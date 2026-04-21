import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TambahJadwalKonsumsi extends StatefulWidget {
  final Map<String, dynamic>? data;

  const TambahJadwalKonsumsi({super.key, this.data});

  @override
  State<TambahJadwalKonsumsi> createState() => _TambahJadwalKonsumsiState();
}

class _TambahJadwalKonsumsiState extends State<TambahJadwalKonsumsi> {
  // State Variables
  String selectedWaktu = "Pagi";
  String selectedFrekuensi = "Setiap Hari";
  String selectedDurasi = "7 Hari";
  File? _imageFile;

  // Controllers
  final TextEditingController namaController = TextEditingController();
  final TextEditingController dosisController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Inisialisasi jika Mode Edit
    if (widget.data != null) {
      namaController.text = widget.data!['nama'] ?? '';
      dosisController.text = widget.data!['dosis'] ?? '';
      selectedWaktu = widget.data!['waktu'] ?? "Pagi";
      selectedFrekuensi = widget.data!['frekuensi'] ?? "Setiap Hari";
      selectedDurasi = widget.data!['durasi'] ?? "7 Hari";
      if (widget.data!['foto'] != null) {
        _imageFile = File(widget.data!['foto']);
      }
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    dosisController.dispose();
    super.dispose();
  }

  // Fungsi ambil gambar dari Galeri/Kamera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Kompres foto agar hemat memori
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // Dialog untuk memilih sumber gambar
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void simpanData() {
    // Validasi sederhana
    if (namaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama obat tidak boleh kosong")),
      );
      return;
    }

    final result = {
      "id": widget.data?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      "nama": namaController.text,
      "dosis": dosisController.text,
      "waktu": selectedWaktu,
      "frekuensi": selectedFrekuensi,
      "durasi": selectedDurasi,
      "foto": _imageFile?.path, // Mengirim path file ke halaman sebelumnya
    };

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.data != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isEdit ? "Edit Jadwal" : "Tambah Jadwal",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Selector (Hanya UI)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabItem("Obat", true),
                const SizedBox(width: 40),
                _buildTabItem("Rutinitas", false),
              ],
            ),
            const SizedBox(height: 20),

            // Form Input
            _buildLabel("Nama Obat"),
            _buildTextField("Contoh: Paracetamol", namaController),

            const SizedBox(height: 15),
            _buildLabel("Dosis"),
            _buildTextField("Contoh: 500mg", dosisController),

            const SizedBox(height: 15),
            _buildLabel("Foto Obat (Opsional)"),
            const SizedBox(height: 5),
            _buildImagePickerBox(),

            const SizedBox(height: 20),
            _buildLabel("Waktu Pengingat"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ["Pagi", "Siang", "Sore", "Malam"]
                  .map((waktu) => _buildWaktuButton(waktu))
                  .toList(),
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    "Frekuensi",
                    selectedFrekuensi,
                    ["Setiap Hari", "2x Sehari", "3x Sehari"],
                    (val) => setState(() => selectedFrekuensi = val!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildDropdownField(
                    "Durasi",
                    selectedDurasi,
                    ["3 Hari", "7 Hari", "14 Hari"],
                    (val) => setState(() => selectedDurasi = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: simpanData,
                child: Text(
                  isEdit ? "Update Jadwal" : "Simpan Jadwal",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600));
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return GestureDetector(
      onTap: _showPickerOptions,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _imageFile == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 30),
                  Text("Tambah Foto", style: TextStyle(color: Colors.grey)),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_imageFile!, width: double.infinity, height: 120, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: GestureDetector(
                      onTap: () => setState(() => _imageFile = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildWaktuButton(String label) {
    bool isSelected = selectedWaktu == label;
    return GestureDetector(
      onTap: () => setState(() => selectedWaktu = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String title, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(title),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildTabItem(String text, bool active) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold, color: active ? Colors.green : Colors.grey),
        ),
        if (active)
          Container(height: 2, width: 30, color: Colors.green, margin: const EdgeInsets.only(top: 4)),
      ],
    );
  }
}