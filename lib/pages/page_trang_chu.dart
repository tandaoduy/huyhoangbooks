import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/pages/page_chi_tiet.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageTrangChu extends StatelessWidget {
  const PageTrangChu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ControllerBookStore>();
    return SafeArea(
      child: GetBuilder<ControllerBookStore>(
        id: "books",
        init: controller,
        builder: (controller) {
          if (controller.dangTai) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.loi != null) {
            return _KhungLoi(
              message: controller.loi!,
              onPressed: () => controller.taiSach(),
            );
          }

          var list = controller.danhSachHienThi;

          return RefreshIndicator(
            onRefresh: () => controller.taiSach(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _DanhMuc(controller: controller)),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(left: 14, top: 18, right: 14, bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Gợi ý hôm nay",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFEF4D2F),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(left: 16, right: 16, bottom: 18),
                  sliver: list.isEmpty
                      ? const SliverToBoxAdapter(child: _KhungRong())
                      : SliverGrid.extent(
                    maxCrossAxisExtent: 230,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.58,
                    children: list.map((e) {
                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PageChiTiet(book: e),
                          ),
                        ),
                        child: _TheSach(
                          book: e,
                          onAdd: () async {
                            await controller.themVaoGioHangKhiDaDangNhap(
                              context,
                              e,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DanhMuc extends StatelessWidget {
  const _DanhMuc({required this.controller});

  final ControllerBookStore controller;

  @override
  Widget build(BuildContext context) {
    var list = ["Tất cả", ...controller.dsDanhMuc];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 14, top: 8, right: 14, bottom: 10),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var ten = list[index];
          var dangChon = controller.danhMucDangChon == ten;

          return ChoiceChip(
            selected: dangChon,
            showCheckmark: false,
            label: Text(ten),
            labelPadding: EdgeInsets.symmetric(horizontal: 8),
            selectedColor: Color(0xFFEF4D2F),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: dangChon ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w800,
            ),
            side: BorderSide(
              color: dangChon ? Color(0xFFEF4D2F) : Colors.black12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            onSelected: (value) => controller.chonDanhMuc(ten),
          );
        },
        separatorBuilder: (context, index) => SizedBox(width: 8),
        itemCount: list.length,
      ),
    );
  }
}

class _TheSach extends StatefulWidget {
  const _TheSach({required this.book, required this.onAdd});

  final Book book;
  final VoidCallback onAdd;

  @override
  State<_TheSach> createState() => _TheSachState();
}

class _TheSachState extends State<_TheSach> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isHovered = true;
      }),
      onExit: (_) => setState(() {
        _isHovered = false;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0.0, _isHovered ? -6.0 : 0.0, 0.0),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: _isHovered ? 12 : 4,
          shadowColor: _isHovered
              ? Color(0xFFEF4D2F).withValues(alpha: 0.15)
              : Colors.black.withValues(alpha: 0.08),
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isHovered ? Color(0xFFEF4D2F) : Color(0xFFE5E7EB),
              width: _isHovered ? 2.0 : 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(child: AnhSach(url: widget.book.anh)),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          widget.book.tenTheLoai ?? "Sách",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFEF4D2F),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 9, right: 10, bottom: 4),
                child: Text(
                  widget.book.tenSach,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, height: 1.25),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.book.tacGia ?? "Chưa có tác giả",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, top: 8, right: 10, bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dinhDangTien(widget.book.giaBan),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFEF4D2F),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (widget.book.dangSale)
                            Text(
                              dinhDangTien(widget.book.giaGoc),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.book.dangSale) ...[
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          "-${widget.book.phanTramSale}%",
                          style: TextStyle(
                            color: Color(0xFFEF4D2F),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Color(0xFFEF4D2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: widget.onAdd,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.add_shopping_cart,
                          size: 18,
                          color: Colors.white,
                        ),
                        tooltip: "Thêm giỏ hàng",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _KhungLoi extends StatelessWidget {
  const _KhungLoi({required this.message, required this.onPressed});

  final String message;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 46, color: Color(0xFFEF4D2F)),
            SizedBox(height: 12),
            const Text(
              "Không tải được dữ liệu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            SizedBox(height: 12),
            FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: Color(0xFFEF4D2F),
              ),
              child: const Text("Thử lại"),
            ),
          ],
        ),
      ),
    );
  }
}

class _KhungRong extends StatelessWidget {
  const _KhungRong();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 42,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 10),
            Text(
              "Không có sản phẩm phù hợp",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}