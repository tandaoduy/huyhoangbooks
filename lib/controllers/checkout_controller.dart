import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/controller_book_store.dart';
import 'package:huyhoangbooks/controllers/giohang.dart';
import 'package:huyhoangbooks/controllers/local_data_controller.dart';
import 'package:huyhoangbooks/controllers/supabae_helper.dart';

class CheckoutController {
  CheckoutController(this.bookStoreController);

  final ControllerBookStore bookStoreController;

  // Lấy thông tin sách mới nhất từ Supabase và kiểm tra xem có đủ số lượng tồn kho hay không
  Future<Map<String, Book>> laySachMoiNhatVaKiemTraTonKho(
    List<GioHangItem> items,
  ) async {
    final booksMoiNhat = await BookSnapshot.getMapBook();

    for (final item in items) {
      final book = booksMoiNhat[item.bookId];
      if (book == null) {
        throw Exception("Có sản phẩm không còn tồn tại trong cửa hàng");
      }

      final tonKho = book.soLuong ?? 0;
      if (tonKho < item.soLuong) {
        throw Exception("${book.tenSach} chỉ còn $tonKho cuốn");
      }
    }

    return booksMoiNhat;
  }

  // Khấu trừ số lượng tồn kho của sách trên database sau khi đặt hàng thành công
  Future<void> truTonKhoSauKhiDatHang(
    List<GioHangItem> items,
    Map<String, Book> booksMoiNhat,
  ) async {
    for (final item in items) {
      final book = booksMoiNhat[item.bookId];
      if (book == null) continue;

      final soLuongSauKhiTru = (book.soLuong ?? 0) - item.soLuong;
      final soLuongMoi = soLuongSauKhiTru < 0 ? 0 : soLuongSauKhiTru;
      final updatedBook = await supabase
          .from('Book')
          .update({'soLuong': soLuongMoi})
          .eq('id', book.id)
          .select('id, soLuong')
          .maybeSingle();

      if (updatedBook == null) {
        throw Exception("Không tìm thấy sách ${book.tenSach} để trừ kho");
      }

      final soLuongDaLuu = _docSoLuong(updatedBook['soLuong']) ?? soLuongMoi;
      book.soLuong = soLuongDaLuu;
      bookStoreController.mapBooks[book.id]?.soLuong = soLuongDaLuu;
    }

    bookStoreController.update(["books", "gioHang"]);
  }

  // Lưu đơn hàng trực tiếp lên Supabase (hàm trống)
  Future<void> luuDonHang(Map<String, dynamic> order) async {
    // Lưu lên Supabase trực tiếp trong datHang
  }

  // Thực hiện quy trình đặt hàng: tạo đơn, tạo chi tiết đơn, cập nhật tồn kho và giỏ hàng
  Future<String> datHang({
    required List<GioHangItem> items,
    required String tenNguoiNhan,
    required String diaChi,
    required String sdt,
    required String ghiChu,
    required int tongTien,
    required String phuongThucThanhToan,
  }) async {
    if (items.isEmpty) {
      throw Exception("Vui lòng chọn sản phẩm trước khi đặt hàng");
    }

    if (diaChi.trim().isEmpty) {
      throw Exception("Vui lòng thêm địa chỉ nhận hàng trước khi đặt hàng");
    }

    if (!RegExp(r'^0\d{9}$').hasMatch(sdt.trim())) {
      throw Exception(
        "Số điện thoại phải gồm đúng 10 chữ số và bắt đầu bằng 0",
      );
    }

    final booksMoiNhat = await laySachMoiNhatVaKiemTraTonKho(items);
    final user = supabase.auth.currentUser;

    // 1. Thêm mới bản ghi vào bảng DonHang
    final donHangInsert = {
      'ngayDat': DateTime.now().toIso8601String(),
      'trangThai': 'pending',
      'tenNguoiNhan': tenNguoiNhan,
      'diaChi': diaChi.trim(),
      'sdt': sdt.trim(),
      'ghiChu': ghiChu.trim(),
      'tongTien': tongTien,
      'phuongThucThanhToan': phuongThucThanhToan,
    };

    final dhResponse = await supabase
        .from('DonHang')
        .insert(donHangInsert)
        .select('id')
        .single();

    final orderId = dhResponse['id'] as int;

    // 2. Thêm các bản ghi chi tiết đơn hàng vào bảng chiTietDon
    int? firstDetailId;
    for (final item in items) {
      final book = booksMoiNhat[item.bookId];
      if (book == null) continue;

      final detailInsert = <String, dynamic>{
        'soLuong': item.soLuong,
        'donGia': book.giaBan.toInt(),
        'BookId': book.id,
      };

      final detailResponse = await _insertChiTietDon(detailInsert, orderId);

      if (firstDetailId == null) {
        firstDetailId = detailResponse['id'] as int?;
      }
    }

    // 3. Liên kết ngược qua chTietDonHang nếu cột này tồn tại trên database
    if (firstDetailId != null) {
      try {
        await supabase
            .from('DonHang')
            .update({'chTietDonHang': firstDetailId})
            .eq('id', orderId);
      } catch (_) {}
    }
    await _saveOrderItemsSnapshot(orderId.toString(), items, booksMoiNhat);

    await truTonKhoSauKhiDatHang(items, booksMoiNhat);

    // Cập nhật số điện thoại và địa chỉ vào hồ sơ người dùng
    if (user != null) {
      try {
        await supabase
            .from('User')
            .update({
              'sdt': sdt.trim(),
              'diaChi': diaChi.trim(),
            })
            .eq('id', user.id);
      } catch (_) {}
      await bookStoreController.xoaSanPhamDaChonKhoiGioHang();
    }

    return orderId.toString();
  }

  // Tạo mã đơn hàng mới
  Future<String> taoMaDonHang() async {
    return '';
  }

  // Hàm nội bộ để chèn thông tin chi tiết đơn hàng (chiTietDon) tương thích với nhiều tên cột
  Future<Map<String, dynamic>> _insertChiTietDon(
    Map<String, dynamic> detailInsert,
    int orderId,
  ) async {
    try {
      return await supabase
          .from('chiTietDon')
          .insert({...detailInsert, 'DonHangId': orderId})
          .select('id')
          .single();
    } catch (_) {
      try {
        return await supabase
            .from('chiTietDon')
            .insert({...detailInsert, 'donHangId': orderId})
            .select('id')
            .single();
      } catch (_) {
        return await supabase
            .from('chiTietDon')
            .insert(detailInsert)
            .select('id')
            .single();
      }
    }
  }

  // Lấy địa chỉ giao hàng mặc định của người dùng từ lưu trữ cục bộ
  Future<Map<String, dynamic>?> layDiaChiMacDinh() async {
    final addresses = await LocalDataController.readList(
      LocalDataController.userKey("dia_chi"),
    );
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (item) => item['macDinh'] == true,
      orElse: () => addresses.first,
    );
  }

  // Lưu bản chụp ảnh (snapshot) danh sách sản phẩm trong đơn hàng xuống bộ nhớ máy cục bộ
  Future<void> _saveOrderItemsSnapshot(
    String orderId,
    List<GioHangItem> items,
    Map<String, Book> booksMoiNhat,
  ) async {
    final snapshots = await LocalDataController.readList(
      LocalDataController.userKey("order_items_snapshot"),
    );
    snapshots.removeWhere((item) => item["orderId"]?.toString() == orderId);

    snapshots.add({
      "orderId": orderId,
      "items": items.map((item) {
        final book = booksMoiNhat[item.bookId];
        return {
          "bookId": item.bookId,
          "tenSach": book?.tenSach ?? "Sách",
          "soLuong": item.soLuong,
          "giaBan": book?.giaBan.toInt() ?? 0,
          "anh": book?.anh ?? "",
        };
      }).toList(),
    });

    await LocalDataController.saveList(
      LocalDataController.userKey("order_items_snapshot"),
      snapshots,
    );
  }

  // Lấy phương thức thanh toán đã được lưu gần nhất của người dùng
  Future<String> layPhuongThucThanhToanDaLuu() async {
    final saved =
        await LocalDataController.readString(
          'checkout_payment_${LocalDataController.currentEmail}',
        ) ??
        'cod';
    if (saved == 'bank' || saved == 'zalopay') return 'momo';
    return saved;
  }

  // Lưu phương thức thanh toán được chọn xuống bộ nhớ máy
  Future<void> luuPhuongThucThanhToan(String value) async {
    await LocalDataController.saveString(
      'checkout_payment_${LocalDataController.currentEmail}',
      value,
    );
  }

  // Hàm nội bộ để phân tích và đọc số lượng sách dạng số nguyên
  int? _docSoLuong(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
