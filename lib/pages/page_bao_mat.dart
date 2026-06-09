import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/security_controller.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';

// Trang cài đặt bảo mật và quyền riêng tư của người dùng
class PageBaoMat extends StatefulWidget {
  const PageBaoMat({super.key});

  @override
  State<PageBaoMat> createState() => _PageBaoMatState();
}

class _PageBaoMatState extends State<PageBaoMat> {
  // Hiển thị modal thay đổi mật khẩu dạng Bottom Sheet
  Future<void> _dialogDoiMatKhau() async {
    final dialogTag = DateTime.now().microsecondsSinceEpoch.toString();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _DoiMatKhauSheet(dialogTag: dialogTag);
      },
    );
    Get.delete<SecurityDialogUiController>(tag: dialogTag);
  }

  // Xây dựng giao diện trang cài đặt Bảo mật & Quyền riêng tư
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Bảo mật & Quyền riêng tư",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                "THIẾT LẬP BẢO MẬT",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: _dialogDoiMatKhau,
                    leading: Icon(
                      Icons.vpn_key_outlined,
                      color: Color(0xFFEF4D2F),
                    ),
                    title: const Text(
                      "Đổi mật khẩu",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                "PHÁP LÝ & QUYỀN RIÊNG TƯ",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      _showMarkdownDialog(
                        "Điều khoản dịch vụ",
                        "Chào mừng bạn đến với Huy Hoàng Books! Khi sử dụng ứng dụng của chúng tôi, bạn đồng ý tuân thủ các điều khoản bao gồm việc không sao chép trái phép dữ liệu sách, cung cấp thông tin giao nhận chính xác và thanh toán đúng hạn cho các đơn hàng đã đặt mua.",
                      );
                    },
                    leading: Icon(
                      Icons.description_outlined,
                      color: Color(0xFFEF4D2F),
                    ),
                    title: const Text(
                      "Điều khoản dịch vụ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                    ),
                  ),
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFE5E7EB),
                  ),
                  ListTile(
                    onTap: () {
                      _showMarkdownDialog(
                        "Chính sách bảo mật",
                        "Chúng tôi cam kết bảo mật tuyệt đối thông tin cá nhân của bạn. Dữ liệu tài khoản, địa chỉ nhận hàng được mã hoá và chỉ sử dụng cho mục đích hoàn tất giao dịch mua sách tại Huy Hoàng Books. Chúng tôi không bao giờ chia sẻ thông tin của bạn cho bên thứ ba khi chưa có sự đồng ý.",
                      );
                    },
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: Color(0xFFEF4D2F),
                    ),
                    title: const Text(
                      "Chính sách quyền riêng tư",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị hộp thoại điều khoản và chính sách bảo mật dạng văn bản
  void _showMarkdownDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFFEF4D2F),
          ),
        ),
        content: Text(
          content,
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Đồng ý",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFEF4D2F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Lớp giao diện nội dung của Modal Bottom Sheet đổi mật khẩu
class _DoiMatKhauSheet extends StatefulWidget {
  final String dialogTag;
  const _DoiMatKhauSheet({required this.dialogTag});

  @override
  State<_DoiMatKhauSheet> createState() => _DoiMatKhauSheetState();
}

class _DoiMatKhauSheetState extends State<_DoiMatKhauSheet> {
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  // Khởi tạo các bộ điều khiển nhập liệu văn bản
  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  // Giải phóng các bộ điều khiển để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Xây dựng giao diện và xử lý sự kiện trong modal thay đổi mật khẩu
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SecurityDialogUiController>(
      init: SecurityDialogUiController(),
      tag: widget.dialogTag,
      builder: (dialogUi) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            top: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                const Text(
                  "Thay đổi mật khẩu",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: currentPasswordController,
                  obscureText: dialogUi.isCurrentObscured,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu hiện tại",
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        dialogUi.isCurrentObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: dialogUi.toggleCurrentPassword,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: dialogUi.isNewObscured,
                  decoration: InputDecoration(
                    labelText: "Mật khẩu mới",
                    prefixIcon: Icon(Icons.vpn_key_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        dialogUi.isNewObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: dialogUi.toggleNewPassword,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: dialogUi.isConfirmObscured,
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu mới",
                    prefixIcon: Icon(
                      Icons.check_circle_outline_rounded,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        dialogUi.isConfirmObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: dialogUi.toggleConfirmPassword,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                FilledButton(
                  // Xử lý gửi dữ liệu thay đổi mật khẩu lên Server
                  onPressed: dialogUi.isUpdating
                      ? null
                      : () async {
                    final current = currentPasswordController.text;
                    final fresh = newPasswordController.text;
                    final confirm = confirmPasswordController.text;

                    dialogUi.setUpdating(true);

                    try {
                      await SecurityController.changePassword(
                        currentPassword: current,
                        newPassword: fresh,
                        confirmPassword: confirm,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                      Get.snackbar(
                        "Thành công",
                        "Mật khẩu của bạn đã được cập nhật thành công.",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    } catch (e) {
                      Get.snackbar(
                        "Thất bại",
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    } finally {
                      dialogUi.setUpdating(false);
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFFEF4D2F),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: dialogUi.isUpdating
                      ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Cập nhật mật khẩu",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}