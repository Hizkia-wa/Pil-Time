import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

// ─── MODEL ───────────────────────────────────────────────────────────────────

enum MedStatus { taken, late, missed }

class MedLog {
  final String name;
  final String instruction;
  final MedStatus status;
  final Color color;

  const MedLog({
    required this.name,
    required this.instruction,
    required this.status,
    this.color = const Color(0xFF15BE77),
  });
}

class DayLog {
  final DateTime date;
  final List<MedLog> logs;
  const DayLog({required this.date, required this.logs});
}

// ─── HELPER FUNCTIONS ───────────────────────────────────────────────────────

List<DayLog> _mapResponseToDayLogs(List<dynamic> response) {
  if (response.isEmpty) return [];

  // Group by tanggal
  final Map<String, List<Map<String, dynamic>>> grouped = {};
  for (final item in response) {
    final tanggal = item['tanggal'] as String?;
    if (tanggal != null) {
      grouped.putIfAbsent(tanggal, () => []);
      grouped[tanggal]!.add(item as Map<String, dynamic>);
    }
  }

  // Convert to DayLog
  final dayLogs = <DayLog>[];
  for (final entry in grouped.entries) {
    final date = DateTime.parse(entry.key);
    final logs = <MedLog>[];

    for (final item in entry.value) {
      final status = item['status'] as String?;
      final namaObat = item['nama_obat'] as String? ?? 'Obat';
      final waktuMinum = item['waktu_minum'] as String?;
      final jadwal = item['jadwal'] as String?;

      // Map status
      MedStatus medStatus;
      if (status == 'Diminum') {
        medStatus = MedStatus.taken;
      } else if (status == 'Terlambat') {
        medStatus = MedStatus.late;
      } else {
        medStatus = MedStatus.missed;
      }

      // Build instruction from waktu_minum or jadwal
      final instruction = waktuMinum ?? jadwal ?? 'Tidak ada waktu';

      logs.add(
        MedLog(name: namaObat, instruction: instruction, status: medStatus),
      );
    }

    dayLogs.add(DayLog(date: date, logs: logs));
  }

  // Sort by date descending (newest first)
  dayLogs.sort((a, b) => b.date.compareTo(a.date));
  return dayLogs;
}

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class RiwayatKonsumsiObatScreen extends StatefulWidget {
  const RiwayatKonsumsiObatScreen({super.key});

  @override
  State<RiwayatKonsumsiObatScreen> createState() =>
      _RiwayatKonsumsiObatScreenState();
}

class _RiwayatKonsumsiObatScreenState extends State<RiwayatKonsumsiObatScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', '7 Hari', '30 Hari', '3 Bulan'];

  List<DayLog> _allData = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session == null) {
        setState(() {
          _errorMsg = 'User session tidak ditemukan';
          _isLoading = false;
        });
        return;
      }

      final pasienId = session['pasien_id'] as int;
      await _fetchRiwayat(pasienId);
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() {
        _errorMsg = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchRiwayat(int pasienId) async {
    try {
      final token = await AuthService.getToken();
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      final response = await http
          .get(
            Uri.parse("${ApiService.baseUrl}/api/pasien/riwayat"),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final List<dynamic> data = responseBody['data'] ?? [];

        if (data.isEmpty) {
          setState(() {
            _allData = [];
            _isLoading = false;
            _errorMsg = null;
          });
        } else {
          final dayLogs = _mapResponseToDayLogs(data);
          setState(() {
            _allData = dayLogs;
            _isLoading = false;
            _errorMsg = null;
          });
        }
      } else {
        final Map<String, dynamic> errorBody = jsonDecode(response.body);
        final errorMsg =
            errorBody['message'] ??
            errorBody['error'] ??
            'Server Error ${response.statusCode}';
        debugPrint("Error Response: ${response.statusCode} - $errorMsg");
        setState(() {
          _errorMsg = errorMsg;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Exception in _fetchRiwayat: $e");
      setState(() {
        _errorMsg = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // ── Compliance: selalu dari SEMUA data, tidak terpengaruh filter ──
  int get _takenDoses => _allData
      .expand((d) => d.logs)
      .where((l) => l.status == MedStatus.taken || l.status == MedStatus.late)
      .length;
  int get _totalDoses => _allData.expand((d) => d.logs).length;
  double get _compliancePercent =>
      _totalDoses == 0 ? 0 : _takenDoses / _totalDoses;

  // ── Daftar obat: berubah sesuai filter ──
  List<DayLog> get _filteredData {
    final now = DateTime.now();
    final cutoffDays = [null, 7, 30, 90][_selectedFilter];
    if (cutoffDays == null) return _allData;
    final cutoff = now.subtract(Duration(days: cutoffDays));
    return _allData.where((d) => d.date.isAfter(cutoff)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: SafeArea(
        child: Column(
          children: [
            // ─── APP BAR (CUSTOM ERGONOMIC) ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 24, 4),
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
                    'Riwayat Kepatuhan',
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
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF15BE77),
          strokeWidth: 3,
        ),
      );
    }

    if (_errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded, 
                size: 56, 
                color: Color(0xFFFF4D4D),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Data',
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13, 
                  color: Color(0xFF64748B),
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadData();
                },
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

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        _buildComplianceCard(),
        _buildFilterRow(),
        const SizedBox(height: 12),
        ..._buildDayLogs(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildComplianceCard() {
    final compPercent = (_compliancePercent * 100).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'RATA-RATA TINGKAT KEPATUHAN',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$compPercent%',
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.bold,
              color: Color(0xFF15BE77),
              fontFamily: 'Roboto',
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$_takenDoses / $_totalDoses Dosis Terkonsumsi',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF15BE77),
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _compliancePercent,
              minHeight: 10,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF15BE77)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 4),
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
                      ? const Color(0xFF15BE77)
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

  List<Widget> _buildDayLogs() {
    if (_filteredData.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
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
                    Icons.history_toggle_off_rounded,
                    color: Color(0xFF94A3B8),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada riwayat obat',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Riwayat konsumsi obat Anda akan terekam otomatis di sini.',
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
        ),
      ];
    }

    final now = DateTime.now();
    final widgets = <Widget>[];

    for (final day in _filteredData) {
      final isToday = _isSameDay(day.date, now);
      final isYesterday = _isSameDay(
        day.date,
        now.subtract(const Duration(days: 1)),
      );
      final dayLabel = isToday
          ? 'Hari Ini'
          : isYesterday
          ? 'Kemarin'
          : '';
      final dayStr =
          '${_dayName(day.date.weekday)}, ${day.date.day} ${_monthName(day.date.month)}';

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

      for (final log in day.logs) {
        widgets.add(_buildMedCard(log));
      }
    }

    return widgets;
  }

  Widget _buildMedCard(MedLog log) {
    final Color barColor;
    final Color iconBg;
    final Color iconColor;
    final IconData iconData;
    final String statusLabel;

    switch (log.status) {
      case MedStatus.taken:
        barColor = const Color(0xFF15BE77); // Emerald Green
        iconBg = const Color(0xFFE8F8F1);
        iconColor = const Color(0xFF15BE77);
        iconData = Icons.check_circle_rounded;
        statusLabel = 'Tepat Waktu';
        break;
      case MedStatus.late:
        barColor = const Color(0xFFF59E0B); // Amber
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.watch_later_rounded;
        statusLabel = 'Terlambat';
        break;
      case MedStatus.missed:
        barColor = const Color(0xFFEF4444); // Crimson Red
        iconBg = const Color(0xFFFEF2F2);
        iconColor = const Color(0xFFEF4444);
        iconData = Icons.cancel_rounded;
        statusLabel = 'Terlewat';
        break;
    }

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
      child: Row(
        children: [
          // Left bar accent
          Container(
            width: 6,
            height: 72,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
            ),
          ),
          
          // Icon obat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.medication_rounded, color: iconColor, size: 24),
            ),
          ),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  log.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.instruction,
                        style: const TextStyle(
                          fontSize: 12, 
                          color: Color(0xFF64748B),
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
          
          // Check icon status
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: Icon(iconData, color: iconColor, size: 24),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayName(int weekday) => [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ][weekday - 1];

  String _monthName(int month) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][month - 1];
}
