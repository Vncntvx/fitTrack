import 'package:flutter/material.dart';

/// 服务状态指示器
/// 显示局域网服务的运行状态
class ServiceStatusIndicator extends StatelessWidget {
  final bool isRunning;
  final String? url;
  final VoidCallback? onTap;

  const ServiceStatusIndicator({
    super.key,
    required this.isRunning,
    this.url,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isRunning ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isRunning ? Colors.green : Colors.red).withAlpha(
                        100,
                      ),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRunning ? '服务运行中' : '服务已停止',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isRunning && url != null)
                      Text(
                        url!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                isRunning ? Icons.arrow_forward_ios : Icons.play_arrow,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
