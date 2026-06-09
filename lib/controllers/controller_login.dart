import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/supabae_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthMode { signIn, signUp }

class ControllerLogin extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  AuthMode authMode = AuthMode.signIn;
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  bool isLoadingEmail = false;
  bool isLoadingVerify = false;
  String? emailErrorText;

  Timer? _emailCheckTimer;
  bool _daDongTrangDangNhap = false;

  // Gọi khi khởi tạo controller để đặt lại form đăng nhập/đăng ký
  @override
  void onInit() {
    super.onInit();
    resetForm();
  }

  // Giải phóng tài nguyên và hủy các bộ điều khiển nhập liệu
  @override
  void onClose() {
    _emailCheckTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Thiết lập lại toàn bộ giá trị nhập liệu và các biến trạng thái về mặc định
  void resetForm() {
    _emailCheckTimer?.cancel();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    authMode = AuthMode.signIn;
    isPasswordObscured = true;
    isConfirmPasswordObscured = true;
    isLoadingEmail = false;
    isLoadingVerify = false;
    emailErrorText = null;
    _daDongTrangDangNhap = false;
  }

  // Bật/tắt trạng thái ẩn/hiện mật khẩu
  void togglePasswordVisibility() {
    isPasswordObscured = !isPasswordObscured;
    update();
  }

  // Bật/tắt trạng thái ẩn/hiện mật khẩu xác nhận
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured = !isConfirmPasswordObscured;
    update();
  }

  // Chuyển đổi qua lại giữa chế độ Đăng nhập và Đăng ký
  void switchMode(AuthMode mode) {
    authMode = mode;
    emailErrorText = null;
    passwordController.clear();
    confirmPasswordController.clear();
    update();
  }

  // Làm sạch chuỗi email nhập vào (xóa khoảng trắng, dấu nháy kép, nháy đơn)
  String _layEmailSach() {
    return emailController.text
        .trim()
        .replaceAll("'", "")
        .replaceAll('"', "")
        .toLowerCase();
  }

  // Kiểm tra tính hợp lệ định dạng của email bằng RegExp
  bool _emailHopLe(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  // Kiểm tra sự tồn tại của email đăng nhập theo thời gian thực (de-bounce) khi đang gõ
  void kiemTraEmailDangNhapKhiNhap(String value) {
    _emailCheckTimer?.cancel();
    emailErrorText = null;
    update();

    if (authMode != AuthMode.signIn) {
      return;
    }

    final email = value
        .trim()
        .replaceAll("'", "")
        .replaceAll('"', "")
        .toLowerCase();
    if (email.isEmpty || !_emailHopLe(email)) {
      return;
    }

    _emailCheckTimer = Timer(const Duration(milliseconds: 600), () async {
      try {
        if (!await _emailDaTonTai(email)) {
          emailErrorText = "Tài khoản không tồn tại";
          update();
        }
      } catch (_) {
        emailErrorText = null;
        update();
      }
    });
  }

  // Hàm nội bộ kiểm tra email đã tồn tại trong database Supabase chưa
  Future<bool> _emailDaTonTai(String email) async {
    final user = await supabase
        .from('User')
        .select('id')
        .eq('email', email)
        .maybeSingle();
    return user != null;
  }

  // Kiểm tra xem người dùng hiện tại đang đăng nhập có phải là admin hay không
  Future<bool> laAdminHienTai() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return false;
    }

    final profile = await supabase
        .from('User')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return profile?['role']?.toString().toLowerCase() == 'admin';
  }

  // Hàm nội bộ đồng bộ thông tin hồ sơ của người dùng (từ Supabase Auth) xuống bảng User
  Future<void> _dongBoHoSoUser(User user) async {
    final email = user.email?.toLowerCase();
    final hoTen = user.userMetadata?['full_name'] ?? email?.split('@').first;
    final daCoHoSo = await supabase
        .from('User')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (daCoHoSo == null) {
      final hoSoTheoEmail = email == null
          ? null
          : await supabase
                .from('User')
                .select('id')
                .eq('email', email)
                .maybeSingle();

      if (hoSoTheoEmail != null) {
        await supabase
            .from('User')
            .update({'id': user.id, 'email': email, 'hoTen': hoTen})
            .eq('email', email!);
        return;
      }

      await supabase.from('User').insert({
        'id': user.id,
        'email': email,
        'hoTen': hoTen,
        'diaChi': '',
        'sdt': '',
        'role': 'customer',
      });
      return;
    }

    await supabase
        .from('User')
        .update({'email': email, 'hoTen': hoTen})
        .eq('id', user.id);
  }

  // Thực hiện chức năng đăng nhập tài khoản bằng email và mật khẩu
  Future<bool> dangNhapEmail() async {
    final email = _layEmailSach();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Lỗi nhập liệu",
        "Vui lòng điền đầy đủ Email và Mật khẩu",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return false;
    }

    if (!_emailHopLe(email)) {
      Get.snackbar(
        "Email không hợp lệ",
        "Nhập email dạng admin@gmail.com, không thêm dấu nháy hoặc khoảng trắng",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return false;
    }

    isLoadingEmail = true;
    update();
    try {
      if (!await _emailDaTonTai(email)) {
        emailErrorText = "Tài khoản không tồn tại";
        update();
        return false;
      }
      emailErrorText = null;
      update();

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _dongBoHoSoUser(response.user!);
        return true;
      }
      return false;
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      final hienThiLoi = message.contains('invalid login credentials')
          ? "Mật khẩu không đúng"
          : message.contains('email not confirmed')
          ? "Tài khoản chưa xác thực email, vui lòng nhập mã OTP trước"
          : e.message;
      Get.snackbar(
        message.contains('invalid login credentials')
            ? "Sai mật khẩu"
            : "Đăng nhập thất bại",
        hienThiLoi,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi không xác định: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoadingEmail = false;
      update();
    }
  }

  // Thực hiện chức năng đăng ký tài khoản mới bằng email và mật khẩu
  Future<void> dangKyEmail(Function(String email) onSignUpSuccess) async {
    final email = _layEmailSach();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        "Lỗi nhập liệu",
        "Vui lòng điền đầy đủ các trường thông tin",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (!_emailHopLe(email)) {
      Get.snackbar(
        "Email không hợp lệ",
        "Nhập email dạng admin@gmail.com, không thêm dấu nháy hoặc khoảng trắng",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        "Lỗi nhập liệu",
        "Mật khẩu xác nhận không khớp",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoadingEmail = true;
    update();
    try {
      if (await _emailDaTonTai(email)) {
        Get.snackbar(
          "Tài khoản đã tồn tại",
          "Email này đã được đăng ký, vui lòng đăng nhập",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orangeAccent,
          colorText: Colors.white,
        );
        return;
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        Get.snackbar(
          "Đăng ký thành công",
          "Mã OTP đã được gửi đến email của bạn",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        onSignUpSuccess(email);
      }
    } on AuthException catch (e) {
      Get.snackbar(
        "Đăng ký thất bại",
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Lỗi",
        "Đã xảy ra lỗi: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoadingEmail = false;
      update();
    }
  }

  // Xác thực mã OTP (signup) gửi qua email để kích hoạt tài khoản
  Future<bool> xacThucOTP(String email, String verificationCode) async {
    isLoadingVerify = true;
    update();
    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: verificationCode,
        email: email,
      );

      if (response.session != null) {
        if (response.user != null) {
          await _dongBoHoSoUser(response.user!);
        }
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        "Xác thực thất bại",
        "Mã OTP không hợp lệ hoặc đã hết hạn: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoadingVerify = false;
      update();
    }
  }

  // Đóng giao diện đăng nhập và trả về giá trị thành công cho context cha
  void dongTrangDangNhap() {
    if (_daDongTrangDangNhap) {
      return;
    }
    _daDongTrangDangNhap = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = Get.key.currentState;
      if (navigator != null && navigator.canPop()) {
        Get.back(result: true);
      }
    });
  }
}
