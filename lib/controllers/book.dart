import 'package:huyhoangbooks/controllers/supabae_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Book {
  String id;
  String tenSach;
  int? gia;
  String? tacGia;
  String? theLoaiSach;
  String? tenTheLoai;
  String? nhaXuatBan;
  int? namXuatBan;
  String? moTa;
  int? soLuong;
  String? anh;
  int? sale;

  Book({
    required this.id,
    required this.tenSach,
    this.gia,
    this.tacGia,
    this.theLoaiSach,
    this.tenTheLoai,
    this.nhaXuatBan,
    this.namXuatBan,
    this.moTa,
    this.soLuong,
    this.anh,
    this.sale,
  });

  // Chuyển đổi đối tượng Book sang dữ liệu Map<String, dynamic> để lưu trữ
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenSach': tenSach,
      'gia': gia,
      'tacGia': tacGia,
      'theLoaiSach': theLoaiSach,
      'nhaXuatBan': nhaXuatBan,
      'namXuatBan': namXuatBan,
      'moTa': moTa,
      'soLuong': soLuong,
      'anh': anh,
      'sale': sale,
    };
  }

  // Khởi tạo đối tượng Book từ bản đồ dữ liệu Map<String, dynamic>
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'].toString(),
      tenSach: map['tenSach']?.toString() ?? '',
      gia: _readInt(map['gia']),
      tacGia: map['tacGia']?.toString(),
      theLoaiSach: map['theLoaiSach']?.toString(),
      tenTheLoai: map['tenTheLoai']?.toString(),
      nhaXuatBan: map['nhaXuatBan']?.toString(),
      namXuatBan: _readInt(map['namXuatBan']),
      moTa: map['moTa']?.toString(),
      soLuong: _readInt(map['soLuong']),
      anh: map['anh']?.toString(),
      sale: _readInt(map['sale']),
    );
  }

  // Lấy giá gốc của sách
  int get giaGoc => gia ?? 0;

  // Lấy phần trăm giảm giá của sách (trong khoảng từ 0 đến 100)
  int get phanTramSale {
    final value = sale ?? 0;
    if (value < 0) return 0;
    if (value > 100) return 100;
    return value;
  }

  // Kiểm tra xem sách có đang trong chương trình giảm giá hay không
  bool get dangSale => phanTramSale > 0;

  // Tính toán giá bán thực tế sau khi áp dụng giảm giá
  int get giaBan {
    if (!dangSale) return giaGoc;
    return giaGoc * (100 - phanTramSale) ~/ 100;
  }
}

// thể loại sách
class TheLoaiSach {
  String id;
  String tenTheLoai;

  TheLoaiSach({required this.id, required this.tenTheLoai});

  // Chuyển đổi đối tượng TheLoaiSach sang bản đồ dữ liệu Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {'id': id, 'tenTheLoai': tenTheLoai};
  }

  // Khởi tạo đối tượng TheLoaiSach từ Map<String, dynamic>
  factory TheLoaiSach.fromMap(Map<String, dynamic> map) {
    return TheLoaiSach(
      id: map['id'].toString(),
      tenTheLoai: map['tenTheLoai']?.toString() ?? '',
    );
  }
}

// Lấy danh sách sách từ Supabase
Future<Map<String, Book>> getMapBook() async {
  return getMapData<Book, String>(
    table: "Book",
    fromJson: (json) => Book.fromMap(json),
    getID: (t) => t.id,
  );
}

// Lấy  danh sách thể loại sách từ Supabase
Future<Map<String, TheLoaiSach>> getMapTheLoaiSach() async {
  return getMapData<TheLoaiSach, String>(
    table: "TheLoaiSach",
    fromJson: (json) => TheLoaiSach.fromMap(json),
    getID: (t) => t.id,
  );
}

// L thao tác cập nhật dữ liệu Book trên Supabase
class BookSnapshot {
  // Lấy Stream luồng dữ liệu của danh sách các cuốn sách
  static Stream<List<Book>> getBookStream() {
    return getDataStream<Book>(
      table: "Book",
      ids: ["id"],
      fromJson: (map) => Book.fromMap(map),
    );
  }

  // Lấy bản đồ danh sách sách trực tiếp từ bảng Book
  static Future<Map<String, Book>> getMapBook() async {
    final data = await supabase.from('Book').select();
    var iterable = data.map((e) => Book.fromMap(e));
    Map<String, Book> map = {for (var element in iterable) element.id: element};
    return map;
  }

  // Cập nhật thông tin một cuốn sách trên Supabase
  static Future<void> update(Book newBook) async {
    await supabase.from('Book').update(newBook.toMap()).eq('id', newBook.id);
  }

  // Xóa một cuốn sách khỏi database Supabase
  static Future<void> delete(String id) async {
    await supabase.from('Book').delete().eq('id', id);
  }

  // Thêm mới một cuốn sách vào database Supabase
  static Future<void> insert(Book book) async {
    await supabase.from("Book").insert(book.toMap());
  }

  // Đăng ký lắng nghe sự thay đổi dữ liệu thời gian thực của bảng Book từ Supabase
  static void listenDataChange(Map<String, Book> maps, {Function()? updateUI}) {
    supabase
        .channel('public:Book')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'Book',
          callback: (payload) {
            switch (payload.eventType) {
              case PostgresChangeEvent.insert:
              case PostgresChangeEvent.update:
                {
                  Book book = Book.fromMap(payload.newRecord);
                  maps[book.id] = book;
                  updateUI?.call();
                  break;
                }
              case PostgresChangeEvent.delete:
                {
                  maps.remove(payload.oldRecord["id"].toString());
                  updateUI?.call();
                  break;
                }
              default:
                {}
            }
          },
        )
        .subscribe();
  }
}

// Hàm hỗ trợ đọc giá trị số nguyên an toàn từ dữ liệu động
int? _readInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
