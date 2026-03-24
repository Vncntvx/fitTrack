import 'package:shelf/shelf.dart';

/// COOP/COEP 中间件
/// 为 Web 端的 Drift OPFS 性能优化添加必要的响应头
///
/// COOP (Cross-Origin-Opener-Policy): 防止跨源文档相互通信
/// COEP (Cross-Origin-Embedder-Policy): 要求嵌入的资源支持 CORS
///
/// 这些头对于 WebAssembly 和 SharedArrayBuffer 等功能是必需的
Middleware coopCoepMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      // 处理 OPTIONS 预检请求
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            'Cross-Origin-Opener-Policy': 'same-origin',
            'Cross-Origin-Embedder-Policy': 'require-corp',
          },
        );
      }

      final response = await handler(request);

      return response.change(
        headers: {
          'Cross-Origin-Opener-Policy': 'same-origin',
          'Cross-Origin-Embedder-Policy': 'require-corp',
        },
      );
    };
  };
}
