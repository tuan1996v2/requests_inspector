import 'dart:convert';

import 'package:dio/dio.dart';

import 'enums/requests_methods.dart';
import 'request_details.dart';

class CurlCommandGenerator {
  final RequestDetails details;

  CurlCommandGenerator(this.details);

  String generate() {
    final parts = <String>[];

    // 1. Method & URL
    final method = _getMethodString();
    final url = _buildFullUrl();
    parts.add('curl -X $method "$url"');

    // 2. Headers
    parts.addAll(_getHeaders());

    // 3. Request Body
    parts.addAll(_getRequestBody());

    // 4. Additional Options
    parts.addAll(_getAdditionalOptions());

    // Nối các thành phần bằng line continuation ' \\\n  ' chuẩn POSIX & Postman
    return parts.join(' \\\n  ');
  }

  String _getMethodString() {
    switch (details.requestMethod) {
      case RequestMethod.GET:
        return 'GET';
      case RequestMethod.POST:
        return 'POST';
      case RequestMethod.PATCH:
        return 'PATCH';
      case RequestMethod.PUT:
        return 'PUT';
      case RequestMethod.DELETE:
        return 'DELETE';
      default:
        return details.requestMethod.name;
    }
  }

  String _buildFullUrl() {
    String url = details.url;
    if (details.queryParameters is Map &&
        (details.queryParameters as Map).isNotEmpty) {
      if (!url.contains('?')) {
        final paramList = <String>[];
        (details.queryParameters as Map).forEach((key, value) {
          if (value != null) {
            paramList.add(
              '${Uri.encodeQueryComponent(key.toString())}=${Uri.encodeQueryComponent(value.toString())}',
            );
          }
        });
        if (paramList.isNotEmpty) {
          url = '$url?${paramList.join('&')}';
        }
      }
    }
    return url;
  }

  List<String> _getHeaders() {
    final headersList = <String>[];
    if (details.headers is Map) {
      (details.headers as Map).forEach((key, value) {
        if (value == null) return;
        final lowerKey = key.toString().toLowerCase();
        if (lowerKey == 'content-length') return;
        // Escape dấu nháy kép nếu có trong header value
        final sanitizedValue = value.toString().replaceAll('"', r'\"');
        headersList.add('-H "$key: $sanitizedValue"');
      });
    }
    return headersList;
  }

  List<String> _getRequestBody() {
    final bodyParts = <String>[];
    if (details.requestBody == null) return bodyParts;

    String contentType = '';
    if (details.headers is Map) {
      final headersMap = details.headers as Map;
      for (final entry in headersMap.entries) {
        if (entry.key.toString().toLowerCase() == 'content-type') {
          contentType = entry.value?.toString().toLowerCase() ?? '';
          break;
        }
      }
    }

    if (contentType.contains('application/x-www-form-urlencoded')) {
      if (details.requestBody is Map) {
        final paramList = <String>[];
        (details.requestBody as Map).forEach((key, value) {
          paramList.add(
            '${Uri.encodeQueryComponent(key.toString())}=${Uri.encodeQueryComponent(value?.toString() ?? '')}',
          );
        });
        final bodyString = paramList.join('&');
        final escapedBody = bodyString.replaceAll("'", r"'\''");
        bodyParts.add("-d '$escapedBody'");
      } else {
        final escapedBody =
            details.requestBody.toString().replaceAll("'", r"'\''");
        bodyParts.add("-d '$escapedBody'");
      }
    } else if (contentType.contains('multipart/form-data')) {
      if (details.requestBody is FormData) {
        final formData = details.requestBody as FormData;
        for (final mapEntry in formData.fields) {
          final escapedVal = mapEntry.value.replaceAll("'", r"'\''");
          bodyParts.add("-F '${mapEntry.key}=$escapedVal'");
        }
        for (final file in formData.files) {
          final fileName = file.value.filename ?? 'file';
          bodyParts.add("-F '${file.key}=@$fileName'");
        }
      }
    } else {
      // JSON hoặc raw body
      String bodyString;
      if (details.requestBody is String) {
        bodyString = details.requestBody as String;
      } else {
        try {
          bodyString = jsonEncode(details.requestBody);
        } catch (_) {
          bodyString = details.requestBody.toString();
        }
      }

      if (bodyString.trim().isNotEmpty) {
        final escapedBody = bodyString.replaceAll("'", r"'\''");
        bodyParts.add("-d '$escapedBody'");
      }
    }

    return bodyParts;
  }

  List<String> _getAdditionalOptions() {
    return [
      '-L', // Follow Redirects
      '-k', // Insecure SSL
    ];
  }
}
