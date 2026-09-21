import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../requests_inspector.dart';
import '../curl_command_generator.dart';
import '../helpers/inspector_helper.dart';

class RequestItemWidget extends StatelessWidget {
  const RequestItemWidget({
    super.key,
    required RequestDetails request,
    required bool isSelected,
    required bool isDarkMode,
    required void Function(BuildContext context, RequestDetails request) onTap,
  })  : _request = request,
        _isSelected = isSelected,
        _isDarkMode = isDarkMode,
        _onTap = onTap;

  final RequestDetails _request;
  final bool _isSelected;
  final bool _isDarkMode;
  final void Function(BuildContext context, RequestDetails request) _onTap;

  @override
  Widget build(BuildContext context) {
    final isError = _request.statusCode == null || _request.statusCode! >= 400;
    final methodColor = InspectorHelper.getMethodColor(_request.requestMethod);
    final methodBg = InspectorHelper.getMethodBgColor(_request.requestMethod, isDark: _isDarkMode);
    final statusColor = InspectorHelper.specifyStatusCodeColor(_request.statusCode);
    final statusBg = InspectorHelper.getStatusBgColor(_request.statusCode, isDark: _isDarkMode);
    final statusText = InspectorHelper.getStatusText(_request.statusCode);

    final durationText = _request.receivedTime != null
        ? InspectorHelper.calculateDuration(_request.sentTime, _request.receivedTime!)
        : 'Pending';
    final sentTimeText = InspectorHelper.extractTimeText(_request.sentTime);

    final cardBg = _isDarkMode
        ? (_isSelected ? const Color(0xFF2C2D35) : const Color(0xFF1E1E24))
        : (_isSelected ? const Color(0xFFF2F4F7) : Colors.white);

    final borderColor = _isSelected
        ? (isError ? const Color(0xFFFDA29B) : const Color(0xFF84CAFF))
        : (_isDarkMode ? Colors.white12 : const Color(0xFFEAECF0));

    final errorMessage = isError ? InspectorHelper.extractErrorMessage(_request.responseBody) : null;

    return InkWell(
      onTap: () => _onTap(context, _request),
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: borderColor, width: _isSelected ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isDarkMode ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Method Badge, Status Badge, Time, and 1-tap Copy cURL
            Row(
              children: [
                // Method Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: methodBg,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    _request.requestMethod.name,
                    style: TextStyle(
                      color: methodColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Time & Duration
                Text(
                  '$sentTimeText • $durationText',
                  style: TextStyle(
                    fontSize: 11.0,
                    color: _isDarkMode ? Colors.white60 : const Color(0xFF667085),
                  ),
                ),
                const SizedBox(width: 4.0),
                // Quick Copy cURL Button
                InkWell(
                  onTap: () {
                    final curl = CurlCommandGenerator(_request).generate();
                    Clipboard.setData(ClipboardData(text: curl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Đã copy cURL: ${_request.requestName}'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 16.0,
                      color: _isDarkMode ? Colors.white70 : const Color(0xFF475467),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6.0),
            // Request Name / Endpoint
            Text(
              _request.requestName,
              style: TextStyle(
                fontSize: 13.0,
                fontWeight: FontWeight.w700,
                color: _isDarkMode ? Colors.white : const Color(0xFF1D2939),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2.0),
            // Full URL
            Text(
              _request.url,
              style: TextStyle(
                fontSize: 11.0,
                color: _isDarkMode ? Colors.white54 : const Color(0xFF667085),
                fontFamily: 'monospace',
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // Error Preview if any
            if (errorMessage != null && errorMessage.isNotEmpty) ...[
              const SizedBox(height: 6.0),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _isDarkMode ? const Color(0xFF381E1E) : const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(
                    color: _isDarkMode ? Colors.red.withValues(alpha: 0.3) : const Color(0xFFFDA29B),
                  ),
                ),
                child: Text(
                  '⚠️ $errorMessage',
                  style: const TextStyle(
                    color: Color(0xFFD92D20),
                    fontSize: 11.0,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

