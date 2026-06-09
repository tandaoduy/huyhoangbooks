import 'dart:convert';

import 'package:huyhoangbooks/controllers/local_data_controller.dart';
import 'package:huyhoangbooks/controllers/order_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderNotificationController {
  OrderNotificationController._();

  // Lấy khóa lưu danh sách thông báo theo tài khoản người dùng
  static String get _notiKey => LocalDataController.userKey("thong_bao");

  // Lấy khóa lưu danh sách ID thông báo đã được người dùng xóa
  static String get _deletedNotiKey {
    return LocalDataController.userKey("thong_bao_da_xoa");
  }

  // Tải danh sách thông báo về đơn hàng và tự động cập nhật nếu trạng thái đơn hàng thay đổi
  static Future<List<Map<String, dynamic>>> loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNotis = await _readMapList(prefs, _notiKey);
    final deletedIds = await _readStringList(prefs, _deletedNotiKey);
    final orders = await OrderController.loadCurrentUserOrders();

    var hasChanges = false;
    for (final order in orders) {
      final orderId = order["id"]?.toString() ?? "";
      final status = order["trangThai"]?.toString() ?? "pending";
      final notiId = "${orderId}_$status";

      if (deletedIds.contains(notiId)) continue;

      final title = statusTitle(status);
      final desc = statusDesc(
        status,
        orderId,
        order["lyDoHuy"]?.toString() ?? "",
      );
      final existingIndex = savedNotis.indexWhere((n) => n["id"] == notiId);
      if (existingIndex == -1) {
        savedNotis.add({
          "id": notiId,
          "orderId": orderId,
          "title": title,
          "desc": desc,
          "time": DateTime.now().toIso8601String(),
          "trangThai": status,
          "daDoc": false,
        });
        hasChanges = true;
      } else {
        final saved = savedNotis[existingIndex];
        if (saved["title"] != title ||
            saved["desc"] != desc ||
            saved["trangThai"] != status) {
          saved["title"] = title;
          saved["desc"] = desc;
          saved["trangThai"] = status;
          hasChanges = true;
        }
      }
    }

    savedNotis.sort((a, b) {
      final dateA =
          DateTime.tryParse(a["time"]?.toString() ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dateB =
          DateTime.tryParse(b["time"]?.toString() ?? "") ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    if (hasChanges) {
      await prefs.setString(_notiKey, jsonEncode(savedNotis));
    }
    return savedNotis;
  }

  // Xóa một thông báo ra khỏi danh sách hiển thị và lưu ID vào danh sách đã xóa để không hiển thị lại
  static Future<List<Map<String, dynamic>>> deleteNotification(
    List<Map<String, dynamic>> notifications,
    String notiId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = await _readStringList(prefs, _deletedNotiKey);
    if (!deletedIds.contains(notiId)) {
      deletedIds.add(notiId);
      await prefs.setString(_deletedNotiKey, jsonEncode(deletedIds));
    }

    final updated = notifications
        .where((n) => n["id"] != notiId)
        .map((n) => Map<String, dynamic>.from(n))
        .toList();
    await prefs.setString(_notiKey, jsonEncode(updated));
    return updated;
  }

  // Đánh dấu tất cả thông báo trong danh sách là đã đọc
  static Future<List<Map<String, dynamic>>> markAllRead(
    List<Map<String, dynamic>> notifications,
  ) async {
    final updated = notifications.map((n) {
      final item = Map<String, dynamic>.from(n);
      item["daDoc"] = true;
      return item;
    }).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notiKey, jsonEncode(updated));
    return updated;
  }

  // Đánh dấu một thông báo cụ thể theo ID là đã đọc
  static Future<List<Map<String, dynamic>>> markRead(
    List<Map<String, dynamic>> notifications,
    String notiId,
  ) async {
    final updated = notifications.map((n) {
      final item = Map<String, dynamic>.from(n);
      if (item["id"] == notiId) {
        item["daDoc"] = true;
      }
      return item;
    }).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notiKey, jsonEncode(updated));
    return updated;
  }

  // Tìm thông tin đơn hàng cụ thể theo ID trong danh sách đơn của người dùng hiện tại
  static Future<Map<String, dynamic>?> findOrder(String orderId) async {
    final orders = await OrderController.loadCurrentUserOrders();
    return orders
            .firstWhere(
              (o) => o["id"]?.toString() == orderId,
              orElse: () => <String, dynamic>{},
            )
            .isEmpty
        ? null
        : orders.firstWhere((o) => o["id"]?.toString() == orderId);
  }

  // Chuyển đổi trạng thái đơn hàng thành tiêu đề thông báo tiếng Việt tương ứng
  static String statusTitle(String status) {
    switch (status) {
      case "cancelled":
        return "Đơn hàng đã hủy";
      case "delivered":
        return "Đơn hàng đã giao";
      case "shipping":
        return "Đơn hàng đang giao";
      default:
        return "Đặt hàng thành công";
    }
  }

  // Tạo nội dung mô tả chi tiết thông báo bằng tiếng Việt dựa trên trạng thái đơn hàng
  static String statusDesc(String status, String orderId, String lyDoHuy) {
    switch (status) {
      case "cancelled":
        return lyDoHuy.isEmpty
            ? "Đơn hàng $orderId đã được hủy thành công."
            : "Đơn hàng $orderId đã được hủy. Lý do: $lyDoHuy";
      case "delivered":
        return "Đơn hàng $orderId đã được giao thành công. Cảm ơn bạn đã mua sắm tại Huy Hoàng Books!";
      case "shipping":
        return "Đơn hàng $orderId đang được vận chuyển đến bạn bởi đơn vị giao hàng.";
      default:
        return "Đơn hàng $orderId đã được ghi nhận và đang chờ cửa hàng xác nhận.";
    }
  }

  // Trả về nhãn trạng thái đơn hàng dạng tiếng Việt thân thiện
  static String statusLabel(String status) {
    switch (status) {
      case "pending":
        return "Chờ xác nhận";
      case "shipping":
        return "Đang giao";
      case "delivered":
        return "Đã giao";
      default:
        return "Đã hủy";
    }
  }

  // Hàm nội bộ để giải mã danh sách Map từ bộ nhớ SharedPreferences
  static Future<List<Map<String, dynamic>>> _readMapList(
    SharedPreferences prefs,
    String key,
  ) async {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  // Hàm nội bộ để giải mã danh sách String từ bộ nhớ SharedPreferences
  static Future<List<String>> _readStringList(
    SharedPreferences prefs,
    String key,
  ) async {
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded.cast<String>();
    } catch (_) {
      return [];
    }
  }
}
