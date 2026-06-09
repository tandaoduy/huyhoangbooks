import 'package:huyhoangbooks/controllers/local_data_controller.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';

class SecurityController {
  SecurityController._();

  // Lấy khóa cấu hình bảo mật dựa trên tài khoản người dùng
  static String get _key {
    return LocalDataController.userKey("security_settings");
  }

  // Tải cấu hình sử dụng sinh trắc học (vân tay/khuôn mặt)
  static Future<bool> loadBiometrics() {
    return LocalDataController.readBool("${_key}_biometrics");
  }

  // Lưu cấu hình sử dụng sinh trắc học
  static Future<void> saveBiometrics(bool value) {
    return LocalDataController.saveBool("${_key}_biometrics", value);
  }

  // Yêu cầu đổi mật khẩu tài khoản thông qua AuthHelper
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return AuthHelper.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
