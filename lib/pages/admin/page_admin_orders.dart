import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageAdminOrders extends StatefulWidget {
  final ControllerBookStore controller;

  const PageAdminOrders({super.key, required this.controller});

  @override
  State<PageAdminOrders> createState() => _PageAdminOrdersState();

  // Hộp thoại hiển thị chi tiết đơn hàng và cho phép cập nhật trạng thái đơn
  static void showChiTietDonHang(
    BuildContext context,
    ControllerBookStore controller,
    Map<String, dynamic> order,
  ) {
    final orderId = order["id"]?.toString() ?? "";
    final dateStr = order["ngayDat"]?.toString() ?? "";
    final currentStatus = order["trangThai"]?.toString() ?? "pending";
    final notes = order["ghiChu"]?.toString() ?? "";
    final addr = order["diaChi"]?.toString() ?? "";
    final sdt = order["sdt"]?.toString() ?? "";
    final customer = order["tenNguoiNhan"]?.toString() ?? "Người dùng";
    final total = _readInt(order["tongTien"]) ?? 0;
    final items = order["items"] as List? ?? [];

    final date = DateTime.tryParse(dateStr);
    final formattedDate = date != null
        ? "${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}"
        : "";

    String selectedStatus = currentStatus;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.all(16),
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chi tiết đơn $orderId",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Thời gian đặt: $formattedDate",
                            style: TextStyle(fontSize: 11, color: Colors.black45),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 6),
                          const Text(
                            "THÔNG TIN KHÁCH HÀNG",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Tên người nhận: $customer",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 4),
                          Text("Số điện thoại: $sdt", style: TextStyle(fontSize: 13)),
                          SizedBox(height: 4),
                          Text("Địa chỉ giao hàng: $addr", style: TextStyle(fontSize: 13)),
                          if (notes.isNotEmpty) ...[
                            SizedBox(height: 4),
                            Text(
                              "Ghi chú: $notes",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          SizedBox(height: 14),
                          const Text(
                            "SẢN PHẨM ĐÃ ĐẶT",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(height: 6),
                          ...items.map((item) {
                            final mapItem = Map<String, dynamic>.from(item as Map);
                            final bookTitle = mapItem["tenSach"]?.toString() ?? "";
                            final bookQty = _readInt(mapItem["soLuong"]) ?? 1;
                            final bookPrice = _readInt(mapItem["giaBan"]) ?? 0;
                            final bookImg = mapItem["anh"]?.toString() ?? "";

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 6.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      color: Colors.grey.shade100,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: bookImg.isNotEmpty
                                        ? Image.network(
                                            bookImg,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.broken_image,
                                              size: 16,
                                            ),
                                          )
                                        : Icon(Icons.book, size: 16),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bookTitle,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "x$bookQty - ${dinhDangTien(bookPrice)}",
                                          style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    dinhDangTien(bookPrice * bookQty),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "TỔNG TIỀN THANH TOÁN",
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                              Text(
                                dinhDangTien(total),
                                style: TextStyle(
                                  color: Color(0xFFEF4D2F),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          const Text(
                            "TRẠNG THÁI ĐƠN HÀNG",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black45,
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedStatus,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: "pending", child: Text("Chờ xác nhận")),
                                  DropdownMenuItem(value: "shipping", child: Text("Đang giao")),
                                  DropdownMenuItem(value: "delivered", child: Text("Đã giao")),
                                  DropdownMenuItem(value: "cancelled", child: Text("Đã hủy")),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setBottomSheetState(() {
                                      selectedStatus = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: FilledButton(
                              onPressed: () async {
                                Get.back();

                                Get.dialog(
                                  const Center(
                                    child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
                                  ),
                                  barrierDismissible: false,
                                );

                                try {
                                  await controller.capNhatTrangThaiDonHang(order, selectedStatus);
                                  Get.back();

                                  Get.snackbar(
                                    "Thành công",
                                    "Đã cập nhật trạng thái đơn hàng",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                } catch (e) {
                                  Get.back();
                                  Get.snackbar(
                                    "Lỗi",
                                    "Không thể cập nhật trạng thái: $e",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.redAccent,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Color(0xFFEF4D2F),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                "CẬP NHẬT TRẠNG THÁI",
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}

class _PageAdminOrdersState extends State<PageAdminOrders> {
  final uiController = Get.put(AdminOrdersUiController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AdminOrdersUiController>(
      init: uiController,
      builder: (ui) {
        final filteredOrders = widget.controller.ordersList.where((o) {
          if (ui.orderStatusFilter == "Tất cả") return true;
          return o['trangThai'] == ui.orderStatusFilter;
        }).toList();

        return Column(
      children: [
        // Lọc trạng thái đơn hàng
        Container(
          height: 48,
          color: Colors.white,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _buildFilterChip("Tất cả"),
              _buildFilterChip("pending", label: "Chờ xác nhận"),
              _buildFilterChip("shipping", label: "Đang giao"),
              _buildFilterChip("delivered", label: "Đã giao"),
              _buildFilterChip("cancelled", label: "Đã hủy"),
            ],
          ),
        ),
        Expanded(
          child: filteredOrders.isEmpty
              ? const Center(child: Text("Không có đơn hàng nào ở trạng thái này"))
              : ListView.separated(
                  padding: EdgeInsets.all(14),
                  itemCount: filteredOrders.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    final orderId = order["id"]?.toString() ?? "";
                    final dateStr = order["ngayDat"]?.toString() ?? "";
                    final tong = _readInt(order["tongTien"]) ?? 0;
                    final trangThai = order["trangThai"]?.toString() ?? "pending";
                    final items = order["items"] as List? ?? [];
                    final count = items.length;

                    final date = DateTime.tryParse(dateStr);
                    final formattedDate = date != null
                        ? "${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.day}/${date.month}/${date.year}"
                        : "";

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFE5E7EB)),
                      ),
                      child: InkWell(
                        onTap: () => PageAdminOrders.showChiTietDonHang(
                          context,
                          widget.controller,
                          order,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    orderId,
                                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                                  ),
                                  _buildStatusBadge(trangThai),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Thời gian đặt: $formattedDate",
                                style: TextStyle(color: Colors.black45, fontSize: 11),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Khách hàng: ${order['tenNguoiNhan'] ?? 'Người dùng'}",
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Sản phẩm: $count món",
                                    style: TextStyle(color: Colors.black54, fontSize: 12),
                                  ),
                                  Text(
                                    dinhDangTien(tong),
                                    style: TextStyle(
                                      color: Color(0xFFEF4D2F),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
        );
      },
    );
  }

  Widget _buildFilterChip(String value, {String? label}) {
    final text = label ?? value;
    final isSelected = uiController.orderStatusFilter == value;

    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        selected: isSelected,
        label: Text(text),
        selectedColor: Color(0xFFEF4D2F),
        backgroundColor: Color(0xFFF3F4F6),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: isSelected ? Color(0xFFEF4D2F) : Colors.transparent),
        onSelected: (selected) {
          if (selected) {
            uiController.setOrderStatusFilter(value);
          }
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    String text;

    switch (status) {
      case "cancelled":
        color = Colors.redAccent;
        bgColor = Color(0xFFFFEBEB);
        text = "Đã hủy";
        break;
      case "delivered":
        color = Colors.green;
        bgColor = Color(0xFFE6F9F0);
        text = "Đã giao";
        break;
      case "shipping":
        color = Colors.blue;
        bgColor = Color(0xFFE8F4FD);
        text = "Đang giao";
        break;
      default:
        color = Color(0xFFEF4D2F);
        bgColor = Color(0xFFFFF2E6);
        text = "Chờ xác nhận";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900),
      ),
    );
  }

  int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
