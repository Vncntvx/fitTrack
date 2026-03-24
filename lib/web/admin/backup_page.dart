import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/database/database.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_indicator.dart';

/// 备份页面（Web 端）
/// 提供 Web 端备份管理界面，包括备份、恢复和配置功能
class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  // 备份操作状态
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isLoadingConfigs = true;

  // 备份配置列表
  List<BackupConfiguration> _configs = [];
  BackupConfiguration? _selectedConfig;

  // 备份记录列表
  List<BackupRecord> _backupRecords = [];

  // 最后操作结果
  String? _lastOperationResult;
  bool? _lastOperationSuccess;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  /// 加载备份配置
  Future<void> _loadConfigs() async {
    final repo = ref.read(backupConfigRepositoryProvider);

    final configs = await repo.getAll();
    final defaultConfig = await repo.getDefault();

    setState(() {
      _configs = configs;
      _selectedConfig =
          defaultConfig ?? (configs.isNotEmpty ? configs.first : null);
      _isLoadingConfigs = false;
    });

    // 加载备份记录
    if (_selectedConfig != null) {
      await _loadBackupRecords();
    }
  }

  /// 加载备份记录
  Future<void> _loadBackupRecords() async {
    if (_selectedConfig == null) return;

    final records = await ref
        .read(backupServiceProvider)
        .listBackups(_selectedConfig!.id);

    setState(() {
      _backupRecords = records;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('备份管理'),
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConfigs,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoadingConfigs
          ? const LoadingIndicator()
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 备份提供者选择
                _buildProviderSelectionCard(),
                const SizedBox(height: 24),

                // 备份数据区域
                _buildSectionTitle('备份数据'),
                _buildBackupCard(),
                const SizedBox(height: 24),

                // 恢复数据区域
                _buildSectionTitle('恢复数据'),
                _buildRestoreCard(),
                const SizedBox(height: 24),

                // 备份配置区域
                _buildSectionTitle('备份配置'),
                _buildConfigCard(),
                const SizedBox(height: 24),

                // 操作状态
                if (_lastOperationResult != null) _buildStatusCard(),
              ],
            ),
    );
  }

  /// 构建分区标题
  Widget _buildSectionTitle(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  /// 构建备份提供者选择卡片
  Widget _buildProviderSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  '备份目标',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_configs.isEmpty)
              _buildNoConfigWarning()
            else
              _buildConfigDropdown(),
          ],
        ),
      ),
    );
  }

  /// 构建无配置警告
  Widget _buildNoConfigWarning() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '尚未配置备份目标，请先在下方"备份配置"区域添加配置',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建配置下拉选择
  Widget _buildConfigDropdown() {
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<BackupConfiguration>(
      initialValue: _selectedConfig,
      decoration: const InputDecoration(
        labelText: '选择备份配置',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: _configs.map((config) {
        final icon = config.providerType == 'webdav'
            ? Icons.folder_outlined
            : Icons.cloud_queue;
        return DropdownMenuItem(
          value: config,
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(config.displayName),
              if (config.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '默认',
                    style: TextStyle(
                      fontSize: 10,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (config) {
        setState(() {
          _selectedConfig = config;
        });
        if (config != null) {
          _loadBackupRecords();
        }
      },
    );
  }

  /// 构建备份卡片
  Widget _buildBackupCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.backup_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  '创建备份',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '将您的运动数据备份到云端存储',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedConfig == null || _isBackingUp
                        ? null
                        : _performBackup,
                    icon: _isBackingUp
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(_isBackingUp ? '备份中...' : '立即备份'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            // 显示备份统计信息
            if (_backupRecords.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                '历史备份：${_backupRecords.length} 个',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建恢复卡片
  Widget _buildRestoreCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.restore_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  '恢复数据',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '从云端备份恢复数据到本地',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_backupRecords.isEmpty)
              _buildNoBackupWarning()
            else
              _buildBackupRecordsList(),
          ],
        ),
      ),
    );
  }

  /// 构建无备份警告
  Widget _buildNoBackupWarning() {
    return const EmptyStateWidget(
      icon: Icons.info_outline,
      message: '暂无备份记录，请先创建备份',
    );
  }

  /// 构建备份记录列表
  Widget _buildBackupRecordsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('选择要恢复的备份：', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _backupRecords.length,
            itemBuilder: (context, index) {
              final record = _backupRecords[index];
              return _buildBackupRecordItem(record);
            },
          ),
        ),
      ],
    );
  }

  /// 构建单个备份记录项
  Widget _buildBackupRecordItem(BackupRecord record) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      leading: Icon(
        record.status == 'completed' ? Icons.check_circle : Icons.error,
        color: record.status == 'completed'
            ? colorScheme.tertiary
            : colorScheme.error,
        size: 20,
      ),
      title: Text(
        dateFormat.format(record.createdAt),
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        record.targetPath.split('/').last,
        style: const TextStyle(fontSize: 12),
      ),
      trailing: _isRestoring
          ? null
          : IconButton(
              icon: const Icon(Icons.restore, size: 20),
              onPressed: () => _showRestoreConfirmation(record),
              tooltip: '恢复此备份',
            ),
    );
  }

  /// 显示恢复确认对话框
  Future<void> _showRestoreConfirmation(BackupRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认恢复'),
        content: const Text('恢复备份将覆盖当前数据，此操作不可撤销。\n\n确定要继续吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onTertiaryContainer,
            ),
            child: const Text('恢复'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performRestore(record);
    }
  }

  /// 构建配置卡片
  Widget _buildConfigCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.settings_outlined, size: 20),
                SizedBox(width: 8),
                Text(
                  '管理配置',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '添加和管理 WebDAV 或 S3 备份配置',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddConfigDialog('webdav'),
                    icon: const Icon(Icons.folder_outlined),
                    label: const Text('添加 WebDAV'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddConfigDialog('s3'),
                    icon: const Icon(Icons.cloud_queue),
                    label: const Text('添加 S3'),
                  ),
                ),
              ],
            ),
            if (_configs.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                '已配置的目标：',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ...(_configs.map((config) => _buildConfigItem(config))),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建配置项
  Widget _buildConfigItem(BackupConfiguration config) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        config.providerType == 'webdav'
            ? Icons.folder_outlined
            : Icons.cloud_queue,
        size: 20,
      ),
      title: Row(
        children: [
          Text(config.displayName),
          if (config.isDefault) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '默认',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        config.providerType.toUpperCase(),
        style: const TextStyle(fontSize: 12),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (value) => _handleConfigAction(config, value),
        itemBuilder: (context) => [
          if (!config.isDefault)
            const PopupMenuItem(value: 'set_default', child: Text('设为默认')),
          const PopupMenuItem(value: 'test', child: Text('测试连接')),
          PopupMenuItem(
            value: 'delete',
            child: Text(
              '删除',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理配置操作
  Future<void> _handleConfigAction(
    BackupConfiguration config,
    String action,
  ) async {
    switch (action) {
      case 'set_default':
        final repo = ref.read(backupConfigRepositoryProvider);
        final settingsRepo = ref.read(settingsRepositoryProvider);
        await repo.setDefault(config.id);
        await settingsRepo.updateDefaultBackupConfig(config.id);
        await _loadConfigs();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已设置为默认备份配置')));
        }
        break;
      case 'test':
        await _testConfigConnection(config);
        break;
      case 'delete':
        await _deleteConfig(config);
        break;
    }
  }

  /// 测试配置连接
  Future<void> _testConfigConnection(BackupConfiguration config) async {
    try {
      final provider = await ref
          .read(backupProviderFactoryProvider)
          .create(config);
      final success = await provider.testConnection();
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        final textColor = success
            ? colorScheme.onTertiaryContainer
            : colorScheme.onErrorContainer;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? '连接成功' : '连接失败',
              style: TextStyle(color: textColor),
            ),
            backgroundColor: success
                ? colorScheme.tertiaryContainer
                : colorScheme.errorContainer,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '连接失败: $e',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
            backgroundColor: colorScheme.errorContainer,
          ),
        );
      }
    }
  }

  /// 删除配置
  Future<void> _deleteConfig(BackupConfiguration config) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除配置 "${config.displayName}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(backupConfigRepositoryProvider);
      await repo.deleteConfig(config.id);
      await ref
          .read(backupCredentialServiceProvider)
          .deleteCredentials(config.id);
      await _loadConfigs();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('配置已删除')));
      }
    }
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: _lastOperationSuccess == true
          ? colorScheme.tertiaryContainer
          : colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _lastOperationSuccess == true ? Icons.check_circle : Icons.error,
              color: _lastOperationSuccess == true
                  ? colorScheme.tertiary
                  : colorScheme.error,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(_lastOperationResult!)),
          ],
        ),
      ),
    );
  }

  /// 显示添加配置对话框
  Future<void> _showAddConfigDialog(String providerType) async {
    final nameController = TextEditingController();
    final endpointController = TextEditingController();
    final pathController = TextEditingController();
    final regionController = TextEditingController(text: 'us-east-1');
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final accessKeyController = TextEditingController();
    final secretKeyController = TextEditingController();
    bool isDefault = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('添加 ${providerType.toUpperCase()} 配置'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '配置名称',
                    hintText: '例如：我的 WebDAV',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: endpointController,
                  decoration: InputDecoration(
                    labelText: providerType == 'webdav' ? 'WebDAV 地址' : 'S3 端点',
                    hintText: providerType == 'webdav'
                        ? 'https://example.com/webdav'
                        : 'https://s3.amazonaws.com',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pathController,
                  decoration: InputDecoration(
                    labelText: providerType == 'webdav' ? '备份路径' : '存储桶名称',
                    hintText: providerType == 'webdav'
                        ? '/backups'
                        : 'my-bucket',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                if (providerType == 'webdav') ...[
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: secretKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Secret Key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                if (providerType == 's3') ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: regionController,
                    decoration: const InputDecoration(
                      labelText: '区域',
                      hintText: 'us-east-1',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('设为默认备份配置'),
                  value: isDefault,
                  onChanged: (value) {
                    setDialogState(() {
                      isDefault = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty ||
                    endpointController.text.isEmpty ||
                    pathController.text.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请填写所有必填字段')));
                  return;
                }

                final repo = ref.read(backupConfigRepositoryProvider);

                if (providerType == 'webdav') {
                  final id = await repo.createWebDavConfig(
                    displayName: nameController.text,
                    endpoint: endpointController.text,
                    path: pathController.text,
                    isDefault: isDefault,
                  );
                  await ref
                      .read(backupCredentialServiceProvider)
                      .writeWebDavCredentials(
                        configId: id,
                        username: usernameController.text.trim(),
                        password: passwordController.text,
                      );
                } else {
                  final id = await repo.createS3Config(
                    displayName: nameController.text,
                    endpoint: endpointController.text,
                    bucket: pathController.text,
                    region: regionController.text,
                    isDefault: isDefault,
                  );
                  await ref
                      .read(backupCredentialServiceProvider)
                      .writeS3Credentials(
                        configId: id,
                        accessKey: accessKeyController.text.trim(),
                        secretKey: secretKeyController.text,
                      );
                }

                // 关闭对话框 - 使用 Navigator.of 并检查 context 是否可用
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
                await _loadConfigs();
                // 使用 widget 的 context 显示 SnackBar
                if (mounted) {
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(const SnackBar(content: Text('配置已添加')));
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  /// 执行备份
  Future<void> _performBackup() async {
    if (_selectedConfig == null) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '请先选择备份配置',
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
        ),
      );
      return;
    }

    setState(() {
      _isBackingUp = true;
      _lastOperationResult = null;
    });

    try {
      final provider = await ref
          .read(backupProviderFactoryProvider)
          .create(_selectedConfig!);

      final result = await ref
          .read(backupServiceProvider)
          .backup(provider, 'backups', configId: _selectedConfig!.id);

      setState(() {
        _lastOperationResult = result.success
            ? '备份成功！文件: ${result.path}'
            : '备份失败: ${result.error}';
        _lastOperationSuccess = result.success;
      });

      // 刷新备份记录
      await _loadBackupRecords();

      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        final textColor = result.success
            ? colorScheme.onTertiaryContainer
            : colorScheme.onErrorContainer;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success ? '备份成功' : '备份失败: ${result.error}',
              style: TextStyle(color: textColor),
            ),
            backgroundColor: result.success
                ? colorScheme.tertiaryContainer
                : colorScheme.errorContainer,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastOperationResult = '备份失败: $e';
        _lastOperationSuccess = false;
      });
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '备份失败: $e',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
            backgroundColor: colorScheme.errorContainer,
          ),
        );
      }
    } finally {
      setState(() {
        _isBackingUp = false;
      });
    }
  }

  /// 执行恢复
  Future<void> _performRestore(BackupRecord record) async {
    if (_selectedConfig == null) {
      final colorScheme = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '请先选择备份配置',
            style: TextStyle(color: colorScheme.onErrorContainer),
          ),
          backgroundColor: colorScheme.errorContainer,
        ),
      );
      return;
    }

    setState(() {
      _isRestoring = true;
      _lastOperationResult = null;
    });

    try {
      final provider = await ref
          .read(backupProviderFactoryProvider)
          .create(_selectedConfig!);

      final result = await ref
          .read(backupServiceProvider)
          .restore(provider, record);

      setState(() {
        _lastOperationResult = result.success
            ? '恢复成功！'
            : '恢复失败: ${result.error}';
        _lastOperationSuccess = result.success;
      });

      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        final textColor = result.success
            ? colorScheme.onTertiaryContainer
            : colorScheme.onErrorContainer;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.success ? '恢复成功' : '恢复失败: ${result.error}',
              style: TextStyle(color: textColor),
            ),
            backgroundColor: result.success
                ? colorScheme.tertiaryContainer
                : colorScheme.errorContainer,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _lastOperationResult = '恢复失败: $e';
        _lastOperationSuccess = false;
      });
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '恢复失败: $e',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
            backgroundColor: colorScheme.errorContainer,
          ),
        );
      }
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }
}
