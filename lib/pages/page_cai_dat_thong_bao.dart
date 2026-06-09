import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';

class PageCaiDatThongBao extends StatelessWidget {
  const PageCaiDatThongBao({super.key});

  @override
  Widget build(BuildContext context) {
    final uiController = Get.put(NotificationSettingsUiController());
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Cài đặt thông báo",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
      ),
      body: SafeArea(
        child: GetBuilder<NotificationSettingsUiController>(
          init: uiController,
          builder: (ui) => ui.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
                )
              : ListView(
                padding: EdgeInsets.all(16),
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      "HOẠT ĐỘNG MUA SẮM",
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
                        _buildSwitchTile(
                          ui,
                          "promo",
                          ui.notifPromo,
                          Icons.percent_rounded,
                          "Khuyến mãi & Ưu đãi",
                          "Nhận thông báo về voucher giảm giá và sự kiện hot hàng tuần",
                        ),
                        const Divider(
                          height: 1,
                          indent: 56,
                          color: Color(0xFFE5E7EB),
                        ),
                        _buildSwitchTile(
                          ui,
                          "order",
                          ui.notifOrderStatus,
                          Icons.local_shipping_outlined,
                          "Trạng thái đơn hàng",
                          "Cập nhật hành trình đơn hàng từ lúc xác nhận tới khi giao hàng thành công",
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                    child: Text(
                      "BẢO MẬT & HỆ THỐNG",
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
                        _buildSwitchTile(
                          ui,
                          "security",
                          ui.notifSecurity,
                          Icons.security_rounded,
                          "Bảo mật tài khoản",
                          "Cảnh báo khi phát hiện đăng nhập lạ hoặc khi bạn đổi mật khẩu",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 36),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        await ui.resetDefaults();
                        Get.snackbar(
                          "Đã khôi phục",
                          "Tất cả cài đặt thông báo đã được đưa về mặc định",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      icon: Icon(
                        Icons.settings_backup_restore_rounded,
                        size: 16,
                      ),
                      label: const Text("Khôi phục cài đặt gốc"),
                      style: TextButton.styleFrom(
                        foregroundColor: Color(0xFFEF4D2F),
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    NotificationSettingsUiController ui,
    String type,
    bool value,
    IconData icon,
    String title,
    String description,
  ) {
    return SwitchListTile(
      value: value,
      onChanged: (val) => ui.updateNotif(type, val),
      // Bỏ thuộc tính activeColor đã bị deprecated. Theme mặc định sẽ tự bôi màu cam đỏ
      title: Row(
        children: [
          Icon(icon, color: Color(0xFFEF4D2F), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(left: 34.0, top: 4.0),
        child: Text(
          description,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
