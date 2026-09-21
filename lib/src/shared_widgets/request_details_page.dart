import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:requests_inspector/requests_inspector.dart';
import 'package:requests_inspector/src/json_pretty_converter.dart';

import '../curl_command_generator.dart';
import '../helpers/inspector_helper.dart';
import '../json_tree_view_widget.dart';

class RequestDetailsPage extends StatelessWidget {
  const RequestDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Selector<InspectorController, RequestDetails?>(
        selector: (_, inspectorController) =>
            inspectorController.selectedRequest,
        shouldRebuild: (previous, next) => true,
        builder: (context, selectedRequest, _) => selectedRequest == null
            ? const Center(
                child: Text('Vui lòng chọn một request để xem chi tiết'),
              )
            : _buildRequestDetails(context, selectedRequest),
      ),
    );
  }

  Widget _buildRequestDetails(BuildContext context, RequestDetails request) {
    return Selector<InspectorController, bool>(
      selector: (_, inspectorController) => inspectorController.isTreeView,
      builder: (context, isTreeView, _) => Selector<InspectorController, bool>(
        selector: (_, inspectorController) => inspectorController.isDarkMode,
        builder: (context, isDarkMode, _) => ListView(
          padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 40.0),
          children: [
            // 1. Error Summary Banner (Chạm để copy toàn bộ lỗi)
            _buildErrorBanner(context, request, isDarkMode),

            // 2. Card thông tin chính (Chạm vào URL để copy cURL ngay)
            _buildGeneralInfoCard(context, request, isDarkMode),
            const SizedBox(height: 8.0),

            // 3. Headers (Chạm để mở/đóng hoặc copy)
            if (request.headers != null)
              _ModernCollapsibleSection(
                title: 'Headers',
                subtitle: '${_countItems(request.headers)} mục',
                icon: Icons.vpn_key_outlined,
                txtCopy: JsonPrettyConverter().convert(request.headers),
                isDarkMode: isDarkMode,
                children: _buildDataBlock(request.headers,
                    isTreeView: isTreeView, isDarkMode: isDarkMode),
              ),

            // 4. Query Parameters (Chạm để mở/đóng hoặc copy)
            if (request.queryParameters != null)
              _ModernCollapsibleSection(
                title: 'Query Parameters',
                subtitle: '${_countItems(request.queryParameters)} mục',
                icon: Icons.filter_alt_outlined,
                txtCopy: JsonPrettyConverter().convert(request.queryParameters),
                isDarkMode: isDarkMode,
                children: _buildDataBlock(request.queryParameters,
                    isTreeView: isTreeView, isDarkMode: isDarkMode),
              ),

            // 5. Request Body (Chạm để mở/đóng hoặc copy)
            if (request.requestBody != null)
              _ModernCollapsibleSection(
                title: 'Request Body',
                icon: Icons.upload_file_outlined,
                txtCopy: JsonPrettyConverter().convert(request.requestBody),
                isDarkMode: isDarkMode,
                children: _buildDataBlock(request.requestBody,
                    isTreeView: isTreeView, isDarkMode: isDarkMode),
              ),

            // 6. Response Body (Chạm để mở/đóng hoặc copy)
            if (request.responseBody != null)
              _ModernCollapsibleSection(
                title: 'Response Body',
                icon: Icons.download_done_outlined,
                txtCopy: JsonPrettyConverter().convert(request.responseBody),
                isDarkMode: isDarkMode,
                children: _buildDataBlock(request.responseBody,
                    isTreeView: isTreeView, isDarkMode: isDarkMode),
              ),
          ],
        ),
      ),
    );
  }

  int _countItems(dynamic data) {
    if (data is Map) return data.length;
    if (data is List) return data.length;
    return 1;
  }

  // Error Banner: Chạm trực tiếp vào banner để copy nội dung lỗi
  Widget _buildErrorBanner(
      BuildContext context, RequestDetails request, bool isDarkMode) {
    final isError = request.statusCode == null || request.statusCode! >= 400;
    if (!isError) return const SizedBox.shrink();

    final errorMessage =
        InspectorHelper.extractErrorMessage(request.responseBody);
    final statusText = InspectorHelper.getStatusText(request.statusCode);

    return InkWell(
      onTap: () {
        final textToCopy = errorMessage ?? 'Lỗi $statusText: ${request.url}';
        Clipboard.setData(ClipboardData(text: textToCopy));
        _showToast(context, '✅ Đã copy thông báo lỗi vào clipboard!');
      },
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? const Color(0xFF3B1E1E)
              : const Color(0xFFFEF3F2),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isDarkMode
                ? const Color(0xFFB42318).withValues(alpha: 0.6)
                : const Color(0xFFFDA29B),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFD92D20), size: 20.0),
                const SizedBox(width: 8.0),
                Text(
                  'LỖI: $statusText',
                  style: const TextStyle(
                    color: Color(0xFFD92D20),
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD92D20).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded,
                          size: 13.0, color: Color(0xFFD92D20)),
                      SizedBox(width: 4.0),
                      Text(
                        'Chạm để copy lỗi',
                        style: TextStyle(
                          color: Color(0xFFD92D20),
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (errorMessage != null && errorMessage.isNotEmpty) ...[
              const SizedBox(height: 8.0),
              Text(
                errorMessage,
                style: TextStyle(
                  color: isDarkMode
                      ? const Color(0xFFFECDCA)
                      : const Color(0xFFB42318),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Card thông tin chính: Chạm vào vùng URL là copy cURL ngay lập tức!
  Widget _buildGeneralInfoCard(
      BuildContext context, RequestDetails request, bool isDarkMode) {
    final methodColor = InspectorHelper.getMethodColor(request.requestMethod);
    final methodBg = InspectorHelper.getMethodBgColor(request.requestMethod,
        isDark: isDarkMode);
    final statusColor =
        InspectorHelper.specifyStatusCodeColor(request.statusCode);
    final statusBg =
        InspectorHelper.getStatusBgColor(request.statusCode, isDark: isDarkMode);
    final statusText = InspectorHelper.getStatusText(request.statusCode);

    final sentTimeText = InspectorHelper.extractTimeText(request.sentTime);
    final durationText = request.receivedTime != null
        ? InspectorHelper.calculateDuration(
            request.sentTime, request.receivedTime!)
        : 'Pending';

    final cardBg = isDarkMode ? const Color(0xFF1E1E24) : Colors.white;
    final borderColor = isDarkMode ? Colors.white12 : const Color(0xFFEAECF0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Badges & Thời gian
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: methodBg,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  request.requestMethod.name,
                  style: TextStyle(
                    color: methodColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$sentTimeText • $durationText',
                style: TextStyle(
                  fontSize: 12.0,
                  color: isDarkMode ? Colors.white60 : const Color(0xFF667085),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          // Row 2: Tên endpoint
          Text(
            request.requestName,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w700,
              color: isDarkMode ? Colors.white : const Color(0xFF1D2939),
            ),
          ),
          const SizedBox(height: 8.0),
          // Row 3: Hộp URL tương tác - Chạm vào là copy cURL ngay!
          InkWell(
            onTap: () {
              final curl = CurlCommandGenerator(request).generate();
              Clipboard.setData(ClipboardData(text: curl));
              _showToast(context, '✅ Đã copy cURL vào clipboard!');
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: request.url));
              _showToast(context, '✅ Đã copy URL');
            },
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF141418)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: isDarkMode ? Colors.white10 : const Color(0xFFEAECF0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.terminal_rounded,
                        size: 14.0,
                        color: isDarkMode
                            ? const Color(0xFF84CAFF)
                            : const Color(0xFF1570EF),
                      ),
                      const SizedBox(width: 6.0),
                      Text(
                        'Chạm để copy cURL (Giữ để copy URL)',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? const Color(0xFF84CAFF)
                              : const Color(0xFF1570EF),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.copy_rounded,
                        size: 14.0,
                        color: isDarkMode
                            ? const Color(0xFF84CAFF)
                            : const Color(0xFF1570EF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    request.url,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      color: isDarkMode
                          ? Colors.white70
                          : const Color(0xFF344054),
                    ),
                  ),
                ],
              ),
            ),
          ),
            // Row 4: Hộp Token tương tác - Chạm vào là copy mỗi Token ngay!
            if (_extractToken(request.headers) != null) ...[
              const SizedBox(height: 8.0),
              Builder(
                builder: (ctx) {
                  final token = _extractToken(request.headers)!;
                  return InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: token));
                      _showToast(context, '🔑 Đã sao chép Token vào clipboard!');
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF262014)
                            : const Color(0xFFFEFBE8),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFFD4A31C).withValues(alpha: 0.4)
                              : const Color(0xFFFDE272),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.vpn_key_rounded,
                                size: 14.0,
                                color: Color(0xFFD4A31C),
                              ),
                              const SizedBox(width: 6.0),
                              const Text(
                                'Chạm để sao chép Token (chỉ token gửi BE)',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFD4A31C),
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.copy_rounded,
                                size: 14.0,
                                color: Color(0xFFD4A31C),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            token,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontFamily: 'monospace',
                              color: isDarkMode
                                  ? Colors.white70
                                  : const Color(0xFF713B12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      );
  }

  static String? _extractToken(dynamic headers) {
    if (headers == null) return null;
    if (headers is Map) {
      for (final entry in headers.entries) {
        final key = entry.key.toString().toLowerCase();
        if (key == 'authorization') {
          String val = entry.value.toString().trim();
          if (val.toLowerCase().startsWith('bearer ')) {
            val = val.substring(7).trim();
          }
          if (val.isNotEmpty) return val;
        }
      }
    }
    return null;
  }

  static void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Widget> _buildDataBlock(
    dynamic data, {
    required bool isTreeView,
    required bool isDarkMode,
  }) {
    if (data == null) return [];

    if ((data is Map || data is String || data is List) && data.isEmpty) {
      return [];
    }

    return [
      isTreeView
          ? JsonTreeView(data, isDarkMode: isDarkMode)
          : _buildSelectableText(data)
    ];
  }

  Widget _buildSelectableText(dynamic text) {
    final prettyprint = JsonPrettyConverter().convert(text);

    return SelectableText(
      prettyprint,
      style: const TextStyle(fontSize: 12.0, fontFamily: 'monospace'),
    );
  }
}

// Collapsible Section hiện đại, thoáng mắt, bấm vào nội dung là copy luôn
class _ModernCollapsibleSection extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String txtCopy;
  final List<Widget> children;
  final bool isDarkMode;
  final IconData icon;

  const _ModernCollapsibleSection({
    required this.title,
    this.subtitle,
    required this.txtCopy,
    required this.children,
    required this.isDarkMode,
    required this.icon,
  });

  @override
  State<_ModernCollapsibleSection> createState() =>
      _ModernCollapsibleSectionState();
}

class _ModernCollapsibleSectionState extends State<_ModernCollapsibleSection> {
  bool _isExpanded = true;

  void _copyContent() {
    Clipboard.setData(ClipboardData(text: widget.txtCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Đã copy ${widget.title} vào clipboard!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDarkMode ? const Color(0xFF1E1E24) : Colors.white;
    final contentBg =
        widget.isDarkMode ? const Color(0xFF141418) : const Color(0xFFF9FAFB);
    final borderColor =
        widget.isDarkMode ? Colors.white12 : const Color(0xFFEAECF0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: widget.isDarkMode ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề Section (Bấm mở/đóng)
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 13.0),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      size: 18.0,
                      color: widget.isDarkMode
                          ? const Color(0xFF84CAFF)
                          : const Color(0xFF1570EF),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: widget.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF1D2939),
                            ),
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(width: 8.0),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: widget.isDarkMode
                                    ? const Color(0xFF2C2D35)
                                    : const Color(0xFFF2F4F7),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                widget.subtitle!,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: widget.isDarkMode
                                      ? Colors.white60
                                      : const Color(0xFF667085),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Nút icon Copy riêng ở Header
                    InkWell(
                      onTap: _copyContent,
                      borderRadius: BorderRadius.circular(6.0),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 16.0,
                          color: widget.isDarkMode
                              ? Colors.white60
                              : const Color(0xFF667085),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Mũi tên thu gọn / mở rộng
                    Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20.0,
                      color: widget.isDarkMode
                          ? Colors.white60
                          : const Color(0xFF667085),
                    ),
                  ],
                ),
              ),
            ),
            // Phần nội dung mở rộng: Bấm vào vùng nội dung là copy luôn!
            if (_isExpanded) ...[
              Divider(height: 1, thickness: 1, color: borderColor),
              InkWell(
                onTap: _copyContent,
                child: Container(
                  width: double.infinity,
                  color: contentBg,
                  padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gợi ý nhỏ gọn
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.touch_app_outlined,
                              size: 12.0,
                              color: widget.isDarkMode
                                  ? Colors.white38
                                  : const Color(0xFF98A2B3),
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              'Chạm để sao chép',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: widget.isDarkMode
                                    ? Colors.white38
                                    : const Color(0xFF98A2B3),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...widget.children,
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
