import 'dart:convert';
import 'package:flutter/material.dart';
import '../enums/requests_methods.dart';

class InspectorHelper {
  static String extractTimeText(DateTime sentTime) {
    var sentTimeText =
        sentTime.toIso8601String().split('T').last.substring(0, 8);
    sentTimeText = _replaceLastSeparatorWithDot(sentTimeText);
    return sentTimeText;
  }

  static String calculateDuration(DateTime sentTime, DateTime receivedTime) {
    final duration = receivedTime.difference(sentTime);

    if (duration.inMilliseconds < 1000) return '${duration.inMilliseconds} ms';
    if (duration.inSeconds < 60) return '${duration.inSeconds} s';
    if (duration.inMinutes < 60) return '${duration.inMinutes} m';
    if (duration.inHours < 24) return '${duration.inHours} h';
    return '${duration.inDays} d';
  }

  static String _replaceLastSeparatorWithDot(String sentTimeText) =>
      sentTimeText.replaceFirst(':', '.', 5);

  static Color specifyStatusCodeColor(int? statusCode) {
    if (statusCode == null) return const Color(0xFFD92D20);
    if (statusCode >= 500) return const Color(0xFFD92D20);
    if (statusCode >= 400) return const Color(0xFFF04438);
    if (statusCode >= 300) return const Color(0xFFF79009);
    return const Color(0xFF12B76A);
  }

  static Color getMethodColor(RequestMethod method) {
    switch (method) {
      case RequestMethod.GET:
        return const Color(0xFF1570EF);
      case RequestMethod.POST:
        return const Color(0xFF039855);
      case RequestMethod.PUT:
      case RequestMethod.PATCH:
        return const Color(0xFFF79009);
      case RequestMethod.DELETE:
        return const Color(0xFFD92D20);
      default:
        return const Color(0xFF667085);
    }
  }

  static Color getMethodBgColor(RequestMethod method, {bool isDark = false}) {
    final color = getMethodColor(method);
    return isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.12);
  }

  static Color getStatusBgColor(int? statusCode, {bool isDark = false}) {
    final color = specifyStatusCodeColor(statusCode);
    return isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.12);
  }

  static String getStatusText(int? statusCode) {
    if (statusCode == null) return 'Error';
    switch (statusCode) {
      case 200:
        return '200 OK';
      case 201:
        return '201 Created';
      case 204:
        return '204 No Content';
      case 400:
        return '400 Bad Request';
      case 401:
        return '401 Unauthorized';
      case 403:
        return '403 Forbidden';
      case 404:
        return '404 Not Found';
      case 409:
        return '409 Conflict';
      case 422:
        return '422 Unprocessable';
      case 500:
        return '500 Server Error';
      case 502:
        return '502 Bad Gateway';
      case 503:
        return '503 Unavailable';
      default:
        if (statusCode >= 200 && statusCode < 300) return '$statusCode OK';
        if (statusCode >= 400 && statusCode < 500) return '$statusCode Client Err';
        if (statusCode >= 500) return '$statusCode Server Err';
        return '$statusCode';
    }
  }

  static String? extractErrorMessage(dynamic responseBody) {
    if (responseBody == null) return null;
    if (responseBody is Map) {
      final keys = [
        'message',
        'error',
        'errorMessage',
        'detail',
        'msg',
        'errors',
        'title'
      ];
      for (final key in keys) {
        if (responseBody.containsKey(key) && responseBody[key] != null) {
          final val = responseBody[key];
          if (val is String && val.trim().isNotEmpty) return val.trim();
          if (val is List && val.isNotEmpty) return val.join('\n');
          if (val is Map && val.isNotEmpty) return jsonEncode(val);
        }
      }
    } else if (responseBody is String && responseBody.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map) return extractErrorMessage(decoded);
      } catch (_) {
        if (responseBody.length < 300) return responseBody.trim();
      }
    }
    return null;
  }
}

