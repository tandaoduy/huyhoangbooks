import 'package:huyhoangbooks/controllers/address_controller.dart';
import 'package:huyhoangbooks/controllers/local_data_controller.dart';
import 'package:huyhoangbooks/controllers/supabae_helper.dart';

class OrderController {
  OrderController._();

  // Tải danh sách đơn hàng của người dùng hiện tại dựa trên số điện thoại đã lưu
  static Future<List<Map<String, dynamic>>> loadCurrentUserOrders() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final userProfile = await supabase
          .from('User')
          .select('sdt')
          .eq('id', user.id)
          .maybeSingle();
      var userSdt = userProfile?['sdt']?.toString() ?? '';

      // Dự phòng: Nếu sdt trên server trống, lấy từ địa chỉ lưu cục bộ dưới máy
      if (userSdt.isEmpty) {
        try {
          final localAddresses = await AddressController.loadAddresses();
          if (localAddresses.isNotEmpty) {
            final defaultAddr = localAddresses.firstWhere(
              (element) => element["macDinh"] == true,
              orElse: () => localAddresses.first,
            );
            final localSdt = defaultAddr["sdt"]?.toString() ?? '';
            if (localSdt.isNotEmpty) {
              userSdt = localSdt;
              // Đồng bộ lên server để lần sau không cần tải lại cục bộ
              await supabase
                  .from('User')
                  .update({'sdt': localSdt})
                  .eq('id', user.id);
            }
          }
        } catch (_) {}
      }

      if (userSdt.isEmpty) {
        return [];
      }

      final List<dynamic> donHangData = await supabase
          .from('DonHang')
          .select()
          .eq('sdt', userSdt)
          .order('ngayDat', ascending: false);

      final List<Map<String, dynamic>> orders = [];
      for (final dh in donHangData) {
        final orderMap = Map<String, dynamic>.from(dh);
        orderMap['id'] = dh['id'].toString();
        final details = await _loadOrderDetails(Map<String, dynamic>.from(dh));
        var orderItems = details.map((item) {
          final book = item['Book'] as Map<String, dynamic>?;
          return {
            'bookId': item['BookId']?.toString() ?? '',
            'tenSach': book?['tenSach'] ?? 'Sách',
            'soLuong': item['soLuong'] ?? 1,
            'giaBan': int.tryParse(item['donGia']?.toString() ?? '0') ?? 0,
            'anh': book?['anh'] ?? '',
          };
        }).toList();

        final snapshotItems = await _loadOrderItemsSnapshot(orderMap['id']);
        if (snapshotItems.length > orderItems.length) {
          orderItems = snapshotItems;
        }

        orderMap['items'] = orderItems;
        orders.add(orderMap);
      }
      return orders;
    } catch (e) {
      print("Lỗi tải đơn hàng: $e");
      return [];
    }
  }

  // Lưu danh sách đơn hàng của người dùng hiện tại (hàm trống không còn sử dụng)
  static Future<void> saveCurrentUserOrders(
    List<Map<String, dynamic>> orders,
  ) async {
    // Không cần lưu local nữa
  }

  // Hàm nội bộ tải danh sách chi tiết đơn hàng tương thích với cấu trúc DB
  static Future<List<dynamic>> _loadOrderDetails(
    Map<String, dynamic> order,
  ) async {
    final details = <dynamic>[];
    final orderId = order['id'];

    try {
      final data = await supabase
          .from('chiTietDon')
          .select('*, Book(*)')
          .eq('DonHangId', orderId);
      details.addAll(data);
    } catch (_) {}

    try {
      final data = await supabase
          .from('chiTietDon')
          .select('*, Book(*)')
          .eq('donHangId', orderId);
      for (final item in data) {
        final itemId = (item as Map)['id']?.toString();
        final exists = details.any((detail) {
          return (detail as Map)['id']?.toString() == itemId;
        });
        if (!exists) {
          details.add(item);
        }
      }
    } catch (_) {}

    if (details.isEmpty && order['chTietDonHang'] != null) {
      final item = await supabase
          .from('chiTietDon')
          .select('*, Book(*)')
          .eq('id', order['chTietDonHang'])
          .maybeSingle();
      if (item != null) {
        details.add(item);
      }
    }

    final tongTien = _readInt(order['tongTien']) ?? 0;
    if (order['chTietDonHang'] != null &&
        tongTien > 0 &&
        _sumDetails(details) < tongTien) {
      try {
        final adjacentDetails = await supabase
            .from('chiTietDon')
            .select('*, Book(*)')
            .gte('id', order['chTietDonHang'])
            .order('id', ascending: true)
            .limit(20);
        final rebuilt = <dynamic>[];
        var total = 0;
        for (final item in adjacentDetails) {
          rebuilt.add(item);
          total += _detailTotal(Map<String, dynamic>.from(item as Map));
          if (total >= tongTien) {
            break;
          }
        }
        if (rebuilt.length > details.length && total == tongTien) {
          return rebuilt;
        }
      } catch (_) {}
    }

    return details;
  }

  // Hàm nội bộ tính tổng số tiền của toàn bộ chi tiết đơn hàng
  static int _sumDetails(List<dynamic> details) {
    var total = 0;
    for (final detail in details) {
      total += _detailTotal(Map<String, dynamic>.from(detail as Map));
    }
    return total;
  }

  // Hàm nội bộ tính số tiền cho từng mặt hàng trong chi tiết đơn hàng
  static int _detailTotal(Map<String, dynamic> detail) {
    final soLuong = _readInt(detail['soLuong']) ?? 1;
    final donGia = _readInt(detail['donGia']) ?? 0;
    return soLuong * donGia;
  }

  // Hàm bổ trợ đọc số nguyên từ dữ liệu động
  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  // Hàm nội bộ tải bản chụp ảnh danh sách sản phẩm của đơn hàng từ lưu trữ cục bộ
  static Future<List<Map<String, dynamic>>> _loadOrderItemsSnapshot(
    String orderId,
  ) async {
    final snapshots = await LocalDataController.readList(
      LocalDataController.userKey("order_items_snapshot"),
    );
    final snapshot = snapshots.firstWhere(
      (item) => item["orderId"]?.toString() == orderId,
      orElse: () => <String, dynamic>{},
    );
    final items = snapshot["items"];
    if (items is! List) return [];
    return items.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  // Cập nhật trạng thái của một đơn hàng cụ thể thuộc người dùng hiện tại (ví dụ: hủy đơn hàng kèm lý do)
  static Future<void> updateCurrentUserOrderStatus(
    List<Map<String, dynamic>> orders,
    String orderId,
    String newStatus, {
    String? lyDoHuy,
  }) async {
    final updateData = <String, dynamic>{'trangThai': newStatus};
    if (lyDoHuy != null && lyDoHuy.trim().isNotEmpty) {
      updateData['lyDoHuy'] = lyDoHuy.trim();
    }

    try {
      final idInt = int.tryParse(orderId);
      if (idInt != null) {
        await supabase.from('DonHang').update(updateData).eq('id', idInt);
        for (final order in orders) {
          if (order["id"] == orderId) {
            order["trangThai"] = newStatus;
            if (lyDoHuy != null && lyDoHuy.trim().isNotEmpty) {
              order["lyDoHuy"] = lyDoHuy.trim();
            }
            break;
          }
        }
      }
    } catch (e) {
      print("Lỗi cập nhật trạng thái đơn hàng: $e");
    }
  }
}
