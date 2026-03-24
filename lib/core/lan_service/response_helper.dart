import 'dart:convert';

import 'package:shelf/shelf.dart';

/// 局域网 API 统一响应格式
class LanApiResponse {
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static Response ok({
    Object? data,
    String? message,
    Map<String, dynamic>? meta,
  }) {
    return _build(statusCode: 200, data: data, message: message, meta: meta);
  }

  static Response created({
    Object? data,
    String? message,
    Map<String, dynamic>? meta,
  }) {
    return _build(statusCode: 201, data: data, message: message, meta: meta);
  }

  static Response badRequest(
    String message, {
    String code = 'bad_request',
    Object? details,
    Map<String, dynamic>? meta,
  }) {
    return _error(
      statusCode: 400,
      message: message,
      code: code,
      details: details,
      meta: meta,
    );
  }

  static Response notFound(
    String message, {
    String code = 'not_found',
    Object? details,
    Map<String, dynamic>? meta,
  }) {
    return _error(
      statusCode: 404,
      message: message,
      code: code,
      details: details,
      meta: meta,
    );
  }

  static Response conflict(
    String message, {
    String code = 'conflict',
    Object? details,
    Map<String, dynamic>? meta,
  }) {
    return _error(
      statusCode: 409,
      message: message,
      code: code,
      details: details,
      meta: meta,
    );
  }

  static Response internalServerError(
    String message, {
    String code = 'internal_error',
    Object? details,
    Map<String, dynamic>? meta,
  }) {
    return _error(
      statusCode: 500,
      message: message,
      code: code,
      details: details,
      meta: meta,
    );
  }

  static Response _error({
    required int statusCode,
    required String message,
    required String code,
    Object? details,
    Map<String, dynamic>? meta,
  }) {
    final errorPayload = <String, dynamic>{'code': code, 'message': message};
    if (details != null) {
      errorPayload['details'] = details;
    }

    return _build(
      statusCode: statusCode,
      data: null,
      error: errorPayload,
      message: message,
      meta: meta,
    );
  }

  static Response _build({
    required int statusCode,
    Object? data,
    Object? error,
    String? message,
    Map<String, dynamic>? meta,
  }) {
    return Response(
      statusCode,
      body: jsonEncode({
        'data': data,
        'error': error,
        'message': message,
        'meta': meta,
      }),
      headers: _jsonHeaders,
    );
  }
}
