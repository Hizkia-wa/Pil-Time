import 'package:flutter/material.dart';

class TambahJadwalKonsumsi extends StatefulWidget {
  final Map<String, dynamic>? data; // ✅ untuk EDIT

  const TambahJadwalKonsumsi({super.key, this.data});

  @override
  State<TambahJadwalKonsumsi> createState() =>
      _TambahJadwalKonsumsiState();
}

class _TambahJadwalKonsumsiState extends State<TambahJadwalKonsumsi> {
  String selectedWaktu = "Pagi";
  String selectedFrekuensi = "Setiap Hari";
  String selectedDurasi = "7 Hari";

  // ✅ CONTROLLER
  final TextEditingController namaController = TextEditingController();
  final TextEditingController dosisController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ MODE EDIT
    if (widget.data != null) {
      namaController.text = widget.data!['nama'] ?? '';
      dosisController.text = widget.data!['dosis'] ?? '';
      selectedWaktu = widget.data!['waktu'] ?? "Pagi";
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    dosisController.dispose();
    super.dispose();
  }

  void simpanData() {
    final result = {
      "id": widget.data?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      "nama": namaController.text,
      "dosis": dosisController.text,
      "waktu": selectedWaktu,
      "frekuensi": selectedFrekuensi,
      "durasi": selectedDurasi,
    };

    Navigator.pop(context, result); // ✅ kirim balik ke halaman sebelumnya
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.data != null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          isEdit ? "Edit Jadwal" : "Tambah Jadwal",
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TAB
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                tabItem("Obat", true),
                const SizedBox(width: 40),
                tabItem("Rutinitas", false),
              ],
            ),

            const SizedBox(height: 20),

            // NAMA
            const Text("Nama Obat"),
            const SizedBox(height: 5),
            textField("Contoh: Paracetamol", controller: namaController),

            const SizedBox(height: 15),

            // DOSIS
            const Text("Dosis"),
            const SizedBox(height: 5),
            textField("Contoh: 500mg", controller: dosisController),

            const SizedBox(height: 15),

            // FOTO
            const Text("Foto Obat (Opsional)"),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 50,
              decoration: boxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Upload foto"),
                  Icon(Icons.camera_alt_outlined)
                ],
              ),
            ),

            const SizedBox(height: 20),

            // WAKTU
            const Text("Waktu Pengingat"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                waktuButton("Pagi"),
                waktuButton("Siang"),
                waktuButton("Sore"),
                waktuButton("Malam"),
              ],
            ),

            const SizedBox(height: 20),

            // DROPDOWN
            Row(
              children: [
                Expanded(
                  child: dropdownField(
                    "Frekuensi",
                    selectedFrekuensi,
                    ["Setiap Hari", "2x Sehari", "3x Sehari"],
                    (val) => setState(() => selectedFrekuensi = val!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: dropdownField(
                    "Durasi",
                    selectedDurasi,
                    ["3 Hari", "7 Hari", "14 Hari"],
                    (val) => setState(() => selectedDurasi = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: simpanData,
                child: Text(
                  isEdit ? "Update Jadwal" : "Simpan Jadwal",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT =================

  Widget tabItem(String text, bool active) {
    return Column(
      children: [
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? Colors.green : Colors.grey),
        ),
        const SizedBox(height: 5),
        if (active)
          Container(
            height: 3,
            width: 40,
            color: Colors.green,
          )
      ],
    );
  }

  Widget textField(String hint, {required TextEditingController controller}) {
    return TextField(
      controller: controller, // ✅ penting
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget waktuButton(String label) {
    bool isSelected = selectedWaktu == label;

    return GestureDetector(
      onTap: () {
        setState(() => selectedWaktu = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300),
        ),
        child: Text(label),
      ),
    );
  }

  Widget dropdownField(String title, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: boxDecoration(),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        )
      ],
    );
  }

  BoxDecoration boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    );
  }
}