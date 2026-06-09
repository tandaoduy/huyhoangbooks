import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';
import 'package:huyhoangbooks/pages/page_login.dart';
import 'package:huyhoangbooks/pages/admin/page_admin.dart';
import 'package:huyhoangbooks/pages/page_trang_chu.dart';
import 'package:huyhoangbooks/pages/page_thong_bao.dart';
import 'package:huyhoangbooks/pages/page_ca_nhan.dart';
import 'package:huyhoangbooks/pages/page_gio_hang.dart';

class PageHome extends StatefulWidget {
  const PageHome({super.key});

  @override
  State<PageHome> createState() => _PageHomeState();
}

class _PageHomeState extends State<PageHome> {
  final controller = Get.put(ControllerBookStore());
  final uiController = Get.put(HomeUiController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _moTrangAdminNeuCan();
    });
  }

  Future<void> _moTrangAdminNeuCan() async {
    if (await AuthHelper.isCurrentUserAdmin()) {
      if (!mounted) return;

      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PageAdmin()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const PageTrangChu(),
      const PageThongBao(),
      PageCaNhan(onSignedOut: _dangXuat),
    ];

    final List<PreferredSizeWidget?> appBars = [
      _buildHomeAppBar(),
      null,
      AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text("Cá nhân", style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1F2937),
        elevation: 0,
      ),
    ];

    return GetBuilder<HomeUiController>(
      init: uiController,
      builder: (ui) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: appBars[ui.currentIndex],
          body: screens[ui.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: ui.currentIndex,
            onTap: _chonTab,
            selectedItemColor: Color(0xFFEF4D2F),
            unselectedItemColor: Color(0xFF9CA3AF),
            backgroundColor: Colors.white,
            elevation: 8,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_filled),
                label: "Trang chủ",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_outlined),
                activeIcon: Icon(Icons.notifications_rounded),
                label: "Thông báo",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: "Cá nhân",
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      titleSpacing: 0,
      toolbarHeight: 74,
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F2937),
      title: Container(
        height: 48,
        margin: EdgeInsets.only(left: 16, top: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
        ),
        child: GetBuilder<ControllerBookStore>(
          id: "books",
          init: controller,
          builder: (controller) {
            return TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.timKiem(value),
              decoration: InputDecoration(
                hintText: "Tìm sách, tác giả, NXB",
                prefixIcon: Icon(Icons.search, color: Color(0xFF4B5563)),
                suffixIcon: controller.tuKhoa.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Color(0xFF4B5563)),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.timKiem("");
                  },
                )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 11),
              ),
            );
          },
        ),
      ),
      actions: [
        GetBuilder<ControllerBookStore>(
          id: "gioHang",
          init: controller,
          builder: (controller) {
            return GestureDetector(
              onTap: () => _moGioHang(),
              child: badges.Badge(
                showBadge: controller.slMHGH > 0,
                badgeStyle: const badges.BadgeStyle(
                  badgeColor: Color(0xFFEF4D2F),
                ),
                badgeContent: Text(
                  "${controller.slMHGH}",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFFEF4D2F),
                  size: 28,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 18),
      ],
    );
  }

  Future<bool> _yeuCauDangNhap() async {
    if (AuthHelper.isSignedIn) {
      if (await AuthHelper.isCurrentUserAdmin()) {
        if (mounted) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const PageAdmin()));
        }
        return false;
      }

      return true;
    }

    final daDangNhap = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (context) => const PageLogin()));

    if (await AuthHelper.isCurrentUserAdmin()) {
      return false;
    }

    return daDangNhap == true || AuthHelper.isSignedIn;
  }

  Future<void> _moGioHang() async {
    final wasSignedIn = AuthHelper.isSignedIn;
    final daDangNhap = await _yeuCauDangNhap();
    if (!daDangNhap || !mounted) {
      return;
    }

    if (!wasSignedIn) {
      uiController.selectIndex(0);
    } else {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => PageGioHang()));
    }
  }

  Future<void> _chonTab(int value) async {
    if (value == 1 && AuthHelper.isSignedIn) {
      if (Get.isRegistered<OrderNotificationsUiController>()) {
        await Get.find<OrderNotificationsUiController>().loadNotifications();
      }
    }

    if (value == 2) {
      final wasSignedIn = AuthHelper.isSignedIn;
      final daDangNhap = await _yeuCauDangNhap();
      if (!daDangNhap || !mounted) {
        return;
      }
      if (!wasSignedIn) {
        uiController.selectIndex(0);
        return;
      }
    }

    if (value != uiController.currentIndex) {
      controller.searchController.clear();
      controller.timKiem("");
    }

    uiController.selectIndex(value);
  }

  Future<void> _dangXuat() async {
    try {
      await AuthHelper.signOut();
      controller.xoaGioHang();

      if (!mounted) {
        return;
      }

      uiController.selectIndex(0);
      Get.snackbar(
        "Đã đăng xuất",
        "Tài khoản của bạn đã được đăng xuất",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      Get.snackbar(
        "Đăng xuất thất bại",
        "$e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}