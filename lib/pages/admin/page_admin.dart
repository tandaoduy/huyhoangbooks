import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';
import 'package:huyhoangbooks/pages/admin/page_admin_books.dart';
import 'package:huyhoangbooks/pages/admin/page_admin_categories.dart';
import 'package:huyhoangbooks/pages/admin/page_admin_orders.dart';
import 'package:huyhoangbooks/pages/page_home.dart';

class PageAdmin extends StatefulWidget {
  const PageAdmin({super.key});

  @override
  State<PageAdmin> createState() => _PageAdminState();
}

class _PageAdminState extends State<PageAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final bookStoreController = Get.find<ControllerBookStore>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Tải toàn bộ đơn hàng từ controller
    bookStoreController.taiTatCaDonHang();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ControllerBookStore>(
      id: "books",
      init: bookStoreController,
      builder: (controller) {
        return Scaffold(
          backgroundColor: Color(0xFFF9FAFB),
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Hệ thống Quản Trị",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout_rounded),
                tooltip: "Đăng xuất",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: const Text(
                        "Đăng xuất?",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFEF4D2F),
                        ),
                      ),
                      content: const Text(
                        "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản quản trị không?",
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Hủy",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        FilledButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await AuthHelper.signOut();
                              controller.xoaGioHang();
                              
                              if (Get.isRegistered<HomeUiController>()) {
                                Get.find<HomeUiController>().selectIndex(0);
                              }
                              
                              Get.offAll(() => const PageHome());
                              
                              Get.snackbar(
                                "Đã đăng xuất",
                                "Tài khoản của bạn đã được đăng xuất",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green,
                                colorText: Colors.white,
                              );
                            } catch (e) {
                              Get.snackbar(
                                "Đăng xuất thất bại",
                                "$e",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Color(0xFFEF4D2F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Đăng xuất",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFFEF4D2F),
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Color(0xFFEF4D2F),
              unselectedLabelColor: Colors.black54,
              indicatorColor: Color(0xFFEF4D2F),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: "Sách", icon: Icon(Icons.menu_book_rounded, size: 20)),
                Tab(text: "Thể loại", icon: Icon(Icons.category_outlined, size: 20)),
                Tab(text: "Đơn hàng", icon: Icon(Icons.receipt_long_rounded, size: 20)),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              PageAdminBooks(
                controller: controller,
              ),
              PageAdminCategories(
                controller: controller,
              ),
              PageAdminOrders(
                controller: controller,
              ),
            ],
          ),
        );
      },
    );
  }
}
