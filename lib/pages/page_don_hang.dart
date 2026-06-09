import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageDonHang extends StatefulWidget {
  const PageDonHang({super.key});

  @override
  State<PageDonHang> createState() => _PageDonHangState();
}

class _PageDonHangState extends State<PageDonHang> {
  final uiController = Get.put(OrdersUiController());

  @override
  void initState() {
    super.initState();
    uiController.loadOrders();
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus, {
    String? lyDoHuy,
  }) async {
    await uiController.updateOrderStatus(orderId, newStatus, lyDoHuy: lyDoHuy);
    if (Get.isRegistered<OrderNotificationsUiController>()) {
      await Get.find<OrderNotificationsUiController>().loadNotifications();
    }

    Get.snackbar(
      newStatus == "cancelled" ? "Đã huỷ đơn" : "Cập nhật thành công",
      newStatus == "cancelled"
          ? "Đơn hàng đã được huỷ bỏ"
          : "Đã cập nhật trạng thái đơn hàng",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _xacNhanHuyDon(String orderId) async {
    const lyDoCoSan = [
      "Tôi muốn thay đổi địa chỉ giao hàng",
      "Tôi đặt nhầm sản phẩm",
      "Tôi không còn nhu cầu mua nữa",
      "Lý do khác",
    ];

    final lyDoKhacController = TextEditingController();
    final reasonUiTag = "cancel-order-$orderId";

    final lyDo = await showDialog<String>(
      context: context,
      builder: (context) {
        return GetBuilder<CancelOrderReasonUiController>(
          init: CancelOrderReasonUiController(lyDoCoSan),
          tag: reasonUiTag,
          builder: (reasonUi) {
            final chonLyDoKhac = reasonUi.selectedReason == lyDoCoSan.last;

            return AlertDialog(
              title: const Text("Lý do hủy đơn hàng"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Bạn vui lòng chọn lý do hủy đơn hàng này.",
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    for (final lyDoItem in lyDoCoSan)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          reasonUi.selectedReason == lyDoItem
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: reasonUi.selectedReason == lyDoItem
                              ? Color(0xFFEF4D2F)
                              : Colors.black26,
                        ),
                        title: Text(
                          lyDoItem,
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () => reasonUi.selectReason(lyDoItem),
                      ),
                    if (chonLyDoKhac) ...[
                      SizedBox(height: 8),
                      TextField(
                        controller: lyDoKhacController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Nhập lý do hủy",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFEF4D2F),
                              width: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Không hủy"),
                ),
                FilledButton(
                  onPressed: () {
                    final result = chonLyDoKhac
                        ? lyDoKhacController.text.trim()
                        : reasonUi.selectedReason;
                    if (result.isEmpty) {
                      Get.snackbar(
                        "Thiếu lý do",
                        "Vui lòng nhập lý do hủy đơn hàng",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.orangeAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    Navigator.of(context).pop(result);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      lyDoKhacController.dispose();
    });

    if (lyDo != null && lyDo.trim().isNotEmpty) {
      await _updateOrderStatus(orderId, "cancelled", lyDoHuy: lyDo);
    }
  }

  Future<void> _datLaiDonHang(Map<String, dynamic> order) async {
    uiController.reorder(order);
    Get.snackbar(
      "Đã thêm vào giỏ hàng",
      "Đã thêm lại các sản phẩm vào giỏ hàng của bạn.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFFEF4D2F),
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        appBar: AppBar(
          title: const Text(
            "Đơn hàng của tôi",
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFFEF4D2F),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFFEF4D2F),
            unselectedLabelColor: Color(0xFF9CA3AF),
            indicatorColor: Color(0xFFEF4D2F),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: [
              Tab(text: "Chờ XN"),
              Tab(text: "Đang giao"),
              Tab(text: "Đã giao"),
              Tab(text: "Đã hủy"),
            ],
          ),
        ),
        body: SafeArea(
          child: GetBuilder<OrdersUiController>(
            init: uiController,
            builder: (ui) => ui.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
                  )
                : TabBarView(
                    children: [
                      _buildOrderList("pending"),
                      _buildOrderList("shipping"),
                      _buildOrderList("delivered"),
                      _buildOrderList("cancelled"),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList(String status) {
    // Lọc các đơn hàng theo trạng thái bằng vòng lặp đơn giản
    List<Map<String, dynamic>> filteredOrders = [];
    for (var o in uiController.orders) {
      if (o["trangThai"] == status) {
        filteredOrders.add(o);
      }
    }

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == "pending"
                  ? Icons.hourglass_empty_rounded
                  : status == "shipping"
                  ? Icons.local_shipping_outlined
                  : status == "delivered"
                  ? Icons.task_alt_rounded
                  : Icons.cancel_presentation_outlined,
              size: 72,
              color: Colors.black26,
            ),
            SizedBox(height: 16),
            Text(
              "Không có đơn hàng nào ở mục này",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(14),
      itemCount: filteredOrders.length,
      separatorBuilder: (context, index) => SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final orderId = order["id"] as String;
        final items = order["items"] as List;
        final tongTien = order["tongTien"] as int;
        final date =
            DateTime.tryParse(order["ngayDat"] ?? "") ?? DateTime.now();
        final formattedDate =
            "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PageChiTietDonHang(
                  order: order,
                  statusLabel: _statusLabel(status),
                ),
              ),
            );
          },
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mã đơn: $orderId",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Ngày đặt: $formattedDate",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF3F4F6)),
                  // Hiển thị danh sách sản phẩm trong đơn
                  for (var item in items)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 50,
                              height: 66,
                              child: _buildItemImage(item["anh"]),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["tenSach"] ?? "Sách",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Số lượng: x${item["soLuong"]}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  dinhDangTien(item["giaBan"] as int),
                                  style: TextStyle(
                                    color: Color(0xFFEF4D2F),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 12, color: Color(0xFFF3F4F6)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Tổng số tiền:",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      Text(
                        dinhDangTien(tongTien),
                        style: TextStyle(
                          color: Color(0xFFEF4D2F),
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                  if (status == "pending" || status == "delivered") ...[
                    const Divider(height: 24, color: Color(0xFFF3F4F6)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status == "pending")
                          OutlinedButton(
                            onPressed: () => _xacNhanHuyDon(orderId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "Hủy đơn hàng",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        if (status == "delivered")
                          FilledButton.icon(
                            onPressed: () => _datLaiDonHang(order),
                            icon: Icon(Icons.refresh_rounded, size: 16),
                            label: const Text(
                              "Mua lại",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: Color(0xFFEF4D2F),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case "pending":
        bgColor = Color(0xFFFEF3C7);
        textColor = Color(0xFFD97706);
        label = "Chờ xác nhận";
        break;
      case "shipping":
        bgColor = Color(0xFFDBEAFE);
        textColor = Color(0xFF2563EB);
        label = "Đang giao";
        break;
      case "delivered":
        bgColor = Color(0xFFD1FAE5);
        textColor = Color(0xFF059669);

        label = "Đã giao";
        break;
      default:
        bgColor = Color(0xFFF3F4F6);
        textColor = Color(0xFF4B5563);
        label = "Đã hủy";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status) {
      case "pending":
        return "Chờ xác nhận";
      case "shipping":
        return "Đang giao";
      case "delivered":
        return "Đã giao";
      default:
        return "Đã hủy";
    }
  }

  Widget _buildItemImage(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Color(0xFFEDEDED),
        child: Icon(Icons.book, color: Colors.black26),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Color(0xFFEDEDED),
        child: Icon(Icons.broken_image, color: Colors.black26),
      ),
    );
  }
}

class PageChiTietDonHang extends StatelessWidget {
  const PageChiTietDonHang({
    super.key,
    required this.order,
    required this.statusLabel,
  });

  final Map<String, dynamic> order;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final items = order["items"] as List? ?? [];
    final date = DateTime.tryParse(order["ngayDat"] ?? "") ?? DateTime.now();
    final formattedDate =
        "${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    final tongTien = order["tongTien"] as int? ?? 0;
    final tenNguoiNhan = (order["tenNguoiNhan"] ?? "").toString();
    final sdt = (order["sdt"] ?? "").toString();
    final diaChi = (order["diaChi"] ?? "").toString();
    final ghiChu = (order["ghiChu"] ?? "").toString();
    final lyDoHuy = (order["lyDoHuy"] ?? "").toString();

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Chi tiết đơn hàng",
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
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mã đơn: ${order["id"]}",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      _statusBadge(statusLabel),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Ngày đặt: $formattedDate",
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (lyDoHuy.isNotEmpty) ...[
                    SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF1F0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Color(0xFFFFCCC7)),
                      ),
                      child: Text(
                        "Lý do hủy: $lyDoHuy",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12),
            _title("Thông tin giao hàng"),
            _sectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tenNguoiNhan.isNotEmpty)
                    _infoRow(Icons.person_outline, "Người nhận", tenNguoiNhan),
                  if (sdt.isNotEmpty)
                    _infoRow(Icons.phone_outlined, "Số điện thoại", sdt),
                  if (diaChi.isNotEmpty)
                    _infoRow(Icons.location_on_outlined, "Địa chỉ", diaChi),
                  if (ghiChu.isNotEmpty)
                    _infoRow(Icons.note_alt_outlined, "Ghi chú", ghiChu),
                ],
              ),
            ),
            SizedBox(height: 12),
            _title("Sản phẩm đã mua"),
            _sectionCard(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _itemRow(Map<String, dynamic>.from(items[i] as Map)),
                    if (i != items.length - 1)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFF3F4F6),
                      ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 12),
            _sectionCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Tổng thanh toán",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  Text(
                    dinhDangTien(tongTien),
                    style: TextStyle(
                      color: Color(0xFFEF4D2F),
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
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

  Widget _title(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }

  Widget _sectionCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: Color(0xFFEF4D2F)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemRow(Map<String, dynamic> item) {
    final soLuong = item["soLuong"] as int? ?? 1;
    final giaBan = item["giaBan"] as int? ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 58,
              height: 76,
              child: _image(item["anh"]?.toString()),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item["tenSach"]?.toString() ?? "Sách",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text(
                  "Số lượng: x$soLuong",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  dinhDangTien(giaBan * soLuong),
                  style: TextStyle(
                    color: Color(0xFFEF4D2F),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Color(0xFFEDEDED),
        child: Icon(Icons.book, color: Colors.black26),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Color(0xFFEDEDED),
        child: Icon(Icons.broken_image, color: Colors.black26),
      ),
    );
  }

  Widget _statusBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color(0xFFDBEAFE),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Color(0xFF2563EB),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
