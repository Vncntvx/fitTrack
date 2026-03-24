import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../../core/logging/logger_service.dart';
import '../../core/providers/app_database_provider.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_indicator.dart';

/// 备份页面（移动端）
/// 提供备份、恢复、配置管理能力
class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  final LoggerService _logger = LoggerService.instance;

  bool _isLoading = true;
  bool _isLoadingRecords = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  List<BackupConfiguration> _configs = [];
  BackupConfiguration? _selectedConfig;
  List<BackupRecord> _records = [];

  String? _statusMessage;
  bool _statusSuccess = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据备份'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新',
            onPressed: _reload,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildTargetCard(),
                const SizedBox(height: 16),
                _buildActionCard(),
                const SizedBox(height: 16),
                _buildRecordsCard(),
                const SizedBox(height: 16),
                _buildConfigCard(),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(),
                ],
              ],
            ),
    );
  }

  Widget _buildTargetCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备份目标',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('请选择用于备份/恢复的配置'),
            const SizedBox(height: 12),
            if (_configs.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '暂无备份配置，请先在下方添加 WebDAV 或 S3 配置',
                  style: TextStyle(color: colorScheme.onErrorContainer),
                ),
              )
            else
              DropdownButtonFormField<BackupConfiguration>(
                initialValue: _selectedConfig,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '当前配置',
                ),
                items: _configs.map((config) {
                  final label = config.isDefault
                      ? '${config.displayName}（默认）'
                      : config.displayName;
                  return DropdownMenuItem(
                    value: config,
                    child: Text(
                      '$label · ${config.providerType.toUpperCase()}',
                    ),
                  );
                }).toList(),
                onChanged: (config) => _selectConfig(config),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    final disabled = _selectedConfig == null || _isBackingUp || _isRestoring;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备份与恢复',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: disabled ? null : _performBackup,
                    icon: _isBackingUp
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.backup),
                    label: Text(_isBackingUp ? '备份中...' : '立即备份'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: disabled ? null : _testSelectedConfig,
                    icon: const Icon(Icons.wifi_protected_setup),
                    label: const Text('测试连接'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备份记录',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_selectedConfig == null)
              const Text('请选择备份配置后查看记录')
            else if (_isLoadingRecords)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LoadingIndicator(size: 24),
              )
            else if (_records.isEmpty)
              const EmptyStateWidget(
                icon: Icons.history_toggle_off,
                message: '当前配置暂无备份记录',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _records.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = _records[index];
                  final createdAt = DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).format(record.createdAt);
                  final size = _extractSize(record.metadataJson);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      record.status == 'completed'
                          ? Icons.check_circle
                          : Icons.error,
                      color: record.status == 'completed'
                          ? colorScheme.tertiary
                          : colorScheme.error,
                    ),
                    title: Text(createdAt),
                    subtitle: Text('状态: ${record.status} · 大小: $size'),
                    trailing: IconButton(
                      icon: _isRestoring
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                      tooltip: '恢复此备份',
                      onPressed: _isRestoring
                          ? null
                          : () => _confirmAndRestore(record),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '配置管理',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddConfigDialog('webdav'),
                    icon: const Icon(Icons.folder_open),
                    label: const Text('添加 WebDAV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddConfigDialog('s3'),
                    icon: const Icon(Icons.cloud),
                    label: const Text('添加 S3'),
                  ),
                ),
              ],
            ),
            if (_configs.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._configs.map((config) => _buildConfigItem(config)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(BackupConfiguration config) {
    final selected = _selectedConfig?.id == config.id;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: selected ? colorScheme.primaryContainer : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          config.providerType == 'webdav' ? Icons.folder_outlined : Icons.cloud,
        ),
        title: Text(config.displayName),
        subtitle: Text('${config.endpoint} / ${config.bucketOrPath}'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'default':
                await _setDefaultConfig(config);
                break;
              case 'test':
                await _testConfig(config);
                break;
              case 'delete':
                await _deleteConfig(config);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'default', child: Text('设为默认')),
            const PopupMenuItem(value: 'test', child: Text('测试连接')),
            const PopupMenuItem(value: 'delete', child: Text('删除配置')),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _statusSuccess ? colorScheme.tertiary : colorScheme.error;
    final backgroundColor = _statusSuccess
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              _statusSuccess ? Icons.check_circle : Icons.error,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(_statusMessage!)),
          ],
        ),
      ),
    );
  }

  Future<void> _reload() async {
    final repo = ref.read(backupConfigRepositoryProvider);

    setState(() {
      _isLoading = true;
    });

    try {
      final previousSelectedId = _selectedConfig?.id;
      final configs = await repo.getAll();
      final defaultConfig = await repo.getDefault();

      BackupConfiguration? selected;
      if (previousSelectedId != null) {
        for (final config in configs) {
          if (config.id == previousSelectedId) {
            selected = config;
            break;
          }
        }
      }
      selected ??= defaultConfig;
      selected ??= configs.isNotEmpty ? configs.first : null;

      List<BackupRecord> records = [];
      if (selected != null) {
        records = await ref
            .read(backupServiceProvider)
            .listBackups(selected.id);
      }

      if (!mounted) return;
      setState(() {
        _configs = configs;
        _selectedConfig = selected;
        _records = records;
      });
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '刷新备份页面数据失败',
        error: e,
        stackTrace: stackTrace,
      );
      _setStatus('加载备份数据失败: $e', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectConfig(BackupConfiguration? config) async {
    if (config == null) return;
    setState(() {
      _selectedConfig = config;
      _isLoadingRecords = true;
    });

    try {
      final records = await ref
          .read(backupServiceProvider)
          .listBackups(config.id);
      if (!mounted) return;
      setState(() {
        _records = records;
      });
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '加载备份记录失败',
        error: e,
        stackTrace: stackTrace,
      );
      _setStatus('加载备份记录失败: $e', false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecords = false;
        });
      }
    }
  }

  Future<void> _performBackup() async {
    final config = _selectedConfig;
    if (config == null) {
      _setStatus('请先选择备份配置', false);
      return;
    }

    setState(() => _isBackingUp = true);

    try {
      final provider = await ref
          .read(backupProviderFactoryProvider)
          .create(config);
      final result = await ref
          .read(backupServiceProvider)
          .backup(provider, 'backups', configId: config.id);

      if (result.success) {
        _setStatus('备份成功: ${result.path}', true);
        await _reload();
      } else {
        _setStatus('备份失败: ${result.error}', false);
      }
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '执行备份失败',
        error: e,
        stackTrace: stackTrace,
      );
      _setStatus('备份失败: $e', false);
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _confirmAndRestore(BackupRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复将覆盖当前本地数据，确定继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('恢复'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _restoreRecord(record);
  }

  Future<void> _restoreRecord(BackupRecord record) async {
    setState(() => _isRestoring = true);

    try {
      final repo = ref.read(backupConfigRepositoryProvider);
      final config = await repo.getById(record.configId);
      if (config == null) {
        throw StateError('恢复失败：备份配置不存在（ID: ${record.configId}）');
      }

      final provider = await ref
          .read(backupProviderFactoryProvider)
          .create(config);
      final result = await ref
          .read(backupServiceProvider)
          .restore(provider, record);
      if (!result.success) {
        _setStatus('恢复失败: ${result.error}', false);
        return;
      }

      ref.invalidate(trainingSessionsStreamProvider);
      ref.invalidate(exercisesStreamProvider);
      ref.invalidate(templatesStreamProvider);
      ref.invalidate(settingsStreamProvider);

      _setStatus('恢复成功，请返回首页确认数据状态', true);
      await _reload();
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '执行恢复失败',
        error: e,
        stackTrace: stackTrace,
      );
      _setStatus('恢复失败: $e', false);
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }

  Future<void> _testSelectedConfig() async {
    final config = _selectedConfig;
    if (config == null) {
      _setStatus('请先选择备份配置', false);
      return;
    }
    await _testConfig(config);
  }

  Future<void> _testConfig(BackupConfiguration config) async {
    try {
      final provider = await ref
          .read(backupProviderFactoryProvider)
          .create(config);
      final ok = await provider.testConnection();
      _setStatus(ok ? '连接测试成功' : '连接测试失败', ok);
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '测试备份连接失败',
        error: e,
        stackTrace: stackTrace,
        data: {'configId': config.id},
      );
      _setStatus('连接测试失败: $e', false);
    }
  }

  Future<void> _setDefaultConfig(BackupConfiguration config) async {
    try {
      final repo = ref.read(backupConfigRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);

      await repo.setDefault(config.id);
      await settingsRepo.updateDefaultBackupConfig(config.id);
      _setStatus('默认配置已更新: ${config.displayName}', true);
      await _reload();
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '设置默认配置失败',
        error: e,
        stackTrace: stackTrace,
        data: {'configId': config.id},
      );
      _setStatus('设置默认配置失败: $e', false);
    }
  }

  Future<void> _deleteConfig(BackupConfiguration config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除配置'),
        content: Text('确定删除配置“${config.displayName}”吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final repo = ref.read(backupConfigRepositoryProvider);
      final settingsRepo = ref.read(settingsRepositoryProvider);
      final count = await repo.deleteConfig(config.id);

      if (count == 0) {
        _setStatus('删除失败：配置不存在', false);
        return;
      }

      await ref
          .read(backupCredentialServiceProvider)
          .deleteCredentials(config.id);
      await settingsRepo.updateDefaultBackupConfig(null);
      _setStatus('配置已删除: ${config.displayName}', true);
      await _reload();

      if (_selectedConfig != null) {
        await settingsRepo.updateDefaultBackupConfig(_selectedConfig!.id);
      }
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupPage',
        '删除配置失败',
        error: e,
        stackTrace: stackTrace,
        data: {'configId': config.id},
      );
      _setStatus('删除配置失败: $e', false);
    }
  }

  Future<void> _showAddConfigDialog(String providerType) async {
    final isWebDav = providerType == 'webdav';
    final nameController = TextEditingController();
    final endpointController = TextEditingController();
    final pathOrBucketController = TextEditingController();
    final regionController = TextEditingController(text: 'us-east-1');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final accessKeyController = TextEditingController();
    final secretKeyController = TextEditingController();
    bool isDefault = false;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text('添加 ${isWebDav ? 'WebDAV' : 'S3'} 配置'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '配置名称',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: endpointController,
                  decoration: InputDecoration(
                    labelText: isWebDav ? 'WebDAV 地址' : 'S3 端点',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pathOrBucketController,
                  decoration: InputDecoration(
                    labelText: isWebDav ? '备份路径' : '存储桶名称',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                if (isWebDav) ...[
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: accessKeyController,
                    decoration: const InputDecoration(
                      labelText: 'Access Key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: secretKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Secret Key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regionController,
                    decoration: const InputDecoration(
                      labelText: 'Region',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: isDefault,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('设为默认配置'),
                  onChanged: (value) {
                    setDialogState(() {
                      isDefault = value ?? false;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final endpoint = endpointController.text.trim();
                final pathOrBucket = pathOrBucketController.text.trim();
                final username = usernameController.text.trim();
                final password = passwordController.text;
                final accessKey = accessKeyController.text.trim();
                final secretKey = secretKeyController.text;
                final region = regionController.text.trim();

                if (name.isEmpty || endpoint.isEmpty || pathOrBucket.isEmpty) {
                  _setStatus('请填写完整的配置信息', false);
                  return;
                }
                if (isWebDav && (username.isEmpty || password.isEmpty)) {
                  _setStatus('WebDAV 用户名和密码不能为空', false);
                  return;
                }
                if (!isWebDav && (accessKey.isEmpty || secretKey.isEmpty)) {
                  _setStatus('S3 Access Key 和 Secret Key 不能为空', false);
                  return;
                }

                try {
                  final repo = ref.read(backupConfigRepositoryProvider);
                  final settingsRepo = ref.read(settingsRepositoryProvider);

                  int configId;
                  if (isWebDav) {
                    configId = await repo.createWebDavConfig(
                      displayName: name,
                      endpoint: endpoint,
                      path: pathOrBucket,
                      isDefault: isDefault,
                    );
                    await ref
                        .read(backupCredentialServiceProvider)
                        .writeWebDavCredentials(
                          configId: configId,
                          username: username,
                          password: password,
                        );
                  } else {
                    configId = await repo.createS3Config(
                      displayName: name,
                      endpoint: endpoint,
                      bucket: pathOrBucket,
                      region: region.isEmpty ? null : region,
                      isDefault: isDefault,
                    );
                    await ref
                        .read(backupCredentialServiceProvider)
                        .writeS3Credentials(
                          configId: configId,
                          accessKey: accessKey,
                          secretKey: secretKey,
                        );
                  }

                  if (isDefault) {
                    await settingsRepo.updateDefaultBackupConfig(configId);
                  }

                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(true);
                  }
                } catch (e, stackTrace) {
                  await _logger.error(
                    'BackupPage',
                    '创建备份配置失败',
                    error: e,
                    stackTrace: stackTrace,
                    data: {'providerType': providerType},
                  );
                  _setStatus('创建配置失败: $e', false);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      await _reload();
      _setStatus('配置已创建', true);
    }
  }

  String _extractSize(String? metadataJson) {
    if (metadataJson == null || metadataJson.isEmpty) return '-';
    try {
      final data = jsonDecode(metadataJson) as Map<String, dynamic>;
      final size = data['size'];
      if (size is int) {
        if (size < 1024) return '${size}B';
        if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
        return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (_) {}
    return '-';
  }

  void _setStatus(String message, bool success) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = success
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;
    setState(() {
      _statusMessage = message;
      _statusSuccess = success;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: success
            ? colorScheme.tertiaryContainer
            : colorScheme.errorContainer,
      ),
    );
  }
}
