import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/lan_service/foreground_service.dart';
import '../../core/logging/logger_service.dart';
import '../../core/secure_storage/secure_storage_service.dart';
import '../../core/network/network_info_service.dart';
import '../../core/providers/app_database_provider.dart';
import 'lan_qr_display.dart';

/// Web 管理界面设置页面
class LanSettingsPage extends ConsumerStatefulWidget {
  const LanSettingsPage({super.key});

  @override
  ConsumerState<LanSettingsPage> createState() => _LanSettingsPageState();
}

class _LanSettingsPageState extends ConsumerState<LanSettingsPage> {
  bool _isRunning = false;
  int _port = 8080;
  String? _ipAddress;
  String? _token;
  bool _isLoading = false;
  bool _tokenEnabled = false;
  final _portController = TextEditingController();
  final LoggerService _logger = LoggerService.instance;

  late ForegroundServiceManager _serviceManager;

  @override
  void initState() {
    super.initState();
    _serviceManager = ref.read(foregroundServiceManagerProvider);
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _serviceManager.initialize();
    await _loadSettings();
  }

  /// 加载设置
  Future<void> _loadSettings() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final secureStorage = ref.read(secureStorageServiceProvider);
    final token = await secureStorage.read(
      SecureStorageService.lanServiceToken,
    );
    _port = await settingsRepo.getLanServicePort();
    _portController.text = '$_port';
    _tokenEnabled = await settingsRepo.isLanServiceTokenEnabled();
    final running = await _serviceManager.isServiceRunning();

    if (!mounted) return;
    setState(() {
      _token = token ?? _generateToken();
      _isRunning = running;
    });

    // 保存新生成的 token
    if (token == null) {
      await secureStorage.write(SecureStorageService.lanServiceToken, _token!);
    }

    await _getIpAddress();
  }

  /// 生成访问令牌
  String _generateToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  /// 获取 IP 地址
  Future<void> _getIpAddress() async {
    try {
      final info = await NetworkInfoService.getLanAddressInfo();
      if (!mounted) return;
      setState(() {
        _ipAddress = info?.host;
      });
    } catch (e, stackTrace) {
      await _logger.error(
        'LanSettingsPage',
        '获取本地 IP 失败',
        error: e,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      setState(() {
        _ipAddress = null;
      });
    }
  }

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Web 管理界面')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          if (_isRunning) ...[_buildAccessCard(), const SizedBox(height: 16)],
          _buildPortCard(),
          const SizedBox(height: 16),
          _buildSecurityCard(),
        ],
      ),
    );
  }

  /// 状态卡片
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '服务状态',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _isRunning ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _isRunning ? '运行中' : '已停止',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _isRunning ? '管理界面可通过局域网访问' : '启动服务后可在局域网内访问管理界面',
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _toggleService,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? '停止服务' : '启动服务'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 访问信息卡片
  Widget _buildAccessCard() {
    final hasLanAddress = NetworkInfoService.isUsableLanAddress(_ipAddress);
    final url = hasLanAddress ? 'http://$_ipAddress:$_port' : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '访问信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text(hasLanAddress ? '访问地址' : '未检测到可用局域网地址'),
              subtitle: Text(
                hasLanAddress
                    ? url!
                    : '请将手机连接到同一局域网的 Wi-Fi 后重试。当前不会展示蜂窝/VPN/模拟器等不可访问地址。',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _getIpAddress,
                    tooltip: '刷新地址',
                  ),
                  if (hasLanAddress && _tokenEnabled && _token != null)
                    IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () {
                        if (_token != null && url != null) {
                          QrCodeDisplay.show(context, url, _token!);
                        }
                      },
                      tooltip: '显示 QR 码',
                    ),
                ],
              ),
            ),
            if (_tokenEnabled && _token != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('访问令牌', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              _token!,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 16,
                                letterSpacing: 1,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.copy,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _token!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('令牌已复制到剪贴板')),
                              );
                            },
                            tooltip: '复制令牌',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _regenerateToken,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('重新生成令牌'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 端口设置卡片
  Widget _buildPortCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '服务设置',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    enabled: !_isRunning,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '端口号',
                      hintText: '8080',
                      border: OutlineInputBorder(),
                    ),
                    controller: _portController,
                    onChanged: (value) {
                      _port = int.tryParse(value) ?? 8080;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isRunning ? '服务运行中不可更改端口' : '建议使用 1024 以上的端口号',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('启用访问令牌'),
              subtitle: Text(
                _tokenEnabled ? '需要令牌才能访问 Web UI' : '任何人都可以访问 Web UI',
              ),
              value: _tokenEnabled,
              onChanged: _isRunning
                  ? null
                  : (value) async {
                      final settingsRepo = ref.read(settingsRepositoryProvider);
                      await settingsRepo.updateLanServiceTokenEnabled(value);
                      setState(() => _tokenEnabled = value);
                    },
            ),
            if (!_tokenEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '警告：关闭令牌后，同一局域网内的任何人都可访问管理界面',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 安全卡片
  Widget _buildSecurityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '安全提示',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSecurityItem(
              Icons.wifi,
              '仅在局域网内访问',
              '确保您的设备和电脑/平板连接到同一个 Wi-Fi 网络',
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              _tokenEnabled ? Icons.security : Icons.lock_open,
              _tokenEnabled ? '访问保护已启用' : '访问保护已关闭',
              _tokenEnabled
                  ? '管理界面需要访问令牌才能访问，请勿分享给不信任的人'
                  : '任何人都可以访问管理界面，建议启用令牌保护',
            ),
            const SizedBox(height: 12),
            _buildSecurityItem(
              Icons.notifications_active,
              '前台服务',
              '服务运行时会显示前台通知，请保持应用运行',
            ),
          ],
        ),
      ),
    );
  }

  /// 安全提示项
  Widget _buildSecurityItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 切换服务
  Future<void> _toggleService() async {
    setState(() => _isLoading = true);

    try {
      if (_isRunning) {
        await _serviceManager.stopService();
        final settingsRepo = ref.read(settingsRepositoryProvider);
        await settingsRepo.updateLanService(enabled: false, port: _port);
        setState(() => _isRunning = false);
      } else {
        if (_port < 1 || _port > 65535) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('端口范围必须在 1-65535')));
          }
          return;
        }
        final accessHost = await NetworkInfoService.getLocalIpAddress();
        if (mounted) {
          setState(() => _ipAddress = accessHost);
        }

        final success = await _serviceManager.startService(
          port: _port,
          token: _tokenEnabled ? _token : null,
          displayHost: accessHost,
        );
        if (success) {
          final settingsRepo = ref.read(settingsRepositoryProvider);
          await settingsRepo.updateLanService(enabled: true, port: _port);
        }
        setState(() => _isRunning = success);
        if (success) {
          await _getIpAddress();
        } else if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('服务启动失败，请查看日志')));
        }
      }
    } catch (e, stackTrace) {
      await _logger.error(
        'LanSettingsPage',
        '切换服务状态失败',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 重新生成令牌
  Future<void> _regenerateToken() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新生成令牌'),
        content: const Text('重新生成后，已连接的 Web UI 需要重新扫码或输入新令牌。确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newToken = _generateToken();
      final secureStorage = ref.read(secureStorageServiceProvider);
      await secureStorage.write(SecureStorageService.lanServiceToken, newToken);
      setState(() => _token = newToken);
    }
  }
}
