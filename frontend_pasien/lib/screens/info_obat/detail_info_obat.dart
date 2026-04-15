import 'package:flutter/material.dart';

// ─── MODEL DETAIL ─────────────────────────────────────────────────────────────

class DetailObat {
  final String nama;
  final String kategori;
  final Color color;
  final String frekuensi;      // contoh: '3-4x sehari'
  final String durasi;         // contoh: '3-5 hari'
  final String waktuMinum;     // contoh: 'Sesudah makan'
  final String fungsi;
  final String aturanPakai;
  final String perhatian;

  const DetailObat({
    required this.nama,
    required this.kategori,
    required this.color,
    required this.frekuensi,
    required this.durasi,
    required this.waktuMinum,
    required this.fungsi,
    required this.aturanPakai,
    required this.perhatian,
  });
}

// ─── DUMMY DETAIL DATA ────────────────────────────────────────────────────────

const _dummyDetail = DetailObat(
  nama: 'Paracetamol',
  kategori: 'Pereda Nyeri & Demam',
  color: Color(0xFF4CAF82),
  frekuensi: '3-4x sehari',
  durasi: '3-5 hari',
  waktuMinum: 'Sesudah makan',
  fungsi:
      'Membantu meredakan sakit kepala, nyeri otot, sakit gigi, serta menurunkan demam dengan cara menghambat pembentukan prostaglandin di dalam tubuh.',
  aturanPakai:
      'Minum 1 tablet setiap 4 hingga 6 jam jika diperlukan. Telan utuh dengan air putih. Jangan melebihi 8 tablet dalam jangka waktu 24 jam untuk menghindari risiko kerusakan hati.',
  perhatian:
      'Simpan di tempat sejuk dan kering, jauh dari jangkauan anak-anak. Konsultasikan dengan dokter jika kondisi tidak turun setelah 3 hari atau jika muncul reaksi alergi seperti ruam kulit.',
);

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class DetailInfoObatScreen extends StatelessWidget {
  final DetailObat obat;

  const DetailInfoObatScreen({super.key, this.obat = _dummyDetail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            _buildInfoRow(),
            const SizedBox(height: 16),
            _buildSection(
              icon: '💊',
              title: 'Fungsi obat',
              content: obat.fungsi,
            ),
            _buildSection(
              icon: '📋',
              title: 'Aturan Pakai',
              content: obat.aturanPakai,
            ),
            _buildSection(
              icon: '⚠️',
              title: 'Perhatian',
              content: obat.perhatian,
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero (gambar + nama + kategori) ──────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          // Placeholder gambar obat
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: obat.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(Icons.medication_rounded, color: obat.color, size: 64),
          ),
          const SizedBox(height: 16),
          Text(obat.nama,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(obat.kategori,
              style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // ── Info row (frekuensi, durasi, waktu minum) ─────────────────────────────────

  Widget _buildInfoRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _infoChip(icon: Icons.access_time_rounded, label: obat.frekuensi),
          _divider(),
          _infoChip(icon: Icons.calendar_today_rounded, label: obat.durasi),
          _divider(),
          _infoChip(icon: Icons.restaurant_rounded, label: obat.waktuMinum),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2BB673), size: 22),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
  }

  // ── Section card (fungsi, aturan, perhatian) ──────────────────────────────────

  Widget _buildSection({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 10),
          Text(content,
              style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.6)),
        ],
      ),
    );
  }
}