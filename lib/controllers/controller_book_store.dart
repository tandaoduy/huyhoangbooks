import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/book.dart';
import 'package:huyhoangbooks/controllers/giohang.dart';
import 'package:huyhoangbooks/controllers/supabae_helper.dart';
import 'package:huyhoangbooks/pages/page_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ControllerBookStore extends GetxController {
  Map<String, Book> mapBooks = {};
  Map<String, TheLoaiSach> mapTheLoai = {};
  Map<String, GioHangItem> gioHang = {};

  List<Book> danhSachHienThi = [];
  List<String> dsDanhMuc = [];
  String danhMucDangChon = "Tất cả";
  String tuKhoa = "";
  final searchController = TextEditingController();
  bool dangTai = true;
  String? loi;
  StreamSubscription<AuthState>? _authSubscription;

  // Các biến của Admin
  List<Map<String, dynamic>> ordersList = [];
  int totalOrders = 0;
  int revenue = 0;

  // Kiểm tra trạng thái đăng nhập của người dùng
  bool get daDangNhap => supabase.auth.currentUser != null;

  // Lấy số lượng mặt hàng trong giỏ hàng
  int get slMHGH => daDangNhap ? gioHang.length : 0;

  // Tính tổng tiền các sản phẩm được chọn trong giỏ hàng
  int get tongTien {
    int tong = 0;
    for (var item in gioHang.values) {
      if (item.chon) {
        tong += (mapBooks[item.bookId]?.giaBan ?? 0) * item.soLuong;
      }
    }
    return tong;
  }

  // Lấy danh sách các sản phẩm đang được chọn trong giỏ hàng
  List<GioHangItem> get sanPhamDaChon =>
      gioHang.values.where((item) => item.chon).toList();

  // Kiểm tra xem tất cả sản phẩm trong giỏ hàng đã được chọn hay chưa
  bool get daChonTatCa =>
      gioHang.isNotEmpty && gioHang.values.every((item) => item.chon);

  // Khởi tạo controller, đăng ký lắng nghe sự kiện tìm kiếm và thay đổi trạng thái đăng nhập
  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) async {
      if (data.event == AuthChangeEvent.signedOut) {
        xoaGioHang();
      } else if (data.event == AuthChangeEvent.signedIn) {
        await _taiGioHangNguoiDung();
      }
    });
    taiDuLieu();
  }

  // Hàm nội bộ xử lý khi từ khóa tìm kiếm thay đổi
  void _onSearchChanged() {
    final cleanText = searchController.text.trim().toLowerCase();
    if (tuKhoa != cleanText) {
      tuKhoa = cleanText;
      if (tuKhoa.isEmpty) {
        danhMucDangChon = "Tất cả";
      }
      _locSach();
      update(["books"]);
    }
  }

  // Giải phóng tài nguyên khi hủy controller
  @override
  void onClose() {
    _authSubscription?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  // Tải toàn bộ dữ liệu sách, thể loại, giỏ hàng và đơn hàng từ database Supabase
  Future<void> taiDuLieu() async {
    dangTai = true;
    loi = null;
    update(["books"]);

    try {
      mapBooks = await getMapBook();
      try {
        mapTheLoai = await getMapTheLoaiSach();
      } catch (_) {
        mapTheLoai = {};
      }
      _ganTenTheLoai();
      _taoDanhMuc();
      _locSach();
      await _taiGioHangNguoiDung();
      await taiTatCaDonHang();
    } catch (e) {
      loi = e.toString();
    }

    dangTai = false;
    update(["books"]);
  }

  // Tải lại dữ liệu sách (bí danh của hàm taiDuLieu)
  Future<void> taiSach() async {
    await taiDuLieu();
  }

  // Hàm nội bộ tự động gán tên thể loại sách từ ID thể loại tương ứng
  void _ganTenTheLoai() {
    for (var book in mapBooks.values) {
      var idTheLoai = book.theLoaiSach;
      if (idTheLoai != null && mapTheLoai.containsKey(idTheLoai)) {
        book.tenTheLoai = mapTheLoai[idTheLoai]!.tenTheLoai;
      }
    }
  }

  // Hàm nội bộ tự động phân tích và tạo danh sách danh mục thể loại sách không trùng lặp
  void _taoDanhMuc() {
    dsDanhMuc =
        mapBooks.values
            .map((e) => e.tenTheLoai ?? "")
            .where((e) => e.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
  }

  // Thực hiện tìm kiếm sách theo từ khóa người dùng nhập vào
  void timKiem(String value) {
    if (searchController.text != value) {
      searchController.text = value;
    } else {
      tuKhoa = value.trim().toLowerCase();
      if (tuKhoa.isEmpty) {
        danhMucDangChon = "Tất cả";
      }
      _locSach();
      update(["books"]);
    }
  }

  // Cập nhật danh mục thể loại sách đang được chọn để hiển thị
  void chonDanhMuc(String value) {
    danhMucDangChon = value;
    _locSach();
    update(["books"]);
  }

  // Hàm nội bộ lọc danh sách sách hiển thị theo từ khóa tìm kiếm và danh mục đang chọn
  void _locSach() {
    danhSachHienThi = mapBooks.values.where((book) {
      var tenTheLoai = book.tenTheLoai ?? "";
      var dungTuKhoa =
          tuKhoa.isEmpty ||
          book.tenSach.toLowerCase().contains(tuKhoa) ||
          (book.tacGia ?? "").toLowerCase().contains(tuKhoa);
      var dungDanhMuc =
          danhMucDangChon == "Tất cả" || tenTheLoai == danhMucDangChon;
      return dungTuKhoa && dungDanhMuc;
    }).toList();
  }

  // Thêm một cuốn sách vào giỏ hàng hoặc tăng số lượng lên 1 nếu đã có trong giỏ
  Future<void> themVaoGioHang(Book book) async {
    if (!daDangNhap) {
      return;
    }

    if (gioHang.containsKey(book.id)) {
      final item = gioHang[book.id]!;
      item.soLuong++;
      update(["gioHang"]);
      final result = await GioHangSnapshot.capNhat(item);
      if (result == 0) {
        item.soLuong--;
        update(["gioHang"]);
      }
    } else {
      final item = GioHangItem(
        bookId: book.id,
        uid: supabase.auth.currentUser!.id,
        soLuong: 1,
        chon: false,
      );
      gioHang[book.id] = item;
      update(["gioHang"]);
      final result = await GioHangSnapshot.them(item);
      if (result == 0) {
        gioHang.remove(book.id);
        update(["gioHang"]);
      }
    }
  }

  // Hỗ trợ thêm sách vào giỏ hàng và mở trang đăng nhập nếu người dùng chưa đăng nhập
  Future<void> themVaoGioHangKhiDaDangNhap(
    BuildContext context,
    Book book,
  ) async {
    if (supabase.auth.currentUser == null) {
      final daDangNhap = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute(builder: (context) => const PageLogin()));

      if (daDangNhap != true && supabase.auth.currentUser == null) {
        return;
      }
    }

    await themVaoGioHang(book);
  }

  // Xóa sạch giỏ hàng cục bộ trên ứng dụng
  void xoaGioHang() {
    gioHang.clear();
    update(["gioHang"]);
  }

  // Tăng số lượng của một cuốn sách trong giỏ hàng lên 1 và đồng bộ lên database
  Future<void> tangSoLuong(String bookId) async {
    final item = gioHang[bookId];
    if (item == null) return;
    item.soLuong++;
    update(["gioHang"]);
    final result = await GioHangSnapshot.capNhat(item);
    if (result == 0) {
      item.soLuong--;
      update(["gioHang"]);
    }
  }

  // Giảm số lượng cuốn sách trong giỏ hàng đi 1, xóa hẳn khỏi giỏ hàng nếu số lượng về 0
  Future<void> giamSoLuong(String bookId) async {
    var item = gioHang[bookId];
    if (item == null) return;
    if (item.soLuong <= 1) {
      gioHang.remove(bookId);
      update(["gioHang"]);
      final result = await GioHangSnapshot.xoa(item.uid!, bookId);
      if (result == 0) {
        gioHang[bookId] = item;
        update(["gioHang"]);
      }
    } else {
      item.soLuong--;
      update(["gioHang"]);
      final result = await GioHangSnapshot.capNhat(item);
      if (result == 0) {
        item.soLuong++;
        update(["gioHang"]);
      }
    }
  }

  // Xóa bỏ một cuốn sách hoàn toàn ra khỏi giỏ hàng của người dùng
  Future<void> xoaSanPhamKhoiGioHang(String bookId) async {
    final item = gioHang[bookId];
    if (item == null) return;
    gioHang.remove(bookId);
    update(["gioHang"]);
    final result = await GioHangSnapshot.xoa(item.uid!, bookId);
    if (result == 0) {
      gioHang[bookId] = item;
      update(["gioHang"]);
    }
  }

  // Xóa tất cả các sản phẩm đang được tích chọn (mua hàng) ra khỏi giỏ hàng
  Future<void> xoaSanPhamDaChonKhoiGioHang() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    final itemsToDelete = gioHang.values.where((item) => item.chon).toList();
    if (itemsToDelete.isEmpty) return;

    gioHang.removeWhere((_, item) => item.chon);
    update(["gioHang"]);

    bool allSuccess = true;
    for (final item in itemsToDelete) {
      final result = await GioHangSnapshot.xoa(user.id, item.bookId);
      if (result == 0) {
        allSuccess = false;
      }
    }

    if (!allSuccess) {
      await _taiGioHangNguoiDung();
    }
  }

  // Thay đổi trạng thái tích chọn để mua hàng của một sản phẩm trong giỏ hàng
  Future<void> chonSanPham(String bookId, bool? value) async {
    final item = gioHang[bookId];
    if (item == null) return;
    final oldValue = item.chon;
    item.chon = value ?? false;
    update(["gioHang"]);
    final result = await GioHangSnapshot.capNhat(item);
    if (result == 0) {
      item.chon = oldValue;
      update(["gioHang"]);
    }
  }

  // Chọn hoặc bỏ chọn toàn bộ tất cả sản phẩm đang có trong giỏ hàng
  Future<void> chonTatCaSanPham(bool? value) async {
    final chon = value ?? false;
    final oldStates = <String, bool>{};
    for (final entry in gioHang.entries) {
      oldStates[entry.key] = entry.value.chon;
      entry.value.chon = chon;
    }
    update(["gioHang"]);

    bool allSuccess = true;
    for (final item in gioHang.values) {
      final result = await GioHangSnapshot.capNhat(item);
      if (result == 0) {
        allSuccess = false;
      }
    }

    if (!allSuccess) {
      for (final entry in gioHang.entries) {
        entry.value.chon = oldStates[entry.key] ?? false;
      }
      update(["gioHang"]);
    }
  }

  // Hàm nội bộ tải dữ liệu danh sách giỏ hàng của người dùng hiện tại từ database Supabase
  Future<void> _taiGioHangNguoiDung() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      xoaGioHang();
      return;
    }

    try {
      final data = await GioHangSnapshot.getGioHang(user.id);
      gioHang = data;
      if (mapBooks.isNotEmpty) {
        gioHang.removeWhere((bookId, _) => !mapBooks.containsKey(bookId));
      }
      update(["gioHang"]);
    } catch (e) {
      print("Lỗi tải giỏ hàng từ Supabase: $e");
    }
  }

  // ── Logic Quản trị và Quản lý ──────────────────────────────────────────

  // Lấy quyền/vai trò (role) của người dùng hiện tại dựa trên ID từ bảng User trên database
  Future<String?> layVaiTroNguoiDung(String userId) async {
    final res = await supabase
        .from('User')
        .select('role')
        .eq('id', userId)
        .maybeSingle();
    return res?['role']?.toString();
  }

  // Nâng cấp quyền tài khoản người dùng chỉ định lên quản trị viên (admin)
  Future<void> nangCapQuyenAdmin(String userId) async {
    await supabase.from('User').update({'role': 'admin'}).eq('id', userId);
  }

  // Thêm một cuốn sách mới vào database và upload ảnh bìa nếu có lên Supabase Storage
  Future<void> themSach(Book book, File? imageFile) async {
    String imgUrl = book.anh ?? "";
    if (imageFile != null) {
      final fileName = "book_${DateTime.now().millisecondsSinceEpoch}.jpg";
      imgUrl = await uploadImage(
        image: imageFile,
        bucket: "anhSach",
        path: fileName,
        upsert: true,
      );
    }
    final finalBook = Book(
      id: book.id,
      tenSach: book.tenSach,
      gia: book.gia,
      tacGia: book.tacGia,
      theLoaiSach: book.theLoaiSach,
      nhaXuatBan: book.nhaXuatBan,
      namXuatBan: book.namXuatBan,
      moTa: book.moTa,
      soLuong: book.soLuong,
      anh: imgUrl,
      sale: book.sale,
    );
    await BookSnapshot.insert(finalBook);
    await taiDuLieu();
  }

  // Cập nhật thông tin cuốn sách hiện có và upload ảnh mới thay thế nếu có chọn ảnh
  Future<void> capNhatSach(Book book, File? imageFile) async {
    String imgUrl = book.anh ?? "";
    if (imageFile != null) {
      final fileName = "book_${DateTime.now().millisecondsSinceEpoch}.jpg";
      imgUrl = await uploadImage(
        image: imageFile,
        bucket: "anhSach",
        path: fileName,
        upsert: true,
      );
    }
    final finalBook = Book(
      id: book.id,
      tenSach: book.tenSach,
      gia: book.gia,
      tacGia: book.tacGia,
      theLoaiSach: book.theLoaiSach,
      nhaXuatBan: book.nhaXuatBan,
      namXuatBan: book.namXuatBan,
      moTa: book.moTa,
      soLuong: book.soLuong,
      anh: imgUrl,
      sale: book.sale,
    );
    await BookSnapshot.update(finalBook);
    await taiDuLieu();
  }

  // Xóa bỏ một cuốn sách hoàn toàn khỏi database Supabase
  Future<void> xoaSach(String bookId) async {
    await BookSnapshot.delete(bookId);
    await taiDuLieu();
  }

  // Thêm mới một danh mục thể loại sách vào database
  Future<void> themTheLoai(String id, String ten) async {
    await supabase.from("TheLoaiSach").insert({'id': id, 'tenTheLoai': ten});
    await taiDuLieu();
  }

  // Cập nhật tên của một thể loại sách đã có
  Future<void> capNhatTheLoai(String id, String ten) async {
    await supabase.from("TheLoaiSach").update({'tenTheLoai': ten}).eq('id', id);
    await taiDuLieu();
  }

  // Xóa bỏ hoàn toàn một thể loại sách khỏi database
  Future<void> xoaTheLoai(String id) async {
    await supabase.from("TheLoaiSach").delete().eq('id', id);
    await taiDuLieu();
  }

  // Tải danh sách toàn bộ các đơn hàng hiện có để phục vụ thống kê doanh thu và quản lý
  Future<void> taiTatCaDonHang() async {
    try {
      final List<dynamic> donHangData = await supabase
          .from('DonHang')
          .select()
          .order('ngayDat', ascending: false);

      final List<Map<String, dynamic>> tempOrders = [];
      int tempRevenue = 0;

      for (final dh in donHangData) {
        final order = Map<String, dynamic>.from(dh as Map);
        order['id'] = dh['id'].toString();

        final details = <dynamic>[];
        try {
          final data = await supabase
              .from('chiTietDon')
              .select('*, Book(*)')
              .eq('DonHangId', dh['id']);
          details.addAll(data);
        } catch (_) {}
        try {
          final data = await supabase
              .from('chiTietDon')
              .select('*, Book(*)')
              .eq('donHangId', dh['id']);
          for (final item in data) {
            final itemId = (item as Map)['id']?.toString();
            final exists = details.any((detail) {
              return (detail as Map)['id']?.toString() == itemId;
            });
            if (!exists) {
              details.add(item);
            }
          }
        } catch (_) {}
        if (details.isEmpty && dh['chTietDonHang'] != null) {
          final item = await supabase
              .from('chiTietDon')
              .select('*, Book(*)')
              .eq('id', dh['chTietDonHang'])
              .maybeSingle();
          if (item != null) {
            details.add(item);
          }
        }

        final tongTien = _readInt(order['tongTien']) ?? 0;
        if (dh['chTietDonHang'] != null &&
            tongTien > 0 &&
            _sumDetails(details) < tongTien) {
          try {
            final adjacentDetails = await supabase
                .from('chiTietDon')
                .select('*, Book(*)')
                .gte('id', dh['chTietDonHang'])
                .order('id', ascending: true)
                .limit(20);
            final rebuilt = <dynamic>[];
            var total = 0;
            for (final item in adjacentDetails) {
              rebuilt.add(item);
              total += _detailTotal(Map<String, dynamic>.from(item as Map));
              if (total >= tongTien) {
                break;
              }
            }
            if (rebuilt.length > details.length && total == tongTien) {
              details
                ..clear()
                ..addAll(rebuilt);
            }
          } catch (_) {}
        }

        order['items'] = details.map((item) {
          final book = item['Book'] as Map<String, dynamic>?;
          return {
            'bookId': item['BookId']?.toString() ?? '',
            'tenSach': book?['tenSach'] ?? 'Sách',
            'soLuong': item['soLuong'] ?? 1,
            'giaBan': int.tryParse(item['donGia']?.toString() ?? '0') ?? 0,
            'anh': book?['anh'] ?? '',
          };
        }).toList();

        if (order['trangThai'] == 'delivered') {
          tempRevenue += _readInt(order['tongTien']) ?? 0;
        }
        tempOrders.add(order);
      }

      ordersList = tempOrders;
      totalOrders = tempOrders.length;
      revenue = tempRevenue;
      update(["admin_orders", "admin_dashboard"]);
      return;
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('don_hang_'));
    List<Map<String, dynamic>> tempOrders = [];
    int tempRevenue = 0;

    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            for (var item in decoded) {
              final order = Map<String, dynamic>.from(item);
              order['_userKey'] = key;
              tempOrders.add(order);

              if (order['trangThai'] == 'delivered') {
                tempRevenue += _readInt(order['tongTien']) ?? 0;
              }
            }
          }
        } catch (_) {}
      }
    }

    tempOrders.sort((a, b) {
      final dateA =
          DateTime.tryParse(a["ngayDat"]?.toString() ?? "") ?? DateTime.now();
      final dateB =
          DateTime.tryParse(b["ngayDat"]?.toString() ?? "") ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    ordersList = tempOrders;
    totalOrders = tempOrders.length;
    revenue = tempRevenue;
    update(["admin_orders", "admin_dashboard"]);
  }

  // Cập nhật trạng thái xử lý của đơn hàng (ví dụ: pending -> delivered) và tải lại danh sách
  Future<void> capNhatTrangThaiDonHang(
    Map<String, dynamic> order,
    String newStatus,
  ) async {
    final orderId = order['id']?.toString() ?? '';
    final idInt = int.tryParse(orderId);
    if (idInt != null) {
      await supabase
          .from('DonHang')
          .update({'trangThai': newStatus})
          .eq('id', idInt);
      order['trangThai'] = newStatus;
      await taiTatCaDonHang();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userKey = order['_userKey'] as String?;
    if (userKey == null) return;

    final raw = prefs.getString(userKey);
    if (raw == null) return;

    final List<dynamic> decoded = jsonDecode(raw);
    final List<Map<String, dynamic>> orders = decoded
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    for (var o in orders) {
      if (o['id'] == order['id']) {
        o['trangThai'] = newStatus;
        break;
      }
    }
    await prefs.setString(userKey, jsonEncode(orders));
    await taiTatCaDonHang();
  }

  // Hàm nội bộ tính tổng tiền từ danh sách chi tiết đơn hàng
  int _sumDetails(List<dynamic> details) {
    var total = 0;
    for (final detail in details) {
      total += _detailTotal(Map<String, dynamic>.from(detail as Map));
    }
    return total;
  }

  // Hàm nội bộ tính tổng tiền cho từng chi tiết đơn hàng (số lượng * đơn giá)
  int _detailTotal(Map<String, dynamic> detail) {
    final soLuong = _readInt(detail['soLuong']) ?? 1;
    final donGia = _readInt(detail['donGia']) ?? 0;
    return soLuong * donGia;
  }

  // Hàm hỗ trợ đọc số nguyên an toàn
  int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
