import 'package:huyhoangbooks/controllers/supabae_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthHelper {
  AuthHelper._();

  // Lấy thông tin người dùng hiện tại đang đăng nhập từ Supabase
  static User? get currentUser => supabase.auth.currentUser;

  // Lấy email dạng chữ thường của người dùng hiện tại, mặc định là "guest" nếu chưa đăng nhập
  static String get currentEmail {
    return currentUser?.email?.toLowerCase() ?? "guest";
  }

  // Lấy email hiển thị của người dùng hiện tại, mặc định là "Chưa đăng nhập"
  static String get displayEmail {
    return currentUser?.email ?? "Chưa đăng nhập";
  }

  // Lấy tên hiển thị của người dùng (tách từ phần trước ký tự @ trong email), mặc định là "Người dùng"
  static String get displayName {
    return currentUser?.email?.split('@').first ?? "Người dùng";
  }

  // Kiểm tra xem người dùng đã đăng nhập hay chưa
  static bool get isSignedIn => currentUser != null;

  // Kiểm tra xem người dùng hiện tại có quyền Admin hay không
  static Future<bool> isCurrentUserAdmin() async {
    final user = currentUser;
    if (user == null) {
      return false;
    }

    try {
      final profile = await supabase
          .from('User')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return profile?['role']?.toString().toLowerCase() == 'admin';
    } catch (_) {
      return false;
    }
  }

  // Đăng xuất tài khoản người dùng hiện tại khỏi hệ thống
  static Future<void> signOut() {
    return supabase.auth.signOut();
  }

  // Cập nhật mật khẩu mới cho người dùng sau khi xác thực mật khẩu hiện tại
  static Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw Exception("Vui lòng đăng nhập trước khi đổi mật khẩu.");
    }

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      throw Exception("Vui lòng điền đầy đủ các trường mật khẩu.");
    }

    if (newPassword != confirmPassword) {
      throw Exception("Mật khẩu mới và xác nhận không khớp.");
    }

    if (newPassword.length < 6) {
      throw Exception("Mật khẩu mới phải dài tối thiểu 6 ký tự.");
    }

    await supabase.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
