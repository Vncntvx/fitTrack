import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_static/shelf_static.dart';
import '../logging/logger_service.dart';

/// Web 资源服务
/// 从 Flutter Web 构建产物加载 Web 文件
class WebAssetService {
  /// 创建 Web 资源处理器
  static Future<Handler> createHandler() async {
    // Android 上从打包进应用的 Flutter Web 资源加载
    if (Platform.isAndroid) {
      return _createAssetHandler();
    }

    // 其他平台直接从本地构建目录提供
    return createStaticHandler('build/web', defaultDocument: 'index.html');
  }

  /// 创建 Asset 处理器
  static Handler _createAssetHandler() {
    final logger = LoggerService.instance;
    return (Request request) async {
      final path = request.url.path;
      final assetPath = 'assets/webapp/${path.isEmpty ? 'index.html' : path}';

      try {
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List();

        // 根据文件扩展名设置 Content-Type
        final contentType = _getContentType(assetPath);

        return Response.ok(bytes, headers: {'Content-Type': contentType});
      } catch (e) {
        await logger.warning(
          'WebAssetService',
          'Web 资源不存在，尝试回退',
          error: e,
          data: {'assetPath': assetPath, 'path': path},
        );
        // 缺省根路径直接回退到 Flutter Web 入口
        if (path.isEmpty || path == 'index.html') {
          return await _serveIndexHtml();
        }

        // 静态资源必须返回 404，避免把 JS/CSS 请求误回退成 index.html
        if (path.contains('.')) {
          return Response.notFound('Asset not found: $path');
        }

        // Flutter Web 路由回退到 index.html
        return await _serveIndexHtml();
      }
    };
  }

  /// 提供 index.html
  static Future<Response> _serveIndexHtml() async {
    try {
      final data = await rootBundle.load('assets/webapp/index.html');
      final bytes = data.buffer.asUint8List();

      return Response.ok(
        bytes,
        headers: {'Content-Type': 'text/html; charset=utf-8'},
      );
    } catch (e, stackTrace) {
      await LoggerService.instance.error(
        'WebAssetService',
        'index.html 加载失败',
        error: e,
        stackTrace: stackTrace,
      );
      return Response.notFound('index.html not found');
    }
  }

  /// 根据文件扩展名获取 Content-Type
  static String _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'html':
        return 'text/html; charset=utf-8';
      case 'css':
        return 'text/css';
      case 'js':
        return 'application/javascript';
      case 'map':
        return 'application/json';
      case 'json':
        return 'application/json';
      case 'wasm':
        return 'application/wasm';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'svg':
        return 'image/svg+xml';
      case 'txt':
        return 'text/plain; charset=utf-8';
      case 'woff':
        return 'font/woff';
      case 'woff2':
        return 'font/woff2';
      case 'ttf':
        return 'font/ttf';
      case 'otf':
        return 'font/otf';
      case 'eot':
        return 'application/vnd.ms-fontobject';
      default:
        return 'application/octet-stream';
    }
  }
}
