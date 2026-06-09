import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';

import 'package:huyhoangbooks/pages/page_don_hang.dart';
import 'package:huyhoangbooks/pages/page_dia_chi.dart';
import 'package:huyhoangbooks/pages/page_cai_dat_thong_bao.dart';
import 'package:huyhoangbooks/pages/page_bao_mat.dart';
import 'package:huyhoangbooks/pages/admin/page_admin.dart';

class PageCaNhan extends StatelessWidget {
  const PageCaNhan({super.key, required this.onSignedOut});

  final Future<void> Function() onSignedOut;

  Future<void> _kiemTraVaVaoAdmin(BuildContext context) async {
    final controller = Get.find<ControllerBookStore>();
    final user = AuthHelper.currentUser;
    if (user == null) {
      Get.snackbar("Lỗi", "Vui lòng đăng nhập trước");
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
      ),
    );

    try {
      final role = await controller.layVaiTroNguoiDung(user.id);

      if (context.mounted) Navigator.of(context).pop(); // Đóng loading

      if (role == 'admin') {
        Get.to(() => const PageAdmin());
      } else {
        if (!context.mounted) return;
        final updateRole = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Kích hoạt quyền Admin?"),
            content: const Text(
              "Tài khoản của bạn hiện tại chưa có quyền Admin. Bạn có muốn nâng cấp tài khoản này lên vai trò Admin để kiểm thử tính năng này không?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Hủy"),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Color(0xFFEF4D2F),
                ),
                child: const Text("Đồng ý nâng cấp"),
              ),
            ],
          ),
        );

        if (updateRole == true) {
          if (!context.mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
            ),
          );

          await controller.nangCapQuyenAdmin(user.id);

          if (context.mounted) Navigator.of(context).pop(); // Đóng loading

          Get.snackbar(
            "Thành công",
            "Đã nâng cấp tài khoản thành Admin",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          Get.to(() => const PageAdmin());
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      Get.snackbar("Lỗi", "Không thể kiểm tra vai trò: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileUiController = Get.put(ProfileUiController());
    final email = AuthHelper.displayEmail;
    final name = AuthHelper.displayName;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Container(
        color: Color(0xFFF6F7F9),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(left: 16, top: 14, right: 16, bottom: 12),
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GetBuilder<ProfileUiController>(
                    init: profileUiController,
                    builder: (profileUi) {
                      final avatarPath = profileUi.avatarPath;
                      return InkWell(
                        onTap: profileUi.pickAvatar,
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFE7E0),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: avatarPath != null && File(avatarPath).existsSync()
                              ? Image.file(File(avatarPath), fit: BoxFit.cover)
                              : Icon(
                            Icons.person_rounded,
                            color: Color(0xFFEF4D2F),
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Text(
                      "Hồ sơ",
                      style: TextStyle(
                        color: Color(0xFFEF4D2F),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ProfileSection(
              title: "Mua sắm",
              children: [
                _ProfileTile(
                  Icons.shopping_bag_outlined,
                  "Đơn hàng của tôi",
                      () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PageDonHang(),
                    ),
                  ),
                ),

                _ProfileTile(
                  Icons.location_on_outlined,
                  "Địa chỉ nhận hàng",
                      () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PageDiaChi()),
                  ),
                ),

              ],
            ),
            GetBuilder<ProfileUiController>(
              init: profileUiController,
              builder: (profileUi) {
                if (!profileUi.isAdmin) {
                  return SizedBox.shrink();
                }

                return Column(
                  children: [
                    SizedBox(height: 12),
                    _ProfileSection(
                      title: "Quản trị",
                      children: [
                        _ProfileTile(
                          Icons.admin_panel_settings_outlined,
                          "Quản trị hệ thống",
                              () => _kiemTraVaVaoAdmin(context),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 12),
            _ProfileSection(
              title: "Tài khoản",
              children: [
                _ProfileTile(
                  Icons.notifications_none_rounded,
                  "Cài đặt thông báo",
                      () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PageCaiDatThongBao(),
                    ),
                  ),
                ),
                _ProfileTile(
                  Icons.shield_outlined,
                  "Bảo mật & Quyền riêng tư",
                      () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PageBaoMat()),
                  ),
                ),
                _ProfileTile(
                  Icons.logout_rounded,
                  "Đăng xuất",
                      () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text(
                          "Xác nhận",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          "Bạn có chắc chắn muốn đăng xuất không?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text("Hủy"),
                          ),
                          FilledButton(
                            onPressed: () {
                              Get.back();
                              onSignedOut();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            child: const Text("Đăng xuất"),
                          ),
                        ],
                      ),
                    );
                  },
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 14, right: 16, bottom: 4),
            child: Text(
              title,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, indent: 68, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(
      this.icon,
      this.title,
      this.onTap, {
        this.textColor,
        this.iconColor,
      });
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? Color(0xFFEF4D2F)).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Color(0xFFEF4D2F),
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: textColor ?? Color(0xFF111827),
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 22,
        color: Color(0xFF9CA3AF),
      ),
      onTap: onTap,
    );
  }
}