import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:huyhoangbooks/controllers/ui_state_controllers.dart';
import 'package:huyhoangbooks/helper/dia_chi_helper.dart';

class PageDiaChi extends StatefulWidget {
  final bool isSelectionMode;
  const PageDiaChi({super.key, this.isSelectionMode = false});

  @override
  State<PageDiaChi> createState() => _PageDiaChiState();
}

class _PageDiaChiState extends State<PageDiaChi> {
  final uiController = Get.put(AddressUiController());

  Future<void> _themHoacSuaDiaChi({Map<String, dynamic>? item}) async {
    final isEdit = item != null;
    final tenController = TextEditingController(text: item?["ten"] ?? "");
    final sdtController = TextEditingController(text: item?["sdt"] ?? "");
    final chiTietController = TextEditingController(
      text: item?["chiTiet"] ?? "",
    );
    bool isMacDinh = item?["macDinh"] ?? false;

    final mapDiaChi = DiaChiHelper.mapDiaChi;

    // Khởi tạo các biến lựa chọn
    String? selectedTinh = item?["tinh"];
    String? selectedQuan = item?["quan"];
    String? selectedPhuong = item?["phuong"];

    // Đảm bảo dữ liệu cũ khớp với Map dữ liệu, tránh lỗi crash Dropdown
    if (selectedTinh != null && !mapDiaChi.containsKey(selectedTinh)) {
      selectedTinh = null;
      selectedQuan = null;
      selectedPhuong = null;
    }
    if (selectedTinh != null &&
        selectedQuan != null &&
        !mapDiaChi[selectedTinh]!.containsKey(selectedQuan)) {
      selectedQuan = null;
      selectedPhuong = null;
    }
    if (selectedTinh != null &&
        selectedQuan != null &&
        selectedPhuong != null &&
        !mapDiaChi[selectedTinh]![selectedQuan]!.contains(selectedPhuong)) {
      selectedPhuong = null;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              padding: EdgeInsets.only(
                left: 20,
                top: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      isEdit ? "Chỉnh sửa địa chỉ" : "Thêm địa chỉ mới",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: tenController,
                      decoration: const InputDecoration(
                        labelText: "Họ và tên người nhận",
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: sdtController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Số điện thoại",
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Dropdown chọn Tỉnh / Thành phố
                    DropdownButtonFormField<String>(
                      menuMaxHeight: 250,
                      initialValue: selectedTinh,
                      decoration: const InputDecoration(
                        labelText: "Tỉnh / Thành phố",
                        prefixIcon: Icon(Icons.map_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: mapDiaChi.keys.map((tinh) {
                        return DropdownMenuItem(value: tinh, child: Text(tinh));
                      }).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedTinh = val;
                          selectedQuan = null;
                          selectedPhuong = null;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    // Dropdown chọn Quận / Huyện
                    DropdownButtonFormField<String>(
                      menuMaxHeight: 250,
                      initialValue: selectedQuan,
                      decoration: const InputDecoration(
                        labelText: "Quận / Huyện",
                        prefixIcon: Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items:
                      (selectedTinh != null &&
                          mapDiaChi.containsKey(selectedTinh!))
                          ? mapDiaChi[selectedTinh]!.keys.map((quan) {
                        return DropdownMenuItem(
                          value: quan,
                          child: Text(quan),
                        );
                      }).toList()
                          : [],
                      onChanged: selectedTinh == null
                          ? null
                          : (val) {
                        setModalState(() {
                          selectedQuan = val;
                          selectedPhuong = null;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    // Dropdown chọn Phường / Xã
                    DropdownButtonFormField<String>(
                      menuMaxHeight: 250,
                      initialValue: selectedPhuong,
                      decoration: const InputDecoration(
                        labelText: "Phường / Xã",
                        prefixIcon: Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items:
                      (selectedTinh != null &&
                          selectedQuan != null &&
                          mapDiaChi[selectedTinh]!.containsKey(
                            selectedQuan!,
                          ))
                          ? mapDiaChi[selectedTinh]![selectedQuan]!.map((
                          phuong,
                          ) {
                        return DropdownMenuItem(
                          value: phuong,
                          child: Text(phuong),
                        );
                      }).toList()
                          : [],
                      onChanged: selectedQuan == null
                          ? null
                          : (val) {
                        setModalState(() {
                          selectedPhuong = val;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: chiTietController,
                      decoration: const InputDecoration(
                        labelText: "Địa chỉ chi tiết (Số nhà, đường...)",
                        prefixIcon: Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Đặt làm địa chỉ mặc định",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      value: isMacDinh,
                      onChanged: (val) {
                        setModalState(() {
                          isMacDinh = val;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    FilledButton(
                      onPressed: () async {
                        if (tenController.text.trim().isEmpty ||
                            sdtController.text.trim().isEmpty ||
                            selectedTinh == null ||
                            selectedQuan == null ||
                            selectedPhuong == null ||
                            chiTietController.text.trim().isEmpty) {
                          Get.snackbar(
                            "Thiếu thông tin",
                            "Vui lòng điền và lựa chọn đầy đủ thông tin địa chỉ.",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.orangeAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final newAddr = {
                          "id": isEdit
                              ? item["id"]
                              : "addr_${DateTime.now().millisecondsSinceEpoch}",
                          "ten": tenController.text.trim(),
                          "sdt": sdtController.text.trim(),
                          "tinh": selectedTinh,
                          "quan": selectedQuan,
                          "phuong": selectedPhuong,
                          "chiTiet": chiTietController.text.trim(),
                          "macDinh": isMacDinh,
                        };

                        await uiController.upsertAddress(
                          newAddr,
                          isEdit: isEdit,
                        );
                        if (!mounted || !context.mounted) return;
                        Navigator.of(context).pop();

                        Get.snackbar(
                          isEdit ? "Cập nhật thành công" : "Đã thêm địa chỉ",
                          isEdit
                              ? "Địa chỉ nhận hàng đã được cập nhật"
                              : "Đã lưu địa chỉ giao hàng mới",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Color(0xFFEF4D2F),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEdit ? "Cập nhật" : "Lưu địa chỉ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setMacDinh(String id) async {
    await uiController.setDefaultAddress(id);
    Get.snackbar(
      "Đã đặt làm mặc định",
      "Địa chỉ nhận hàng mặc định của bạn đã thay đổi",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  Future<void> _xoaDiaChi(String id) async {
    await uiController.deleteAddress(id);
    Get.snackbar(
      "Đã xóa địa chỉ",
      "Địa chỉ nhận hàng đã bị gỡ bỏ",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Địa chỉ nhận hàng",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFFEF4D2F),
        elevation: 0,
      ),
      body: SafeArea(
        child: GetBuilder<AddressUiController>(
          init: uiController,
          builder: (ui) => ui.isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFEF4D2F)),
          )
              : ui.addresses.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: ui.addresses.length,
            separatorBuilder: (context, index) =>
            SizedBox(height: 12),
            itemBuilder: (context, index) {
              final addr = ui.addresses[index];
              final id = addr["id"] as String;
              final isMacDinh = addr["macDinh"] as bool? ?? false;

              return GestureDetector(
                onTap: widget.isSelectionMode
                    ? () => Navigator.of(context).pop(addr)
                    : null,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isMacDinh
                          ? Color(0xFFEF4D2F)
                          : Color(0xFFE5E7EB),
                      width: isMacDinh ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              addr["ten"] ?? "",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            if (isMacDinh)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Color(0xFFEF4D2F),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Text(
                                  "Mặc định",
                                  style: TextStyle(
                                    color: Color(0xFFEF4D2F),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Điện thoại: ${addr["sdt"]}",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "${addr["chiTiet"]}, ${addr["phuong"]}, ${addr["quan"]}, ${addr["tinh"]}",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const Divider(height: 24, color: Color(0xFFF3F4F6)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (!isMacDinh)
                              TextButton(
                                onPressed: () => _setMacDinh(id),
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(0xFFEF4D2F),
                                  padding: EdgeInsets.zero,
                                ),
                                child: const Text(
                                  "Thiết lập mặc định",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            else
                              SizedBox.shrink(),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _themHoacSuaDiaChi(item: addr),
                                  icon: Icon(Icons.edit_outlined),
                                  color: Color(0xFF4B5563),
                                  tooltip: "Chỉnh sửa",
                                ),
                                IconButton(
                                  onPressed: () => _xoaDiaChi(id),
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                  ),
                                  color: Colors.redAccent,
                                  tooltip: "Xóa",
                                ),
                              ],
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
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: FilledButton.icon(
            onPressed: () => _themHoacSuaDiaChi(),
            icon: Icon(Icons.add, size: 20),
            label: const Text(
              "Thêm địa chỉ mới",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Color(0xFFEF4D2F),
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: Colors.black26,
          ),
          SizedBox(height: 16),
          Text(
            "Bạn chưa lưu địa chỉ nhận hàng nào",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _themHoacSuaDiaChi(),
            icon: Icon(Icons.add, size: 18),
            label: const Text(
              "Thêm địa chỉ ngay",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Color(0xFFEF4D2F),
              side: const BorderSide(color: Color(0xFFEF4D2F), width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
