import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/address_controller.dart';
import 'package:huyhoangbooks/controllers/checkout_controller.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/notification_settings_controller.dart';
import 'package:huyhoangbooks/controllers/order_controller.dart';
import 'package:huyhoangbooks/controllers/order_notification_controller.dart';
import 'package:huyhoangbooks/controllers/profile_controller.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';
import 'package:huyhoangbooks/controllers/supabae_helper.dart';

// Bộ điều khiển trạng thái giao diện Trang chủ (quản lý tab đang hiển thị)
class HomeUiController extends GetxController {
  int currentIndex = 0;

  // Cập nhật tab index màn hình trang chủ đang hiển thị
  void selectIndex(int value) {
    currentIndex = value;
    update();
  }
}

// Bộ điều khiển trạng thái giao diện Cá nhân (ảnh đại diện, quyền admin)
class ProfileUiController extends GetxController {
  String? avatarPath;
  bool isAdmin = false;

  @override
  void onInit() {
    super.onInit();
    loadAvatar();
    checkAdminStatus();
  }

  // Tải đường dẫn ảnh đại diện của người dùng hiện tại
  Future<void> loadAvatar() async {
    avatarPath = await ProfileController.loadAvatarPath();
    update();
  }

  // Chọn ảnh mới từ thư viện làm ảnh đại diện
  Future<void> pickAvatar() async {
    final path = await ProfileController.pickAndSaveAvatar();
    if (path == null) return;
    avatarPath = path;
    update();
  }

  // Kiểm tra quyền quản trị của người dùng hiện tại để điều chỉnh giao diện
  Future<void> checkAdminStatus() async {
    isAdmin = await AuthHelper.isCurrentUserAdmin();
    update();
  }
}

// Bộ điều khiển giao diện Cài đặt thông báo
class NotificationSettingsUiController extends GetxController {
  bool notifPromo = true;
  bool notifOrderStatus = true;
  bool notifSecurity = true;
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // Tải cài đặt bật/tắt nhận thông báo từ lưu trữ cục bộ
  Future<void> load() async {
    isLoading = true;
    update();
    final settings = await NotificationSettingsController.load();
    _apply(settings);
    isLoading = false;
    update();
  }

  // Cập nhật một thiết lập thông báo (ví dụ: bật/tắt thông báo đơn hàng)
  Future<void> updateNotif(String type, bool value) async {
    final settings = await NotificationSettingsController.update(
      NotificationSettings(
        promo: notifPromo,
        orderStatus: notifOrderStatus,
        security: notifSecurity,
      ),
      type,
      value,
    );
    _apply(settings);
    update();
  }

  // Khôi phục cài đặt thông báo về giá trị mặc định ban đầu
  Future<void> resetDefaults() async {
    _apply(await NotificationSettingsController.resetDefaults());
    update();
  }

  // Hàm nội bộ áp dụng giá trị cấu hình thông báo vào biến trạng thái của UI
  void _apply(NotificationSettings settings) {
    notifPromo = settings.promo;
    notifOrderStatus = settings.orderStatus;
    notifSecurity = settings.security;
  }
}

// Bộ điều khiển trạng thái danh sách Đơn hàng của người dùng
class OrdersUiController extends GetxController {
  final bookStoreController = Get.find<ControllerBookStore>();
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  // Tải toàn bộ đơn hàng của người dùng
  Future<void> loadOrders() async {
    isLoading = true;
    update();
    orders = await OrderController.loadCurrentUserOrders();
    isLoading = false;
    update();
  }

  // Cập nhật trạng thái đơn hàng (ví dụ: người dùng hủy đơn hàng)
  Future<void> updateOrderStatus(
    String orderId,
    String newStatus, {
    String? lyDoHuy,
  }) async {
    await OrderController.updateCurrentUserOrderStatus(
      orders,
      orderId,
      newStatus,
      lyDoHuy: lyDoHuy,
    );
    update();
  }

  // Mua lại đơn hàng: thêm tất cả sách trong đơn hàng cũ vào giỏ hàng
  void reorder(Map<String, dynamic> order) {
    final items = order["items"] as List;
    for (var item in items) {
      final book = bookStoreController.mapBooks[item["bookId"]];
      if (book != null) {
        bookStoreController.themVaoGioHang(book);
      }
    }
  }
}

// Bộ điều khiển màn hình chọn Lý do hủy đơn hàng
class CancelOrderReasonUiController extends GetxController {
  CancelOrderReasonUiController(this.reasons)
    : selectedReason = reasons.isNotEmpty ? reasons.first : "";

  final List<String> reasons;
  String selectedReason;

  // Chọn một lý do hủy cụ thể từ danh sách
  void selectReason(String value) {
    selectedReason = value;
    update();
  }
}

// Bộ điều khiển màn hình quản lý Danh sách địa chỉ nhận hàng
class AddressUiController extends GetxController {
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  // Tải danh sách địa chỉ nhận hàng đã lưu của người dùng
  Future<void> loadAddresses() async {
    isLoading = true;
    update();
    addresses = await AddressController.loadAddresses();
    isLoading = false;
    update();
  }

  // Đồng bộ địa chỉ mặc định từ danh sách local lên bảng User ở database Supabase
  Future<void> _syncDefaultAddressToDatabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final defaultAddr = addresses.firstWhere(
      (element) => element["macDinh"] == true,
      orElse: () => addresses.isNotEmpty ? addresses.first : {},
    );

    if (defaultAddr.isEmpty) return;

    final parts = [
      defaultAddr['chiTiet'],
      defaultAddr['phuong'] ?? defaultAddr['xa'],
      defaultAddr['quan'],
      defaultAddr['tinh'],
    ].where((v) => v != null && v.toString().trim().isNotEmpty).map((v) {
      return v.toString().trim();
    }).toList();

    final formattedAddress = parts.join(', ');

    try {
      await supabase
          .from('User')
          .update({'diaChi': formattedAddress})
          .eq('id', user.id);
    } catch (_) {}
  }

  // Thêm mới hoặc cập nhật thông tin một địa chỉ nhận hàng
  Future<void> upsertAddress(
    Map<String, dynamic> address, {
    required bool isEdit,
  }) async {
    addresses = await AddressController.upsertAddress(
      addresses,
      address,
      isEdit: isEdit,
    );
    await _syncDefaultAddressToDatabase();
    update();
  }

  // Thiết lập một địa chỉ làm địa chỉ nhận hàng mặc định
  Future<void> setDefaultAddress(String id) async {
    addresses = await AddressController.setDefaultAddress(addresses, id);
    await _syncDefaultAddressToDatabase();
    update();
  }

  // Xóa địa chỉ nhận hàng chỉ định khỏi danh sách
  Future<void> deleteAddress(String id) async {
    addresses = await AddressController.deleteAddress(addresses, id);
    await _syncDefaultAddressToDatabase();
    update();
  }
}

// Bộ điều khiển trạng thái danh sách Thông báo đơn hàng
class OrderNotificationsUiController extends GetxController {
  List<Map<String, dynamic>> notifications = [];
  bool loading = true;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // Tải danh sách các thông báo của người dùng
  Future<void> loadNotifications() async {
    loading = true;
    update();
    notifications = await OrderNotificationController.loadNotifications();
    loading = false;
    update();
  }

  // Xóa một thông báo cụ thể ra khỏi danh sách hiển thị
  Future<void> deleteNotification(String notiId) async {
    notifications = await OrderNotificationController.deleteNotification(
      notifications,
      notiId,
    );
    update();
  }

  // Đánh dấu tất cả thông báo hiện có là đã đọc
  Future<void> markAllRead() async {
    notifications = await OrderNotificationController.markAllRead(
      notifications,
    );
    update();
  }

  // Đánh dấu một thông báo là đã đọc và trả về thông tin đơn hàng liên kết với thông báo đó
  Future<Map<String, dynamic>?> markReadAndFindOrder(
    Map<String, dynamic> item,
  ) async {
    final notiId = item["id"] as String;
    notifications = await OrderNotificationController.markRead(
      notifications,
      notiId,
    );
    update();
    return OrderNotificationController.findOrder(item["orderId"] as String);
  }
}

// Bộ điều khiển màn hình Thanh toán/Đặt hàng (Checkout)
class CheckoutUiController extends GetxController {
  CheckoutUiController(this.checkoutController);

  final CheckoutController checkoutController;
  final diaChiController = TextEditingController();
  final sdtController = TextEditingController();
  final ghiChuController = TextEditingController();
  String selectedPayment = 'cod';
  Map<String, dynamic>? selectedAddress;

  // Giải phóng các bộ điều khiển nhập liệu khi hủy controller
  @override
  void onClose() {
    diaChiController.dispose();
    sdtController.dispose();
    ghiChuController.dispose();
    super.onClose();
  }

  // Tải phương thức thanh toán đã lưu trước đây của người dùng
  Future<void> loadSavedPayment() async {
    selectedPayment = await checkoutController.layPhuongThucThanhToanDaLuu();
    update();
  }

  // Tự động lấy và điền thông tin địa chỉ giao hàng mặc định
  Future<void> fillDefaultAddress() async {
    applyAddress(await checkoutController.layDiaChiMacDinh());
  }

  // Áp dụng thông tin địa chỉ giao hàng cụ thể lên các ô nhập liệu
  void applyAddress(Map<String, dynamic>? address) {
    selectedAddress = address;
    if (address == null) {
      diaChiController.clear();
      sdtController.clear();
      update();
      return;
    }

    final parts =
        [
          address['chiTiet'],
          address['phuong'] ?? address['xa'],
          address['quan'],
          address['tinh'],
        ].where((v) => v != null && v.toString().trim().isNotEmpty).map((v) {
          return v.toString().trim();
        }).toList();

    diaChiController.text = parts.join(', ');
    sdtController.text = (address['sdt'] ?? '').toString();
    update();
  }

  // Chọn phương thức thanh toán mới và lưu cấu hình lại
  Future<void> selectPayment(String value) async {
    selectedPayment = value;
    update();
    await checkoutController.luuPhuongThucThanhToan(value);
  }
}

// Bộ điều khiển giao diện Modal đổi mật khẩu bảo mật
class SecurityDialogUiController extends GetxController {
  // Các controller quản lý văn bản nhập liệu mật khẩu
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Trạng thái ẩn/hiện mật khẩu và trạng thái đang cập nhật
  bool isCurrentObscured = true;
  bool isNewObscured = true;
  bool isConfirmObscured = true;
  bool isUpdating = false;

  // Bật/tắt ẩn hiện mật khẩu hiện tại
  void toggleCurrentPassword() {
    isCurrentObscured = !isCurrentObscured;
    update();
  }

  // Bật/tắt ẩn hiện mật khẩu mới
  void toggleNewPassword() {
    isNewObscured = !isNewObscured;
    update();
  }

  // Bật/tắt ẩn hiện xác nhận mật khẩu mới
  void toggleConfirmPassword() {
    isConfirmObscured = !isConfirmObscured;
    update();
  }

  // Cập nhật trạng thái đang xử lý đổi mật khẩu
  void setUpdating(bool value) {
    isUpdating = value;
    update();
  }

  // Giải phóng tài nguyên khi hủy controller
  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

// Bộ điều khiển hiệu ứng rê chuột (Hover) trên thẻ Sách
class BookCardHoverUiController extends GetxController {
  bool isHovered = false;

  // Cập nhật trạng thái rê chuột để tạo hiệu ứng nổi bật
  void setHovered(bool value) {
    if (isHovered == value) return;
    isHovered = value;
    update();
  }
}

// Bộ điều khiển quản lý trạng thái giao diện quản lý Đơn hàng của Admin
class AdminOrdersUiController extends GetxController {
  String selectedStatus = "pending";
  String orderStatusFilter = "Tất cả";

  // Thay đổi trạng thái đang được chọn của đơn hàng trong hộp thoại cập nhật
  void selectStatus(String value) {
    selectedStatus = value;
    update();
  }

  // Đặt bộ lọc hiển thị danh sách đơn hàng theo trạng thái
  void setOrderStatusFilter(String value) {
    orderStatusFilter = value;
    update();
  }

  // Thiết lập lại trạng thái được chọn của đơn hàng
  void resetSelectedStatus(String value) {
    selectedStatus = value;
  }
}

// Bộ điều khiển giao diện quản lý Sách của Admin (thêm, sửa, lọc sách)
class AdminBooksUiController extends GetxController {
  String searchQuery = "";
  File? imageFile;
  String? selectedCategoryId;

  // Cập nhật từ khóa tìm kiếm sách
  void setSearchQuery(String value) {
    searchQuery = value.trim().toLowerCase();
    update();
  }

  // Cập nhật tệp tin hình ảnh bìa sách được chọn
  void setImageFile(File? file) {
    imageFile = file;
    update();
  }

  // Chọn danh mục thể loại sách
  void setSelectedCategoryId(String? value) {
    selectedCategoryId = value;
    update();
  }

  // Thiết lập lại các thông tin trên biểu mẫu thêm/sửa sách
  void resetForm({required String? categoryId, File? image}) {
    selectedCategoryId = categoryId;
    imageFile = image;
  }
}
