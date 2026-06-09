import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/controller_login.dart';
import 'package:huyhoangbooks/pages/admin/page_admin.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerLogin>(
      init: ControllerLogin(),
      builder: (controller) => _PageLoginContent(controller: controller),
    );
  }
}

class _PageLoginContent extends StatelessWidget {
  const _PageLoginContent({required this.controller});

  final ControllerLogin controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GetBuilder<ControllerLogin>(
          builder: (controller) {
            switch (controller.authMode) {
              case AuthMode.signIn:
                return const Text(
                  "Đăng nhập",
                  style: TextStyle(fontWeight: FontWeight.w900),
                );
              case AuthMode.signUp:
                return const Text(
                  "Đăng ký tài khoản",
                  style: TextStyle(fontWeight: FontWeight.w900),
                );
            }
          },
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF8F6),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFF4F0),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo thiết kế cao cấp
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Color(
                              0xFFEF4D2F,
                            ).withValues(alpha: 0.12),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(
                                0xFFEF4D2F,
                              ).withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.jpg',
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Color(0xFFEF4D2F),
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    const Text(
                      "Huy Hoàng Books",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    GetBuilder<ControllerLogin>(
                      builder: (controller) {
                        String description = "";
                        switch (controller.authMode) {
                          case AuthMode.signIn:
                            description =
                                "Đăng nhập để xem giỏ hàng và tài khoản của bạn";
                            break;
                          case AuthMode.signUp:
                            description =
                                "Tạo tài khoản mới để bắt đầu mua sắm";
                            break;
                        }
                        return Text(
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 28),

                    // Khung biểu mẫu bán trong suốt kèm đổ bóng
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GetBuilder<ControllerLogin>(
                        builder: (controller) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AnimatedSize(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  switchInCurve: Curves.easeIn,
                                  switchOutCurve: Curves.easeOut,
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: animation,
                                        axisAlignment: -1.0,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: _buildFormFields(context, controller),
                                ),
                              ),
                              SizedBox(height: 24),
                              // Nút gửi biểu mẫu chính
                              _buildSubmitButton(context, controller),
                            ],
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    // Chân trang chuyển đổi chế độ đăng nhập/đăng ký
                    _buildFooter(controller),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(BuildContext context, ControllerLogin controller) {
    switch (controller.authMode) {
      case AuthMode.signIn:
        return Column(
          key: ValueKey("signInFields"),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(controller),
            SizedBox(height: 16),
            _buildPasswordField(controller),
          ],
        );
      case AuthMode.signUp:
        return Column(
          key: ValueKey("signUpFields"),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailField(controller),
            SizedBox(height: 16),
            _buildPasswordField(controller),
            SizedBox(height: 16),
            _buildConfirmPasswordField(controller),
          ],
        );
    }
  }

  Widget _buildEmailField(ControllerLogin controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Địa chỉ Email",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          onChanged: controller.kiemTraEmailDangNhapKhiNhap,
          decoration: InputDecoration(
            hintText: "example@gmail.com",
            errorText: controller.emailErrorText,
            prefixIcon: Icon(Icons.email_outlined, color: Colors.black45),
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4D2F),
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(ControllerLogin controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mật khẩu",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.passwordController,
          obscureText: controller.isPasswordObscured,
          decoration: InputDecoration(
            hintText: "••••••••",
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.black45,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
              ),
              onPressed: controller.togglePasswordVisibility,
            ),
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4D2F),
                width: 2.0,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(ControllerLogin controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Xác nhận mật khẩu",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller.confirmPasswordController,
          obscureText: controller.isConfirmPasswordObscured,
          decoration: InputDecoration(
            hintText: "••••••••",
            prefixIcon: Icon(
              Icons.lock_outline_rounded,
              color: Colors.black45,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                controller.isConfirmPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
              ),
              onPressed: controller.toggleConfirmPasswordVisibility,
            ),
            filled: true,
            fillColor: Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFEF4D2F),
                width: 2.0,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, ControllerLogin controller) {
    final isEmailLoading = controller.isLoadingEmail;
    String btnText = "";
    switch (controller.authMode) {
      case AuthMode.signIn:
        btnText = "Đăng nhập";
        break;
      case AuthMode.signUp:
        btnText = "Đăng ký";
        break;
    }

    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Color(0xFFEF4D2F), Color(0xFFFF7A50)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFEF4D2F).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isEmailLoading
            ? null
            : () async {
                if (controller.authMode == AuthMode.signIn) {
                  final signedIn = await controller.dangNhapEmail();
                  if (signedIn && context.mounted) {
                    final isAdmin = await controller.laAdminHienTai();
                    if (!context.mounted) return;

                    if (isAdmin) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const PageAdmin()),
                      );
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  }
                } else if (controller.authMode == AuthMode.signUp) {
                  controller.dangKyEmail((email) {
                    Get.to(() => PageVerifyUser(email: email));
                  });
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: isEmailLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                btnText,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter(ControllerLogin controller) {
    return GetBuilder<ControllerLogin>(
      builder: (controller) {
        String question = "";
        String actionText = "";
        VoidCallback onTap;

        if (controller.authMode == AuthMode.signIn) {
          question = "Chưa có tài khoản?";
          actionText = "Đăng ký ngay";
          onTap = () => controller.switchMode(AuthMode.signUp);
        } else {
          question = "Đã có tài khoản?";
          actionText = "Đăng nhập";
          onTap = () => controller.switchMode(AuthMode.signIn);
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              question,
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 6),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFEF4D2F),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionText,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PageVerifyUser extends StatelessWidget {
  const PageVerifyUser({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Xác thực Email",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Nền chuyển màu và các đốm trang trí
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF7F5),
                  Color(0xFFFFFFFF),
                  Color(0xFFFFF2EE),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFEF4D2F).withValues(alpha: 0.08),
                    Color(0xFFEF4D2F).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0xFFEF4D2F).withValues(alpha: 0.05),
                    Color(0xFFEF4D2F).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFEF4D2F).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(
                            0xFFEF4D2F,
                          ).withValues(alpha: 0.12),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: Color(0xFFEF4D2F),
                      ),
                    ),
                    SizedBox(height: 24),
                    const Text(
                      "Mã xác thực OTP",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Vui lòng nhập mã xác thực gồm 6 chữ số đã được gửi đến\n$email",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 32),
                    Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GetBuilder<ControllerLogin>(
                        builder: (controller) {
                          final isVerifying = controller.isLoadingVerify;
                          return AbsorbPointer(
                            absorbing: isVerifying,
                            child: Column(
                              children: [
                                OtpTextField(
                                  numberOfFields: 6,
                                  borderColor: Color(0xFFE5E7EB),
                                  focusedBorderColor: Color(0xFFEF4D2F),
                                  showFieldAsBox: true,
                                  borderWidth: 2,
                                  fieldWidth: 42,
                                  borderRadius: BorderRadius.circular(12),
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onSubmit: (verificationCode) async {
                                    final success = await controller.xacThucOTP(
                                      email,
                                      verificationCode,
                                    );
                                    if (success) {
                                      Get.back();
                                      Get.back(result: true);
                                    }
                                  },
                                ),
                                isVerifying
                                    ? const Padding(
                                        padding: EdgeInsets.only(top: 28),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFFEF4D2F),
                                              ),
                                        ),
                                      )
                                    : SizedBox.shrink(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
