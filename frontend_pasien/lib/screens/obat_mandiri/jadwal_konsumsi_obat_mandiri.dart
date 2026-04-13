import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './tambah_jadwal_konsumsi_obat_mandiri.dart';

class JadwalKonsumsiObatMandiriStyled extends StatefulWidget {
  final int streakHari;

  const JadwalKonsumsiObatMandiriStyled({
    super.key,
    required this.streakHari,
  });

  @override
  State<JadwalKonsumsiObatMandiriStyled> createState() =>
      _JadwalKonsumsiObatMandiriStyledState();
}

class _JadwalKonsumsiObatMandiriStyledState
    extends State<JadwalKonsumsiObatMandiriStyled> {

  List<dynamic> jadwalList = [];
  bool isLoading = true;

  final String baseUrl = "http://10.0.2.2:8080/jadwal";

  @override
  void initState() {
    super.initState();
    fetchJadwal();
  }

  // ================= FETCH DATA =================
  Future<void> fetchJadwal() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          jadwalList = data['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= DELETE =================
  Future<void> deleteJadwal(int id) async {
    await http.delete(Uri.parse("$baseUrl/$id"));
    fetchJadwal();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchJadwal,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _buildStreakCard(),
          const SizedBox(height: 16),

          const Text(
            "Daftar Obat",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (jadwalList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Belum ada jadwal obat",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            )
          else
            ...jadwalList.map(_buildObatCard),

          const SizedBox(height: 30),

          _buildTambahButton(),
        ],
      ),
    );
  }

  // ================= STREAK CARD =================
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10221C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🏆 STREAK KAMU!",
            style: TextStyle(
              color: Color(0xFF13ECA4),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${widget.streakHari} Hari",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================= OBAT CARD =================
  Widget _buildObatCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['nama_jadwal'] ?? '-',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item['dosis'] ?? '-',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              _actionButton(
                icon: Icons.edit_rounded,
                color: Colors.blue,
                bg: const Color(0xFFDBEAFE),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TambahJadwalKonsumsi(data: item),
                    ),
                  ).then((_) => fetchJadwal());
                },
              ),
              const SizedBox(width: 8),
              _actionButton(
                icon: Icons.delete_rounded,
                color: Colors.red,
                bg: const Color(0xFFFEE2E2),
                onTap: () {
                  deleteJadwal(item['jadwal_id']);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTON =================
  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ================= TAMBAH BUTTON =================
  Widget _buildTambahButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TambahJadwalKonsumsi(),
            ),
          ).then((_) => fetchJadwal());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF13EC5B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(
          Icons.add_rounded,
          color: Color(0xFF0F172A),
        ),
        label: const Text(
          "Tambahkan Jadwal Konsumsi Obat",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}