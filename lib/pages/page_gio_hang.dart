import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/giohang.dart';
import 'package:huyhoangbooks/pages/page_thanh_toan.dart';
import 'package:huyhoangbooks/helper/utils.dart';

class PageGioHang extends StatelessWidget {
  PageGioHang({super.key});

  final controller = Get.put(ControllerBookStore());

  Future<bool> _xacNhanXoaSanPham(
      BuildContext context,
      String tenSach,
      ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Xoá sản phẩm?"),
          content: Text("Bạn có muốn xoá \"$tenSach\" ra khỏi giỏ hàng không?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Huỷ"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Xoá"),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GetBuilder<ControllerBookStore>(
          id: "gioHang",
          init: controller,
          builder: (controller) => Text("Giỏ hàng (${controller.slMHGH})"),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
      ),
      body: SafeArea(
        child: GetBuilder<ControllerBookStore>(
          id: "gioHang",
          init: controller,
          builder: (controller) {
            if (controller.gioHang.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.remove_shopping_cart_outlined,
                      size: 82,
                      color: Color(0xFFEF4D2F),
                    ),
                    SizedBox(height: 14),
                    Text(
                      "Giỏ hàng đang trống",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Hãy thêm sách bạn yêu thích vào giỏ hàng",
                      style: TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        GioHangItem ghItem = controller.gioHang.values
                            .toList()[index];
                        Book book = controller.mapBooks[ghItem.bookId]!;

                        return Slidable(
                          key: ValueKey("cart_${book.id}"),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.22,
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  final dongY = await _xacNhanXoaSanPham(
                                    context,
                                    book.tenSach,
                                  );
                                  if (!dongY) return;
                                  controller.xoaSanPhamKhoiGioHang(book.id);
                                },
                                backgroundColor: Color(0xFFFFE4E6),
                                foregroundColor: Color(0xFFEF4D2F),
                                icon: Icons.delete_outline_rounded,
                                label: "Xóa",
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: ghItem.chon,
                                    activeColor: Color(0xFFEF4D2F),
                                    onChanged: (value) =>
                                        controller.chonSanPham(book.id, value),
                                  ),
                                  SizedBox(
                                    height: 84,
                                    width: 64,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: AnhSach(url: book.anh),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.tenSach,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                dinhDangTien(
                                                  book.giaBan * ghItem.soLuong,
                                                ),
                                                style: TextStyle(
                                                  color: Color(0xFFEF4D2F),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: TextButton(
                                                    onPressed: () async {
                                                      if (ghItem.soLuong <= 1) {
                                                        final dongY =
                                                        await _xacNhanXoaSanPham(
                                                          context,
                                                          book.tenSach,
                                                        );
                                                        if (!dongY) return;
                                                      }
                                                      controller.giamSoLuong(book.id);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                      MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: const Text("-"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 24,
                                                  child: Text(
                                                    "${ghItem.soLuong}",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 32,
                                                  height: 32,
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        controller.tangSoLuong(book.id),
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                      MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    child: const Text("+"),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                      SizedBox(height: 8),
                      itemCount: controller.slMHGH,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: controller.daChonTatCa,
                          activeColor: Color(0xFFEF4D2F),
                          onChanged: controller.chonTatCaSanPham,
                        ),
                        const Text(
                          "Tất cả",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Tổng tiền",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                dinhDangTien(controller.tongTien),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFFEF4D2F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          width: 112,
                          height: 44,
                          child: FilledButton(
                            onPressed: !controller.gioHang.values.any(
                                  (item) => item.chon,
                            )
                                ? null
                                : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PageThanhToan(controller: controller),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Color(0xFFEF4D2F),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Mua hàng",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}