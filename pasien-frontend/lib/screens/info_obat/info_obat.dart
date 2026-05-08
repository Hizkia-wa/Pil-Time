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

      final responseData = response['data'] as Map<String, dynamic>;
      final List<dynamic> jadwalsList = responseData['jadwals'] ?? [];
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
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: SafeArea(
        child: FutureBuilder<List<ObatDay>>(
          future: _obatFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF15BE77),
                  strokeWidth: 3,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFFF4D4D),
                        size: 56,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Gagal mengambil data obat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _obatFuture = _fetchObat()),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF15BE77),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final allData = snapshot.data ?? [];
            final displayData = _filterData(allData);

            return Column(
              children: [
                // ─── APP BAR (CUSTOM ERGONOMIC) ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 24, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          color: Color(0xFF0F172A),
                          size: 32,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Info Obat',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSearchBar(),
                _buildFilterRow(),
                const SizedBox(height: 12),
                
                Expanded(
                  child: displayData.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.search_off_rounded,
                                    color: Color(0xFF94A3B8),
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isNotEmpty
                                      ? 'Obat "${_searchQuery}" tidak ditemukan'
                                      : 'Tidak ada obat untuk periode ini',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Coba cari dengan kata kunci lain atau pilih saringan periode yang berbeda.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                    fontFamily: 'Inter',
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 24),
                          children: _buildDayGroups(displayData),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF0F172A),
          fontFamily: 'Inter',
        ),
        decoration: InputDecoration(
          hintText: 'Cari Nama Obat Anda...',
          hintStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Inter',
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 24,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchQuery = '';
                    _searchController.clear();
                  }),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
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
      margin: const EdgeInsets.fromLTRB(20, 6, 20, 6),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFF15BE77) // Emerald Green resmi
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF15BE77).withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _filters[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : const Color(0xFF64748B),
                    fontFamily: 'Inter',
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF15BE77),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  children: [
                    if (dayLabel.isNotEmpty)
                      TextSpan(
                        text: '$dayLabel · ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15BE77),
                          fontFamily: 'Inter',
                        ),
                      ),
                    TextSpan(
                      text: dayStr.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
    final color = _getCategoryColor(obat.kategoriObat);
    final bgColor = _getCategoryBgColor(obat.kategoriObat);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailInfoObatScreen(obat: obat)),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getCategoryIcon(obat.kategoriObat),
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obat.namaObat,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Roboto',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            obat.kategoriObat.isEmpty ? 'Umum' : obat.kategoriObat,
                            style: TextStyle(
                              fontSize: 12, 
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${obat.frekuensiPerHari} • ${obat.waktuMinum}',
                              style: const TextStyle(
                                fontSize: 12, 
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Inter',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded, 
                  color: Color(0xFF94A3B8), 
                  size: 28,
                ),
              ],
            ),
          ),
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
    final lower = category.toLowerCase();
    if (lower.contains('antibiotik')) return const Color(0xFF10B981); // Emerald
    if (lower.contains('pereda') || lower.contains('nyeri')) return const Color(0xFFF97316); // Orange
    if (lower.contains('suplemen') || lower.contains('vitamin')) return const Color(0xFF3B82F6); // Blue
    if (lower.contains('flu') || lower.contains('batuk')) return const Color(0xFF8B5CF6); // Purple
    if (lower.contains('darah') || lower.contains('tensi')) return const Color(0xFFEF4444); // Red
    return const Color(0xFF64748B); // Slate
  }

  Color _getCategoryBgColor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('antibiotik')) return const Color(0xFFE8F8F1); // Soft Emerald
    if (lower.contains('pereda') || lower.contains('nyeri')) return const Color(0xFFFFF7ED); // Soft Orange
    if (lower.contains('suplemen') || lower.contains('vitamin')) return const Color(0xFFEFF6FF); // Soft Blue
    if (lower.contains('flu') || lower.contains('batuk')) return const Color(0xFFF5F3FF); // Soft Purple
    if (lower.contains('darah') || lower.contains('tensi')) return const Color(0xFFFEF2F2); // Soft Red
    return const Color(0xFFF1F5F9); // Soft Slate
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('antibiotik')) return Icons.shield_rounded;
    if (lower.contains('pereda') || lower.contains('nyeri')) return Icons.healing_rounded;
    if (lower.contains('suplemen') || lower.contains('vitamin')) return Icons.energy_savings_leaf_rounded;
    if (lower.contains('flu') || lower.contains('batuk')) return Icons.thermostat_rounded;
    return Icons.medication_rounded;
  }
}
