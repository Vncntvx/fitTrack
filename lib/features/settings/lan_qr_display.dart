import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// QR 码显示对话框
class QrCodeDisplay extends StatelessWidget {
  final String lanUrl;
  final String token;

  const QrCodeDisplay({super.key, required this.lanUrl, required this.token});

  /// 显示对话框
  static Future<void> show(BuildContext context, String url, String token) {
    return showDialog(
      context: context,
      builder: (context) => QrCodeDisplay(lanUrl: url, token: token),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullUrl = '$lanUrl?token=$token';

    return AlertDialog(
      title: const Text('扫码访问 Web UI'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: QrImageView(
              data: fullUrl,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lanUrl,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          const Text(
            '在同一局域网的设备上使用浏览器扫描二维码',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: fullUrl));
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('链接已复制')));
          },
          icon: const Icon(Icons.copy),
          label: const Text('复制链接'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }
}
