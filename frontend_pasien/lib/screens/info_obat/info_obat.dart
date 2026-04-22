import 'package:flutter/material.dart';
import 'package:frontend_pasien/screens/info_obat/detail_info_obat.dart';

// ─── MODEL ───────────────────────────────────────────────────────────────────

class InfoObatItem {
  final String nama;
  final String kategori;
  final Color color;
  final String frekuensi;
  final String durasi;
  final String waktuMinum;
  final String fungsi;
  final String aturanPakai;
  final String perhatian;

  const InfoObatItem({
    required this.nama,
    required this.kategori,
    required this.color,
    this.frekuensi = '3-4x sehari',
    this.durasi = '3-5 hari',
    this.waktuMinum = 'Sesudah makan',
    this.fungsi = 'Fungsi obat akan diisi dari backend.',
    this.aturanPakai = 'Aturan pakai akan diisi dari backend.',
    this.perhatian = 'Perhatian akan diisi dari backend.',
  });
}

class InfoObatHari {
  final DateTime tanggal;
  final List<InfoObatItem> obatList;

  const InfoObatHari({required this.tanggal, required this.obatList});
}

// ─── DUMMY DATA ───────────────────────────────────────────────────────────────

List<InfoObatHari> _generateData() {
  final now = DateTime.now();
  DateTime ago(int days) => now.subtract(Duration(days: days));

  return [
    InfoObatHari(tanggal: ago(0), obatList: [
      InfoObatItem(
        nama: 'Paracetamol', kategori: 'Pereda Nyeri & Demam', color: const Color(0xFF4CAF82),
        frekuensi: '3-4x sehari', durasi: '3-5 hari', waktuMinum: 'Sesudah makan',
        fungsi: 'Membantu meredakan sakit kepala, nyeri otot, sakit gigi, serta menurunkan demam dengan cara menghambat pembentukan prostaglandin di dalam tubuh.',
        aturanPakai: 'Minum 1 tablet setiap 4 hingga 6 jam jika diperlukan. Telan utuh dengan air putih. Jangan melebihi 8 tablet dalam 24 jam.',
        perhatian: 'Simpan di tempat sejuk dan kering, jauh dari jangkauan anak-anak. Konsultasikan dengan dokter jika kondisi tidak membaik setelah 3 hari.',
      ),
      InfoObatItem(
        nama: 'Amocilin', kategori: 'Pereda Nyeri & Demam', color: const Color(0xFFE57373),
        frekuensi: '3x sehari', durasi: '5-7 hari', waktuMinum: 'Sesudah makan',
        fungsi: 'Mengobati berbagai jenis infeksi bakteri, seperti infeksi saluran pernapasan, infeksi telinga, infeksi kulit, hingga infeksi saluran kemih.',
        aturanPakai: 'Minum 1 kapsul setiap 8 jam secara teratur. Wajib dihabiskan sesuai petunjuk dokter meskipun gejala sudah hilang.',
        perhatian: 'Jangan digunakan jika memiliki riwayat alergi terhadap Penicillin. Segera hubungi dokter jika muncul gejala alergi berat.',
      ),
    ]),
    InfoObatHari(tanggal: ago(1), obatList: [
      InfoObatItem(
        nama: 'Flutamol', kategori: 'Obat Flu & Batuk', color: const Color(0xFF64B5F6),
        frekuensi: '2-3x sehari', durasi: '3-5 hari', waktuMinum: 'Sesudah makan',
        fungsi: 'Meringankan gejala flu seperti demam, sakit kepala, hidung tersumbat, dan bersin-bersin yang disertai batuk tidak berdahak.',
        aturanPakai: 'Minum 1 kaplet setiap 6-8 jam. Jangan melebihi 3 kaplet dalam 24 jam. Hindari mengemudi setelah mengonsumsi obat ini.',
        perhatian: 'Simpan di bawah suhu 30°C. Tidak dianjurkan untuk penderita tekanan darah tinggi, gangguan jantung, atau yang sedang mengonsumsi obat antidepresan.',
      ),
    ]),
    InfoObatHari(tanggal: ago(5), obatList: [
      InfoObatItem(
        nama: 'Amoxicillin', kategori: 'Antibiotik', color: const Color(0xFFFFB74D),
        frekuensi: '3x sehari', durasi: '7 hari', waktuMinum: 'Sesudah makan',
        fungsi: 'Antibiotik spektrum luas yang digunakan untuk mengobati berbagai infeksi bakteri.',
        aturanPakai: 'Minum 1 kapsul setiap 8 jam. Habiskan seluruh dosis meskipun gejala sudah membaik.',
        perhatian: 'Beritahu dokter jika ada riwayat alergi penisilin. Hentikan penggunaan jika muncul ruam atau kesulitan bernapas.',
      ),
      InfoObatItem(
        nama: 'Vitamin C', kategori: 'Suplemen', color: const Color(0xFF81C784),
        frekuensi: '1x sehari', durasi: 'Sesuai anjuran', waktuMinum: 'Sesudah makan',
        fungsi: 'Membantu meningkatkan daya tahan tubuh, berperan sebagai antioksidan, dan membantu penyerapan zat besi.',
        aturanPakai: 'Konsumsi 1 tablet per hari setelah makan. Tidak perlu diminum saat perut kosong.',
        perhatian: 'Konsumsi berlebihan dapat menyebabkan gangguan pencernaan. Jangan melebihi dosis yang dianjurkan.',
      ),
    ]),
    InfoObatHari(tanggal: ago(10), obatList: [
      InfoObatItem(
        nama: 'Ibuprofen', kategori: 'Pereda Nyeri', color: const Color(0xFFBA68C8),
        frekuensi: '3x sehari', durasi: '3-5 hari', waktuMinum: 'Sesudah makan',
        fungsi: 'Meredakan nyeri ringan hingga sedang, seperti sakit kepala, nyeri haid, nyeri gigi, dan demam.',
        aturanPakai: 'Minum 1 tablet setiap 6-8 jam bersama makanan atau susu untuk menghindari iritasi lambung.',
        perhatian: 'Hindari penggunaan jika memiliki riwayat maag atau tukak lambung. Tidak dianjurkan untuk ibu hamil.',
      ),
    ]),
    InfoObatHari(tanggal: ago(20), obatList: [
      InfoObatItem(
        nama: 'Paracetamol', kategori: 'Pereda Nyeri & Demam', color: const Color(0xFF4CAF82),
        frekuensi: '3-4x sehari', durasi: '3-5 hari', waktuMinum: 'Sesudah makan',
        fungsi: 'Membantu meredakan sakit kepala, nyeri otot, sakit gigi, serta menurunkan demam.',
        aturanPakai: 'Minum 1 tablet setiap 4 hingga 6 jam jika diperlukan. Jangan melebihi 8 tablet dalam 24 jam.',
        perhatian: 'Simpan di tempat sejuk dan kering, jauh dari jangkauan anak-anak.',
      ),
    ]),
  ];
}

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class InfoObatScreen extends StatefulWidget {
  const InfoObatScreen({super.key});

  @override
  State<InfoObatScreen> createState() => _InfoObatScreenState();
}

class _InfoObatScreenState extends State<InfoObatScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', '7 Hari', '30 Hari', '3 Bulan'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<InfoObatHari> _allData = _generateData();

  List<InfoObatHari> get _filteredByDate {
    final now = DateTime.now();
    final cutoffDays = [null, 7, 30, 90][_selectedFilter];
    if (cutoffDays == null) return _allData;
    final cutoff = now.subtract(Duration(days: cutoffDays));
    return _allData.where((d) => d.tanggal.isAfter(cutoff)).toList();
  }

  List<InfoObatHari> get _displayData {
    if (_searchQuery.isEmpty) return _filteredByDate;
    return _filteredByDate.map((hari) {
      final filtered = hari.obatList
          .where((o) => o.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      return InfoObatHari(tanggal: hari.tanggal, obatList: filtered);
    }).where((h) => h.obatList.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Info Obat',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterRow(),
          const SizedBox(height: 8),
          Expanded(
            child: _displayData.isEmpty
                ? const Center(
                    child: Text('Tidak ada obat ditemukan',
                        style: TextStyle(color: Colors.black45, fontSize: 14)))
                : ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: _buildDayGroups(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        decoration: InputDecoration(
          hintText: 'Cari Nama Obat...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[400], size: 20),
                  onPressed: () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final selected = i == _selectedFilter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF2BB673) : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(_filters[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : Colors.black54)),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildDayGroups() {
    final now = DateTime.now();
    final widgets = <Widget>[];

    for (final hari in _displayData) {
      final isToday = _isSameDay(hari.tanggal, now);
      final isYesterday = _isSameDay(hari.tanggal, now.subtract(const Duration(days: 1)));
      final dayLabel = isToday ? 'Hari Ini' : isYesterday ? 'Kemarin' : '';
      final dayStr = '${_dayName(hari.tanggal.weekday)}, ${hari.tanggal.day} ${_monthName(hari.tanggal.month)}';

      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
        child: RichText(
          text: TextSpan(children: [
            if (dayLabel.isNotEmpty)
              TextSpan(
                  text: '$dayLabel · ',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF2BB673))),
            TextSpan(
                text: dayStr.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black45, letterSpacing: 0.5)),
          ]),
        ),
      ));

      for (final obat in hari.obatList) {
        widgets.add(_buildObatCard(obat));
      }
    }

    return widgets;
  }

  Widget _buildObatCard(InfoObatItem obat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailInfoObatScreen(
            obat: DetailObat(
              nama: obat.nama,
              kategori: obat.kategori,
              color: obat.color,
              frekuensi: obat.frekuensi,
              durasi: obat.durasi,
              waktuMinum: obat.waktuMinum,
              fungsi: obat.fungsi,
              aturanPakai: obat.aturanPakai,
              perhatian: obat.perhatian,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: obat.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.medication_rounded, color: obat.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(obat.nama,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 2),
                  Text(obat.kategori,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayName(int weekday) =>
      ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'][weekday - 1];

  String _monthName(int month) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'][month - 1];
}