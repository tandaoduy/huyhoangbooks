import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/giohang.dart';
import 'package:huyhoangbooks/helper/auth_helper.dart';
import 'package:huyhoangbooks/pages/page_login.dart';
import 'package:huyhoangbooks/pages/page_gio_hang.dart';
import 'package:huyhoangbooks/pages/page_thanh_toan.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageChiTiet extends StatelessWidget {
  PageChiTiet({super.key, required this.book});

  final Book book;
  final controller = Get.put(ControllerBookStore());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Trang sản phẩm"),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
        actions: [
          GetBuilder<ControllerBookStore>(
            id: "gioHang",
            init: controller,
            builder: (controller) {
              return GestureDetector(
                onTap: () => _moGioHangTrongChiTiet(context),
                child: badges.Badge(
                  showBadge: controller.slMHGH > 0,
                  badgeStyle: const badges.BadgeStyle(
                    badgeColor: Color(0xFFEF4D2F),
                  ),
                  badgeContent: Text(
                    "${controller.slMHGH}",
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  child: Icon(Icons.shopping_cart_outlined, size: 28),
                ),
              );
            },
          ),
          SizedBox(width: 18),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(aspectRatio: 1, child: AnhSach(url: book.anh)),
              _HopThongTinSach(book),
              _HopMoTaSach(book),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.only(left: 12, top: 9, right: 12, bottom: 12),
          color: Colors.white,
          child: Row(
            children: [

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await controller.themVaoGioHangKhiDaDangNhap(context, book);
                  },
                  icon: Icon(Icons.add_shopping_cart),
                  label: const Text("Thêm giỏ"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFEF4D2F),
                    side: const BorderSide(color: Color(0xFFEF4D2F)),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final daDangNhap = await _yeuCauDangNhapTuContext(context);
                    if (!daDangNhap || !context.mounted) {
                      return;
                    }

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PageThanhToan(
                          controller: controller,
                          itemsMuaNgay: [GioHangItem(bookId: book.id)],
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFFEF4D2F),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Mua ngay"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> _yeuCauDangNhapTuContext(BuildContext context) async {
  if (AuthHelper.isSignedIn) {
    return true;
  }

  final daDangNhap = await Navigator.of(
    context,
  ).push<bool>(MaterialPageRoute(builder: (context) => const PageLogin()));

  return daDangNhap == true || AuthHelper.isSignedIn;
}



Future<void> _moGioHangTrongChiTiet(BuildContext context) async {
  final daDangNhap = await _yeuCauDangNhapTuContext(context);
  if (!daDangNhap || !context.mounted) {
    return;
  }

  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => PageGioHang()));
}

class _HopThongTinSach extends StatelessWidget {
  const _HopThongTinSach(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.tenSach,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          SizedBox(height: 8),
          Text(
            book.tacGia ?? "Chưa có tác giả",
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Text(
                dinhDangTien(book.giaBan),
                style: TextStyle(
                  color: Color(0xFFEF4D2F),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (book.dangSale) ...[
                SizedBox(width: 10),
                Text(
                  dinhDangTien(book.giaGoc),
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    "SALE ${book.phanTramSale}%",
                    style: TextStyle(
                      color: Color(0xFFEF4D2F),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              RatingBarIndicator(
                rating: 4.6,
                itemBuilder: (context, index) =>
                Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 22,
              ),
              SizedBox(width: 10),
              const Text("100 đánh giá"),
            ],
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(Icons.business_outlined, book.nhaXuatBan ?? "NXB"),
              _InfoPill(
                Icons.calendar_month_outlined,
                "${book.namXuatBan ?? 0}",
              ),
              _InfoPill(
                Icons.inventory_2_outlined,
                "${book.soLuong ?? 0} cuốn",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HopMoTaSach extends StatelessWidget {
  const _HopMoTaSach(this.book);

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mô tả sản phẩm",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            (book.moTa ?? "").isEmpty
                ? "Sản phẩm chưa có mô tả trong Supabase."
                : book.moTa!,
            style: TextStyle(height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Color(0xFF667085)),
          SizedBox(width: 5),
          Text(text, style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}