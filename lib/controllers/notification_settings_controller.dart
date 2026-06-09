import 'package:huyhoangbooks/controllers/local_data_controller.dart';

// Mô hình lưu trữ các cấu hình bật/tắt nhận thông báo của người dùng
class NotificationSettings {
  const NotificationSettings({
    required this.promo,
    required this.orderStatus,
    required this.security,
  });

  final bool promo;
  final bool orderStatus;
  final bool security;

  // Sao chép đối tượng cấu hình và ghi đè một vài thuộc tính mới nếu có
  NotificationSettings copyWith({
    bool? promo,
    bool? orderStatus,
    bool? security,
  }) {
    return NotificationSettings(
      promo: promo ?? this.promo,
      orderStatus: orderStatus ?? this.orderStatus,
      security: security ?? this.security,
    );
  }
}

// Bộ điều khiển quản lý và lưu trữ cài đặt thông báo của người dùng
class NotificationSettingsController {
  NotificationSettingsController._();

  // Khóa định danh lưu cài đặt thông báo theo tài khoản người dùng
  static String get _key {
    return LocalDataController.userKey("notif_settings");
  }

  // Tải các cài đặt thông báo của người dùng từ bộ nhớ cục bộ
  static Future<NotificationSettings> load() async {
    return NotificationSettings(
      promo: await LocalDataController.readBool(
        "${_key}_promo",
        defaultValue: true,
      ),
      orderStatus: await LocalDataController.readBool(
        "${_key}_order",
        defaultValue: true,
      ),
      security: await LocalDataController.readBool(
        "${_key}_security",
        defaultValue: true,
      ),
    );
  }

  // Cập nhật một cấu hình cài đặt thông báo cụ thể (khuyến mãi, trạng thái đơn, bảo mật)
  static Future<NotificationSettings> update(
    NotificationSettings current,
    String type,
    bool value,
  ) async {
    await LocalDataController.saveBool("${_key}_$type", value);
    return switch (type) {
      "promo" => current.copyWith(promo: value),
      "order" => current.copyWith(orderStatus: value),
      "security" => current.copyWith(security: value),
      _ => current,
    };
  }

  // Khôi phục tất cả cài đặt thông báo về giá trị mặc định (bật hết)
  static Future<NotificationSettings> resetDefaults() async {
    const defaults = NotificationSettings(
      promo: true,
      orderStatus: true,
      security: true,
    );
    await LocalDataController.saveBool("${_key}_promo", defaults.promo);
    await LocalDataController.saveBool("${_key}_order", defaults.orderStatus);
    await LocalDataController.saveBool("${_key}_security", defaults.security);
    return defaults;
  }
}
