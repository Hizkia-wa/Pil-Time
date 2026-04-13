import 'package:flutter/material.dart';

class EditJadwalKonsumsi extends StatefulWidget {
  final Map<String, dynamic> data; // ✅ WAJIB untuk edit

  const EditJadwalKonsumsi({super.key, required this.data});

  @override
  State<EditJadwalKonsumsi> createState() =>
      _EditJadwalKonsumsiState();
}

class _EditJadwalKonsumsiState extends State<EditJadwalKonsumsi> {
  String selectedWaktu = "Pagi";
  String selectedFrekuensi = "Setiap Hari";
  String selectedDurasi = "7 Hari";

  final TextEditingController namaController = TextEditingController();
  final TextEditingController dosisController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // ✅ LOAD DATA DARI LIST
    namaController.text = widget.data['nama'] ?? '';
    dosisController.text = widget.data['dosis'] ?? '';
    selectedWaktu = widget.data['waktu'] ?? "Pagi";
    selectedFrekuensi = widget.data['frekuensi'] ?? "Setiap Hari";
    selectedDurasi = widget.data['durasi'] ?? "7 Hari";
  }

  @override
  void dispose() {
    namaController.dispose();
    dosisController.dispose();
    super.dispose();
  }

  void updateData() {
    final result = {
      "id": widget.data['id'],
      "nama": namaController.text,
      "dosis": dosisController.text,
      "waktu": selectedWaktu,
      "frekuensi": selectedFrekuensi,
      "durasi": selectedDurasi,
    };

    Navigator.pop(context, result); // ✅ kirim balik
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Edit Jadwal"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // NAMA
            const Text("Nama Obat"),
            const SizedBox(height: 5),
            textField("Contoh: Paracetamol", namaController),

            const SizedBox(height: 15),

            // DOSIS
            const Text("Dosis"),
            const SizedBox(height: 5),
            textField("Contoh: 500mg", dosisController),

            const SizedBox(height: 20),

            // WAKTU
            const Text("Waktu Pengingat"),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
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

            // BUTTON UPDATE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: updateData,
                child: const Text(
                  "Update Jadwal",
                  style: TextStyle(
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

  Widget textField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
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
      onTap: () => setState(() => selectedWaktu = label),
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