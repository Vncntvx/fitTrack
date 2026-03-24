import 'dart:convert';
import 'package:shelf/shelf.dart';

/// 创建认证中间件
/// 验证请求中的 Authorization 头
/// Web 资源（非 /api 路径）跳过认证
Middleware authMiddleware(String? expectedToken) {
  return (Handler handler) {
    return (Request request) async {
      final path = request.url.path;

      // 健康检查端点跳过认证
      if (path == '/health' || path == 'health') {
        return handler(request);
      }

      // Web 资源（非 /api 路径）跳过认证
      if (!path.startsWith('api/')) {
        return handler(request);
      }

      // 如果没有设置令牌，允许访问
      if (expectedToken == null || expectedToken.isEmpty) {
        return handler(request);
      }

      final authHeader =
          request.headers['authorization'] ?? request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return _unauthorizedResponse();
      }

      final incomingToken = authHeader.substring('Bearer '.length).trim();
      if (incomingToken.isEmpty || incomingToken != expectedToken) {
        return _unauthorizedResponse();
      }

      return handler(request);
    };
  };
}

Response _unauthorizedResponse() {
  return Response.unauthorized(
    jsonEncode({'error': 'Unauthorized'}),
    headers: {'Content-Type': 'application/json'},
  );
}
