import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/checkout_controller.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/giohang.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';
import 'package:huyhoangbooks/pages/page_dia_chi.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageThanhToan extends StatefulWidget {
  const PageThanhToan({super.key, required this.controller, this.itemsMuaNgay});

  final ControllerBookStore controller;
  final List<GioHangItem>? itemsMuaNgay;

  @override
  State<PageThanhToan> createState() => _PageThanhToanState();
}

class _PageThanhToanState extends State<PageThanhToan> {
  late final CheckoutController checkoutController;
  late final CheckoutUiController uiController;

  @override
  void initState() {
    super.initState();
    checkoutController = CheckoutController(widget.controller);
    uiController = Get.put(
      CheckoutUiController(checkoutController),
      tag: hashCode.toString(),
    );
    _dienDiaChiMacDinh();
    _taiPaymentSaved();
  }

  Future<void> _taiPaymentSaved() async {
    await uiController.loadSavedPayment();
  }

  Future<void> _dienDiaChiMacDinh() async {
    await uiController.fillDefaultAddress();
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Color(0xFF6B7280),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildPaymentTile({
    required String value,
    required Widget leading,
    required String title,
    String? subtitle,
  }) {
    final selected = uiController.selectedPayment == value;
    return GestureDetector(
      onTap: () async {
        await uiController.selectPayment(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFFFF1F0) : Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? Color(0xFFEF4D2F) : Color(0xFFE5E7EB),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            leading,
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: selected
                          ? Color(0xFFEF4D2F)
                          : Color(0xFF1F2937),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? Color(0xFFEF4D2F) : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Color(0xFFEF4D2F)
                      : Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _walletIcon(String type) {
    if (type == 'momo') {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(0xFFAE006E),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: const Text(
          "mo",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            height: 0.9,
          ),
        ),
      );
    } else {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Color(0xFF059669),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.payments_outlined,
          color: Colors.white,
          size: 20,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final items =
        widget.itemsMuaNgay ??
            controller.gioHang.values.where((item) => item.chon).toList();
    final tongThanhToan = items.fold<int>(0, (tong, item) {
      final book = controller.mapBooks[item.bookId];
      return tong + ((book?.giaBan ?? 0) * item.soLuong).toInt();
    });

    final user = AuthHelper.currentUser;
    final displayName =
        uiController.selectedAddress?['ten'] as String? ??
            user?.userMetadata?['display_name'] as String? ??
            user?.email?.split('@').first ??
            'Khách hàng';

    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSectionLabel('ĐỊA CHỈ NHẬN HÀNG'),
          GetBuilder<CheckoutUiController>(
            init: uiController,
            builder: (ui) {
              final addressDisplayName =
                  ui.selectedAddress?['ten'] as String? ?? displayName;

              return _buildCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFFEF4D2F),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                addressDisplayName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(width: 8),
                              if (ui.sdtController.text.isNotEmpty)
                                Text(
                                  ui.sdtController.text,
                                  style: TextStyle(
                                    color: Color(0xFF4B5563),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            ui.diaChiController.text.isNotEmpty
                                ? ui.diaChiController.text
                                : 'Chưa có địa chỉ mặc định',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final selected = await Navigator.of(context)
                            .push<Map<String, dynamic>>(
                          MaterialPageRoute(
                            builder: (_) =>
                            const PageDiaChi(isSelectionMode: true),
                          ),
                        );
                        if (selected != null) {
                          ui.applyAddress(selected);
                        } else {
                          await _dienDiaChiMacDinh();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Color(0xFFEF4D2F),
                      ),
                      child: const Text(
                        'Thay đổi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _buildSectionLabel('SẢN PHẨM (${items.length})'),
          _buildCard(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final item = entry.value;
                final book = controller.mapBooks[item.bookId];
                if (book == null) return SizedBox.shrink();
                final isLast = entry.key == items.length - 1;
                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 58,
                              height: 76,
                              child: AnhSach(url: book.anh),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.tenSach,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                SizedBox(
                                  width: double.infinity,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Số lượng: x${item.soLuong}',
                                            style: TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                            '  ${dinhDangTien((book.giaBan * item.soLuong).toInt())}',
                                            style: TextStyle(
                                              color: Color(0xFFEF4D2F),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      softWrap: false,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFF3F4F6),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          _buildSectionLabel('GHI CHÚ'),
          _buildCard(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: uiController.ghiChuController,
              maxLines: 2,
              style: TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ghi chú cho người bán (không bắt buộc)...',
                hintStyle: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildSectionLabel('PHƯƠNG THỨC THANH TOÁN'),
          GetBuilder<CheckoutUiController>(
            init: uiController,
            builder: (ui) => _buildCard(
              child: Column(
                children: [
                  _buildPaymentTile(
                    value: 'cod',
                    leading: _walletIcon('cod'),
                    title: 'Thanh toán khi nhận hàng (COD)',
                    subtitle: 'Trả tiền mặt khi nhận hàng',
                  ),
                  _buildPaymentTile(
                    value: 'momo',
                    leading: _walletIcon('momo'),
                    title: 'Ví điện tử MoMo',
                    subtitle: 'Thanh toán nhanh bằng tài khoản MoMo',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildCard(
            child: Column(
              children: [
                _buildPriceRow('Tạm tính:', dinhDangTien(tongThanhToan)),
                SizedBox(height: 6),
                _buildPriceRow(
                  'Phí vận chuyển:',
                  'Miễn phí',
                  valueColor: Color(0xFF059669),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFFF3F4F6)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      dinhDangTien(tongThanhToan),
                      style: TextStyle(
                        color: Color(0xFFEF4D2F),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng cộng',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dinhDangTien(tongThanhToan),
                    style: TextStyle(
                      color: Color(0xFFEF4D2F),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    try {
                      final tenNguoiNhan =
                          uiController.selectedAddress?['ten'] as String? ??
                              displayName;
                      final newOrderId = await checkoutController.datHang(
                        items: items,
                        tenNguoiNhan: tenNguoiNhan,
                        diaChi: uiController.diaChiController.text,
                        sdt: uiController.sdtController.text,
                        ghiChu: uiController.ghiChuController.text,
                        tongTien: tongThanhToan,
                        phuongThucThanhToan: uiController.selectedPayment,
                      );

                      if (widget.itemsMuaNgay == null) {
                        controller.xoaSanPhamDaChonKhoiGioHang();
                      }
                      if (Get.isRegistered<OrderNotificationsUiController>()) {
                        await Get.find<OrderNotificationsUiController>()
                            .loadNotifications();
                      }

                      Get.snackbar(
                        'Đặt hàng thành công',
                        'Đơn hàng $newOrderId đã được ghi nhận',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    } catch (e) {
                      Get.snackbar(
                        'Đặt hàng thất bại',
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                      );
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFFEF4D2F),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Đặt hàng ngay',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Color(0xFF1F2937),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
