import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:requests_inspector/src/shared_widgets/request_details_page.dart';
import 'package:requests_inspector/src/shared_widgets/request_item.dart';
import 'package:requests_inspector/src/shared_widgets/run_again_widget.dart';
import '../../requests_inspector.dart';
import '../enums/share_type_enum.dart';

class Inspector extends StatelessWidget {
  const Inspector({
    super.key,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : _navigatorKey = navigatorKey;

  final GlobalKey<NavigatorState>? _navigatorKey;

  bool showStopperDialogsAllowed() => _navigatorKey?.currentContext != null;

  @override
  Widget build(BuildContext context) {
    return Selector<InspectorController, bool>(
      selector: (_, controller) => controller.isDarkMode,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          theme: isDarkMode
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: Colors.grey[800]!,
                  ),
                )
              : ThemeData.light(),
          home: Scaffold(
            appBar: _buildAppBar(isDarkMode),
            body: _buildBody(isDarkMode: isDarkMode),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(bool isDarkMode) {
    return AppBar(
      backgroundColor: isDarkMode ? const Color(0xFF141418) : Colors.white,
      elevation: 0.5,
      iconTheme: IconThemeData(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      title: const Text(
        'Inspector 🕵️',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      leading: IconButton(
        onPressed: InspectorController().hideInspector,
        icon: const Icon(Icons.close),
      ),
      actions: _buildActions(isDarkMode),
    );
  }

  List<Widget> _buildActions(
    bool isDarkMode,
  ) {
    return [
      Selector<InspectorController, int>(
        selector: (_, c) => c.selectedTab,
        builder: (context, selectedTab, _) {
          return Row(
            children: [
              if (selectedTab == 0)
                _ClearAllButton(
                  isDarkMode: isDarkMode,
                  onShowDialog: () => _showAreYouSureDialog(
                    context,
                    onYes: InspectorController().clearAllRequests,
                  ),
                )
              else ...[
                RunAgainButton(
                  key: ValueKey(
                      InspectorController().selectedRequest.hashCode),
                  onTap: InspectorController().runAgain,
                  isDarkMode: isDarkMode,
                ),
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.vpn_key_rounded,
                        size: 20, color: Colors.amber),
                    tooltip: 'Sao chép Token',
                    onPressed: () => _copyToken(ctx),
                  ),
                ),
                Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.share_rounded, size: 20),
                    tooltip: 'Share',
                    onPressed: () => _handleShare(ctx),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      _buildPopUpMenu(),
    ];
  }

  Widget _buildPopUpMenu() {
    return PopupMenuButton(
      icon: Selector<InspectorController, bool>(
        selector: (_, controller) => controller.isDarkMode,
        builder: (context, isDarkMode, __) => Icon(Icons.more_vert,
            color: isDarkMode ? Colors.white : Colors.black87),
      ),
      itemBuilder: (context) => [
        // Dark Mode Toggle
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: InspectorController().toggleInspectorTheme,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dark Mode'),
                  Selector<InspectorController, bool>(
                    selector: (_, controller) => controller.isDarkMode,
                    builder: (context, isDarkMode, __) {
                      return Switch(
                        value: isDarkMode,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.grey[700],
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[700],
                        onChanged: (value) =>
                            InspectorController().toggleInspectorTheme(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        // JSON Tree View Toggle
        PopupMenuItem(
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: InspectorController().toggleInspectorJsonView,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('JSON Tree View'),
                  Selector<InspectorController, bool>(
                    selector: (_, controller) => controller.isTreeView,
                    builder: (context, isTreeView, __) {
                      return Switch(
                        value: isTreeView,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.grey[700],
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[700],
                        onChanged: (value) =>
                            InspectorController().toggleInspectorJsonView(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showStopperDialogsAllowed())
          PopupMenuItem(
            padding: EdgeInsets.zero,
            // Remove default padding for InkWell to fill
            child: InkWell(
              onTap: () => InspectorController().requestStopperEnabled =
                  !InspectorController().requestStopperEnabled,
              child: Padding(
                // Add padding back for content
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Requests Stopper'),
                    Selector<InspectorController, bool>(
                      selector: (_, inspectorController) =>
                          inspectorController.requestStopperEnabled,
                      builder: (context, requestStopperEnabled, _) => Switch(
                        value: requestStopperEnabled,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.grey[700],
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[700],
                        onChanged: (value) =>
                            InspectorController().requestStopperEnabled = value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (showStopperDialogsAllowed())
          PopupMenuItem(
            padding: EdgeInsets.zero,
            // Remove default padding for InkWell to fill
            child: InkWell(
              onTap: () => InspectorController().responseStopperEnabled =
                  !InspectorController().responseStopperEnabled,
              child: Padding(
                // Add padding back for content
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Responses Stopper'),
                    Selector<InspectorController, bool>(
                      selector: (_, inspectorController) =>
                          inspectorController.responseStopperEnabled,
                      builder: (context, responseStopperEnabled, _) => Switch(
                        value: responseStopperEnabled,
                        activeThumbColor: Colors.green,
                        activeTrackColor: Colors.grey[700],
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey[700],
                        onChanged: (value) => InspectorController()
                            .responseStopperEnabled = value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Mục Sao chép Token ở cuối cùng
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () => _copyToken(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                Icon(Icons.vpn_key_rounded, size: 20, color: Colors.amber),
                SizedBox(width: 12.0),
                Text('Sao chép Token (Copy Token)'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _copyToken(BuildContext context) {
    String? token;

    // 1. Ưu tiên lấy từ request đang chọn nếu có
    final selected = InspectorController().selectedRequest;
    if (selected != null) {
      token = _extractTokenFromHeaders(selected.headers);
    }

    // 2. Nếu chưa có, duyệt từ request mới nhất đến cũ nhất
    if (token == null || token.isEmpty) {
      final requests = InspectorController().requestsList;
      for (final r in requests.reversed) {
        token = _extractTokenFromHeaders(r.headers);
        if (token != null && token.isNotEmpty) break;
      }
    }

    if (token != null && token.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: token));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
              SizedBox(width: 8.0),
              Expanded(child: Text('🔑 Đã sao chép Token vào clipboard!')),
            ],
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Chưa tìm thấy Authorization Token trong các requests.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String? _extractTokenFromHeaders(dynamic headers) {
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

  Widget _buildBody({required bool isDarkMode}) {
    return Selector<InspectorController, int>(
      selector: (_, inspectorController) => inspectorController.selectedTab,
      builder: (context, selectedTab, _) => Column(
        children: [
          _buildTabBar(isDarkMode: isDarkMode, selectedTab: selectedTab),
          _buildSelectedTabBody(
              isDarkMode: isDarkMode, selectedTab: selectedTab),
        ],
      ),
    );
  }

  Widget _buildTabBar({required int selectedTab, required bool isDarkMode}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTabItem(
          title: 'All',
          isDarkMode: isDarkMode,
          isSelected: selectedTab == 0,
          isLeft: true,
          onTap: () => InspectorController().selectedTab = 0,
        ),
        _buildTabItem(
          title: 'Request Details',
          isDarkMode: isDarkMode,
          isSelected: selectedTab == 1,
          isLeft: false,
          onTap: () => InspectorController().selectedTab = 1,
        ),
      ],
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isSelected,
    required bool isDarkMode,
    required bool isLeft,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDarkMode
                ? (isSelected ? Colors.white : Colors.black87)
                : (isSelected ? Colors.black87 : Colors.white),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isDarkMode
                  ? (isSelected ? Colors.black87 : Colors.white)
                  : (isSelected ? Colors.white : Colors.black87),
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTabBody(
      {required int selectedTab, required bool isDarkMode}) {
    return selectedTab == 0
        ? _AllRequestsListView(isDarkMode: isDarkMode)
        : const RequestDetailsPage();
  }

  Future<void> _showAreYouSureDialog(
    BuildContext context, {
    required VoidCallback onYes,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xoá? 🤔'),
        content: const Text('Toàn bộ request đã ghi lại sẽ bị xoá khỏi bộ nhớ.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Huỷ', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            child: const Text('Xoá tất cả', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop();
              onYes();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    final selectedRequest = InspectorController().selectedRequest;
    if (selectedRequest == null) return;
    final box = context.findRenderObject() as RenderBox?;
    final isHttp = _isHttp(selectedRequest);

    final shareType = isHttp ? await _showDialogShareType(context) : null;
    if (shareType == null) return;

    InspectorController().shareSelectedRequest(
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      shareType: shareType,
    );
  }

  bool _isHttp(RequestDetails selectedRequest) {
    return selectedRequest.requestMethod == RequestMethod.GET ||
        selectedRequest.requestMethod == RequestMethod.POST ||
        selectedRequest.requestMethod == RequestMethod.PUT ||
        selectedRequest.requestMethod == RequestMethod.PATCH ||
        selectedRequest.requestMethod == RequestMethod.DELETE;
  }

  Future<ShareType?> _showDialogShareType(BuildContext context) {
    return showDialog<ShareType?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chia sẻ định dạng nào? 🤔'),
        content: const Text(
            'Lệnh cURL dùng để chạy lại trên Terminal / Postman. Normal Log dùng để xem toàn bộ thông tin chi tiết.'),
        actions: [
          TextButton(
            child: const Text(
              'Lệnh cURL',
              style: TextStyle(color: Colors.green),
            ),
            onPressed: () => Navigator.of(context).pop(ShareType.CurlCommand),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ShareType.NormalLog),
            child: const Text(
              'Normal Log',
              style: TextStyle(color: Colors.orange),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ShareType.Both),
            child: const Text(
              'Cả hai',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllRequestsListView extends StatefulWidget {
  final bool isDarkMode;
  const _AllRequestsListView({required this.isDarkMode});

  @override
  State<_AllRequestsListView> createState() => _AllRequestsListViewState();
}

class _AllRequestsListViewState extends State<_AllRequestsListView> {
  final TextEditingController _searchController = TextEditingController();
  int _statusFilterIndex = 0; // 0: All, 1: Errors, 2: Success

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Selector<InspectorController, List<RequestDetails>>(
        selector: (_, controller) => controller.requestsList,
        shouldRebuild: (previous, next) => true,
        builder: (context, allRequests, _) {
          if (allRequests.isEmpty) {
            return const Center(child: Text('Chưa có request nào được ghi lại'));
          }

          final totalCount = allRequests.length;
          final errorCount = allRequests
              .where((r) => r.statusCode == null || r.statusCode! >= 400)
              .length;
          final successCount = allRequests
              .where((r) =>
                  r.statusCode != null &&
                  r.statusCode! >= 200 &&
                  r.statusCode! < 300)
              .length;

          final query = _searchController.text.trim().toLowerCase();
          final filteredRequests = allRequests.where((r) {
            if (_statusFilterIndex == 1) {
              final isErr = r.statusCode == null || r.statusCode! >= 400;
              if (!isErr) return false;
            } else if (_statusFilterIndex == 2) {
              final isSuccess = r.statusCode != null &&
                  r.statusCode! >= 200 &&
                  r.statusCode! < 300;
              if (!isSuccess) return false;
            }

            if (query.isNotEmpty) {
              final inUrl = r.url.toLowerCase().contains(query);
              final inName = r.requestName.toLowerCase().contains(query);
              final inMethod = r.requestMethod.name.toLowerCase().contains(query);
              return inUrl || inName || inMethod;
            }

            return true;
          }).toList();

          return Column(
            children: [
              // Search Bar & Filter Row
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 10.0, 12.0, 6.0),
                child: Column(
                  children: [
                    // Search TextField perfectly centered
                    Container(
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? const Color(0xFF1E1E24)
                            : const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(
                          color: widget.isDarkMode
                              ? Colors.white12
                              : const Color(0xFFD0D5DD),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        style: TextStyle(
                          fontSize: 13.0,
                          color: widget.isDarkMode ? Colors.white : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Tìm kiếm URL, endpoint...',
                          hintStyle: TextStyle(
                            fontSize: 13.0,
                            height: 1.2,
                            color: widget.isDarkMode
                                ? Colors.white38
                                : const Color(0xFF98A2B3),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20.0,
                            color: widget.isDarkMode
                                ? Colors.white54
                                : const Color(0xFF667085),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 40.0,
                            minHeight: 40.0,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? InkWell(
                                  onTap: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                  child: Icon(
                                    Icons.cancel_rounded,
                                    size: 18.0,
                                    color: widget.isDarkMode
                                        ? Colors.white54
                                        : const Color(0xFF98A2B3),
                                  ),
                                )
                              : null,
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 36.0,
                            minHeight: 40.0,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Tất cả ($totalCount)',
                            isSelected: _statusFilterIndex == 0,
                            onTap: () => setState(() => _statusFilterIndex = 0),
                          ),
                          const SizedBox(width: 8.0),
                          _buildFilterChip(
                            label: '🔴 Lỗi ($errorCount)',
                            isSelected: _statusFilterIndex == 1,
                            onTap: () => setState(() => _statusFilterIndex = 1),
                            activeColor: const Color(0xFFFDA29B),
                            activeTextColor: const Color(0xFFB42318),
                          ),
                          const SizedBox(width: 8.0),
                          _buildFilterChip(
                            label: '🟢 Thành công ($successCount)',
                            isSelected: _statusFilterIndex == 2,
                            onTap: () => setState(() => _statusFilterIndex = 2),
                            activeColor: const Color(0xFFA6F4C5),
                            activeTextColor: const Color(0xFF027A48),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 6.0, thickness: 0.5),
              // List View
              Expanded(
                child: filteredRequests.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy request phù hợp',
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? Colors.white54
                                : const Color(0xFF667085),
                            fontSize: 13.0,
                          ),
                        ),
                      )
                    : Selector<InspectorController, RequestDetails?>(
                        selector: (_, controller) => controller.selectedRequest,
                        builder: (context, selectedRequest, _) =>
                            ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 12.0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8.0),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            final request = filteredRequests[index];
                            return RequestItemWidget(
                              request: request,
                              isSelected: selectedRequest == request,
                              isDarkMode: widget.isDarkMode,
                              onTap: (itemContext, tappedRequest) {
                                InspectorController().selectedRequest =
                                    tappedRequest;
                                InspectorController().selectedTab = 1;
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
    Color? activeTextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected
              ? (activeColor ?? (widget.isDarkMode ? Colors.white : Colors.black87))
              : (widget.isDarkMode ? const Color(0xFF25262E) : const Color(0xFFEAECF0)),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (activeTextColor ?? (widget.isDarkMode ? Colors.black87 : Colors.white))
                : (widget.isDarkMode ? Colors.white70 : const Color(0xFF344054)),
          ),
        ),
      ),
    );
  }
}

class _ClearAllButton extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onShowDialog;

  const _ClearAllButton({
    required this.isDarkMode,
    required this.onShowDialog,
  });

  @override
  State<_ClearAllButton> createState() => _ClearAllButtonState();
}

class _ClearAllButtonState extends State<_ClearAllButton> {
  Timer? _singleTapTimer;
  DateTime? _lastTapTime;

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    super.dispose();
  }

  void _clearImmediately() {
    _singleTapTimer?.cancel();
    _lastTapTime = null;
    InspectorController().clearAllRequests();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Đã xoá tất cả requests!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTap() {
    final now = DateTime.now();
    // Nếu bấm lần 2 trong vòng 600ms -> Xoá luôn không hiện cảnh báo
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 600)) {
      _clearImmediately();
      return;
    }

    _lastTapTime = now;

    // Chờ 350ms xem người dùng có bấm lần 2 không, nếu không bấm tiếp mới mở Dialog
    _singleTapTimer?.cancel();
    _singleTapTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        widget.onShowDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode
        ? const Color(0xFFFDA29B)
        : const Color(0xFFD92D20);

    return Tooltip(
      message: 'Bấm 2 lần để xoá nhanh không cần cảnh báo',
      child: InkWell(
        onTap: _handleTap,
        onDoubleTap: _clearImmediately,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_sweep_rounded, size: 18, color: textColor),
              const SizedBox(width: 4.0),
              Text(
                'Xoá tất cả',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
