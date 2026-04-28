import 'package:flutter/material.dart';
import 'package:frontend_pasien/services/api_service.dart';
import 'package:frontend_pasien/models/obat.dart';
import 'detail_info_obat.dart';

// ─── GROUPED OBAT DATA ────────────────────────────────────────────────────

class ObatDay {
  final DateTime tanggal;
  final List<ObatDetail> obatList;

  const ObatDay({required this.tanggal, required this.obatList});
}

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class InfoObatScreen extends StatefulWidget {
  final int pasienId;

  const InfoObatScreen({super.key, required this.pasienId});

  @override
  State<InfoObatScreen> createState() => _InfoObatScreenState();
}

class _InfoObatScreenState extends State<InfoObatScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', '7 Hari', '30 Hari', '3 Bulan'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late Future<List<ObatDay>> _obatFuture;

  @override
  void initState() {
    super.initState();
    _obatFuture = _fetchObat();
  }

  Future<List<ObatDay>> _fetchObat() async {
    try {
      final response = await ApiService.getMedicines(pasienId: widget.pasienId);
      if (!response['success']) {
        throw Exception(response['error'] ?? 'Gagal mengambil data obat');
      }

      // Backend returns PasienJadwalResponse with structure: {PasienID, Nama, Jadwals: [...]}
      final responseData = response['data'] as Map<String, dynamic>;
      final List<dynamic> jadwalsList = responseData['Jadwals'] ?? [];
      final obats = jadwalsList
          .map((item) => ObatDetail.fromJson(item as Map<String, dynamic>))
          .toList();

      // Group medicines by tanggalMulai
      final Map<String, List<ObatDetail>> grouped = {};
      for (var obat in obats) {
        if (obat.status.toLowerCase() == 'aktif') {
          final key = obat.tanggalMulai;
          if (!grouped.containsKey(key)) {
            grouped[key] = [];
          }
          grouped[key]!.add(obat);
        }
      }

      // Convert to ObatDay sorted by date (newest first)
      final List<ObatDay> days = grouped.entries
          .map((e) {
            try {
              final date = DateTime.parse(e.key);
              return ObatDay(tanggal: date, obatList: e.value);
            } catch (e) {
              // Skip invalid dates
              return null;
            }
          })
          .whereType<ObatDay>()
          .toList();

      days.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      return days;
    } catch (e) {
      debugPrint('Error fetching obat: $e');
      rethrow;
    }
  }

  List<ObatDay> _filterData(List<ObatDay> days) {
    final now = DateTime.now();
    final cutoffDays = [null, 7, 30, 90][_selectedFilter];
    List<ObatDay> filtered;

    if (cutoffDays == null) {
      filtered = days;
    } else {
      final cutoff = now.subtract(Duration(days: cutoffDays));
      filtered = days.where((d) => d.tanggal.isAfter(cutoff)).toList();
    }

    if (_searchQuery.isEmpty) return filtered;
    return filtered
        .map((hari) {
          final filteredObats = hari.obatList
              .where(
                (o) => o.namaObat.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
          return filteredObats.isEmpty
              ? null
              : ObatDay(tanggal: hari.tanggal, obatList: filteredObats);
        })
        .whereType<ObatDay>()
        .toList();
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
        title: const Text(
          'Info Obat',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<ObatDay>>(
        future: _obatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2BB673)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal mengambil data obat',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _obatFuture = _fetchObat()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2BB673),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medication, color: Colors.grey[300], size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data obat',
                    style: TextStyle(color: Colors.black45, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final allData = snapshot.data!;
          final displayData = _filterData(allData);

          return Column(
            children: [
              _buildSearchBar(),
              _buildFilterRow(),
              const SizedBox(height: 8),
              Expanded(
                child: displayData.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isNotEmpty
                              ? 'Obat "${_searchQuery}" tidak ditemukan'
                              : 'Tidak ada obat untuk periode ini',
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: _buildDayGroups(displayData),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
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
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6),
        ],
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
                  color: selected
                      ? const Color(0xFF2BB673)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  _filters[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildDayGroups(List<ObatDay> days) {
    final now = DateTime.now();
    final widgets = <Widget>[];

    for (final hari in days) {
      final isToday = _isSameDay(hari.tanggal, now);
      final isYesterday = _isSameDay(
        hari.tanggal,
        now.subtract(const Duration(days: 1)),
      );
      final dayLabel = isToday
          ? 'Hari Ini'
          : isYesterday
          ? 'Kemarin'
          : '';
      final dayStr =
          '${_dayName(hari.tanggal.weekday)}, ${hari.tanggal.day} ${_monthName(hari.tanggal.month)}';

      widgets.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: RichText(
            text: TextSpan(
              children: [
                if (dayLabel.isNotEmpty)
                  TextSpan(
                    text: '$dayLabel · ',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2BB673),
                    ),
                  ),
                TextSpan(
                  text: dayStr.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      for (final obat in hari.obatList) {
        widgets.add(_buildObatCard(obat));
      }
    }

    return widgets;
  }

  Widget _buildObatCard(ObatDetail obat) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailInfoObatScreen(obat: obat)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(
                  obat.kategoriObat,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getCategoryIcon(obat.kategoriObat),
                color: _getCategoryColor(obat.kategoriObat),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obat.namaObat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    obat.kategoriObat.isEmpty ? 'Obat' : obat.kategoriObat,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${obat.frekuensiPerHari} • ${obat.waktuMinum}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  // ─── UTILITIES ────────────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayName(int weekday) => const [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ][weekday];

  String _monthName(int month) => const [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ][month];

  Color _getCategoryColor(String category) {
    if (category.contains('Antibiotik')) return const Color(0xFF4CAF50);
    if (category.contains('Pereda')) return const Color(0xFFFFC107);
    if (category.contains('Suplemen')) return const Color(0xFF2196F3);
    if (category.contains('Flu')) return const Color(0xFF9C27B0);
    if (category.contains('Darah')) return const Color(0xFFF44336);
    return const Color(0xFF607D8B);
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Antibiotik')) return Icons.shield;
    if (category.contains('Pereda')) return Icons.healing;
    if (category.contains('Suplemen')) return Icons.energy_savings_leaf;
    if (category.contains('Flu')) return Icons.thermostat;
    return Icons.medication;
  }
}
