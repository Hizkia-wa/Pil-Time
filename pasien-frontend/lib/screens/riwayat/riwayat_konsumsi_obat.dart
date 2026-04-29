import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../services/auth_service.dart';

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
    this.color = const Color(0xFF4CAF82),
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

  int? _pasienId;
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
      setState(() => _pasienId = pasienId);

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
            Uri.parse(
              "http://10.0.2.2:8080/api/pasien/riwayat",
            ),
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Backend returns { "data": [...] }
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
          'Riwayat',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Data',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMsg!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildComplianceCard(),
        _buildFilterRow(),
        const SizedBox(height: 8),
        ..._buildDayLogs(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Rataan Tingkat Kepatuhan',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_compliancePercent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2BB673),
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_takenDoses / $_totalDoses Dosis',
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _compliancePercent,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8F5EE),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2BB673)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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

  List<Widget> _buildDayLogs() {
    if (_filteredData.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Tidak ada riwayat untuk periode ini',
              style: TextStyle(color: Colors.black45, fontSize: 14),
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

      for (final log in day.logs) {
        widgets.add(_buildMedCard(log));
      }
    }

    return widgets;
  }

  Widget _buildMedCard(MedLog log) {
    // ── Warna & icon berdasarkan status ──
    final Color barColor;
    final Color iconBg;
    final Color iconColor;
    final IconData iconData;

    switch (log.status) {
      case MedStatus.taken:
        barColor = const Color(0xFF2BB673);
        iconBg = const Color(0xFFE6F7EF);
        iconColor = const Color(0xFF2BB673);
        iconData = Icons.check_box_rounded;
        break;
      case MedStatus.late:
        barColor = const Color(0xFFFFA726);
        iconBg = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFFFA726);
        iconData = Icons.watch_later_rounded;
        break;
      case MedStatus.missed:
        barColor = const Color(0xFFE53935);
        iconBg = const Color(0xFFFFEBEE);
        iconColor = const Color(0xFFE53935);
        iconData = Icons.warning_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Accent bar kiri
          Container(
            width: 5,
            height: 64,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(14),
              ),
            ),
          ),
          // Icon obat
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.medication_rounded, color: iconColor, size: 22),
            ),
          ),
          // Nama & instruksi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  log.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  log.status == MedStatus.missed
                      ? 'Terlewat'
                      : log.status == MedStatus.late
                      ? 'Terlambat, ${log.instruction}'
                      : 'Tepat waktu, ${log.instruction}',
                  style: TextStyle(fontSize: 12, color: iconColor),
                ),
              ],
            ),
          ),
          // Status icon
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
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
