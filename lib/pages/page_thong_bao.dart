import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/order_notification_controller.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/pages/page_don_hang.dart';

class PageThongBao extends StatefulWidget {
  const PageThongBao({super.key});

  @override
  State<PageThongBao> createState() => _PageThongBaoState();
}

class _PageThongBaoState extends State<PageThongBao> {
  final uiController = Get.put(OrderNotificationsUiController());

  String _formatNotificationTime(DateTime? date) {
    if (date == null) {
      return "Vừa xong";
    }

    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    return "${diff.inDays} ngày trước";
  }

  Future<void> _xoaThongBao(String notiId) async {
    await uiController.deleteNotification(notiId);

    Get.snackbar(
      "Đã xóa",
      "Đã xóa thông báo thành công",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _docTatCa() async {
    if (uiController.notifications.isEmpty) return;
    await uiController.markAllRead();

    Get.snackbar(
      "Thành công",
      "Đã đánh dấu tất cả thông báo là đã đọc",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _handleNotiTap(Map<String, dynamic> item) async {
    final order = await uiController.markReadAndFindOrder(item);
    if (order != null) {
      Get.to(
        () => PageChiTietDonHang(
          order: order,
          statusLabel: OrderNotificationController.statusLabel(
            order["trangThai"]?.toString() ?? "pending",
          ),
        ),
      );
    } else {
      Get.snackbar(
        "Lỗi",
        "Không tìm thấy thông tin đơn hàng này nữa",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildLeadingIcon(String status, IconData iconData) {
    Color bgColor;
    Color iconColor;

    switch (status) {
      case "cancelled":
        bgColor = Color(0xFFFFEBEB);
        iconColor = Colors.redAccent;
        break;
      case "delivered":
        bgColor = Color(0xFFE6F9F0);
        iconColor = Colors.green;
        break;
      case "shipping":
        bgColor = Color(0xFFE8F4FD);
        iconColor = Colors.blue;
        break;
      default:
        bgColor = Color(0xFFFFF2E6);
        iconColor = Color(0xFFEF4D2F);
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }

  IconData _getIconData(String status) {
    switch (status) {
      case "cancelled":
        return Icons.cancel_outlined;
      case "delivered":
        return Icons.task_alt_rounded;
      case "shipping":
        return Icons.local_shipping_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderNotificationsUiController>(
      init: uiController,
      builder: (ui) {
        if (ui.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
          );
        }

        if (ui.notifications.isEmpty) {
          return Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text(
                "Thông báo",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              backgroundColor: Colors.white,
              foregroundColor: Color(0xFF1F2937),
              elevation: 0,
            ),
            body: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 72,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Chưa có thông báo đơn hàng",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Color(0xFFF9FAFB),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text(
              "Thông báo",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1F2937),
            elevation: 0,
            actions: [
              TextButton.icon(
                onPressed: _docTatCa,
                icon: Icon(
                  Icons.done_all_rounded,
                  size: 18,
                  color: Color(0xFFEF4D2F),
                ),
                label: const Text(
                  "Đọc tất cả",
                  style: TextStyle(
                    color: Color(0xFFEF4D2F),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              SizedBox(width: 8),
            ],
          ),
          body: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 12),
            itemCount: ui.notifications.length,
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = ui.notifications[index];
              final notiId = item["id"] as String;
              final daDoc = item["daDoc"] as bool? ?? false;
              final title = item["title"] as String? ?? "";
              final desc = item["desc"] as String? ?? "";
              final time = item["time"] as String? ?? "";
              final trangThai = item["trangThai"] as String? ?? "pending";
              final iconData = _getIconData(trangThai);

              final date = DateTime.tryParse(time);
              final formattedTime = _formatNotificationTime(date);

              return Slidable(
                key: ValueKey(notiId),
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.22,
                  children: [
                    SlidableAction(
                      onPressed: (context) => _xoaThongBao(notiId),
                      backgroundColor: Colors.redAccent.shade100.withValues(
                        alpha: 0.1,
                      ),
                      foregroundColor: Colors.redAccent,
                      icon: Icons.delete_outline_rounded,
                      label: 'Xóa',
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(16),
                      ),
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: daDoc ? Colors.white : Color(0xFFFFF6F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: daDoc
                          ? Color(0xFFE5E7EB)
                          : Color(0xFFFFE4DE),
                      width: 1,
                    ),
                    boxShadow: [
                      if (!daDoc)
                        BoxShadow(
                          color: Color(
                            0xFFEF4D2F,
                          ).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _handleNotiTap(item),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeadingIcon(trangThai, iconData),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: daDoc
                                              ? FontWeight.bold
                                              : FontWeight.w900,
                                          color: daDoc
                                              ? Color(0xFF1F2937)
                                              : Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                    if (!daDoc) ...[
                                      SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4D2F),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                SizedBox(height: 6),
                                Text(
                                  desc,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: daDoc
                                        ? Colors.black54
                                        : Color(0xFF374151),
                                    height: 1.4,
                                    fontWeight: daDoc
                                        ? FontWeight.normal
                                        : FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: daDoc
                                        ? Colors.black38
                                        : Color(
                                            0xFFEF4D2F,
                                          ).withValues(alpha: 0.8),
                                    fontWeight: daDoc
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
