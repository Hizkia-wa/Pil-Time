import 'package:flutter/material.dart';

// ─── MODEL ───────────────────────────────────────────────────────────────────

enum MedStatus { taken, missed }

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

// ─── DUMMY DATA ───────────────────────────────────────────────────────────────

List<DayLog> _generateDummyData() {
  final now = DateTime.now();
  DateTime ago(int days) => now.subtract(Duration(days: days));

  MedLog taken(String name, String jam) =>
      MedLog(name: name, instruction: 'Diminum, $jam', status: MedStatus.taken);
  MedLog missed(String name, String jam) =>
      MedLog(name: name, instruction: 'Diminum, $jam', status: MedStatus.missed);

  return [
    DayLog(date: ago(0),  logs: [taken('Paracetamol', '08:10'), taken('Amoxicillin', '08:10')]),
    DayLog(date: ago(1),  logs: [taken('Paracetamol', '08:10'), missed('Amoxicillin', '08:10'), taken('Paracetamol', '12:10')]),
    DayLog(date: ago(2),  logs: [taken('Paracetamol', '08:10'), taken('Vitamin C', '08:10')]),
    DayLog(date: ago(3),  logs: [missed('Paracetamol', '08:10'), taken('Amoxicillin', '08:10')]),
    DayLog(date: ago(4),  logs: [taken('Paracetamol', '08:10'), taken('Amoxicillin', '12:10')]),
    DayLog(date: ago(5),  logs: [taken('Vitamin C', '08:10'), missed('Paracetamol', '20:00')]),
    DayLog(date: ago(6),  logs: [taken('Paracetamol', '08:10'), taken('Amoxicillin', '08:10')]),
    DayLog(date: ago(10), logs: [taken('Paracetamol', '08:10'), missed('Vitamin C', '12:10')]),
    DayLog(date: ago(15), logs: [missed('Amoxicillin', '08:10'), taken('Paracetamol', '08:10')]),
    DayLog(date: ago(20), logs: [taken('Paracetamol', '08:10'), taken('Vitamin C', '20:00')]),
    DayLog(date: ago(29), logs: [taken('Amoxicillin', '08:10'), missed('Paracetamol', '12:10')]),
    DayLog(date: ago(45), logs: [taken('Paracetamol', '08:10'), taken('Amoxicillin', '08:10')]),
    DayLog(date: ago(60), logs: [missed('Vitamin C', '08:10'), taken('Paracetamol', '20:00')]),
    DayLog(date: ago(80), logs: [taken('Paracetamol', '08:10'), missed('Amoxicillin', '08:10')]),
  ];
}

final List<DayLog> _allData = _generateDummyData();

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class RiwayatKonsumsiObatScreen extends StatefulWidget {
  const RiwayatKonsumsiObatScreen({super.key});

  @override
  State<RiwayatKonsumsiObatScreen> createState() => _RiwayatKonsumsiObatScreenState();
}

class _RiwayatKonsumsiObatScreenState extends State<RiwayatKonsumsiObatScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['Semua', '7 Hari', '30 Hari', '3 Bulan'];

  // ── Compliance: selalu dari SEMUA data, tidak terpengaruh filter ──
  int get _takenDoses =>
      _allData.expand((d) => d.logs).where((l) => l.status == MedStatus.taken).length;
  int get _totalDoses => _allData.expand((d) => d.logs).length;
  double get _compliancePercent => _totalDoses == 0 ? 0 : _takenDoses / _totalDoses;

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
        title: const Text('Riwayat',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildComplianceCard(),
          _buildFilterRow(),
          const SizedBox(height: 8),
          ..._buildDayLogs(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          const Text('Rataan Tingkat Kepatuhan',
              style: TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('${(_compliancePercent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700, color: Color(0xFF2BB673), height: 1.1)),
          const SizedBox(height: 6),
          Text('$_takenDoses / $_totalDoses Dosis',
              style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w500)),
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

  List<Widget> _buildDayLogs() {
    if (_filteredData.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Tidak ada riwayat untuk periode ini',
                style: TextStyle(color: Colors.black45, fontSize: 14)),
          ),
        )
      ];
    }

    final now = DateTime.now();
    final widgets = <Widget>[];

    for (final day in _filteredData) {
      final isToday = _isSameDay(day.date, now);
      final isYesterday = _isSameDay(day.date, now.subtract(const Duration(days: 1)));
      final dayLabel = isToday ? 'Hari Ini' : isYesterday ? 'Kemarin' : '';
      final dayStr = '${_dayName(day.date.weekday)}, ${day.date.day} ${_monthName(day.date.month)}';

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

      for (final log in day.logs) {
        widgets.add(_buildMedCard(log));
      }
    }

    return widgets;
  }

  Widget _buildMedCard(MedLog log) {
    final isMissed = log.status == MedStatus.missed;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 5, height: 64,
            decoration: BoxDecoration(
              color: isMissed ? const Color(0xFFE53935) : log.color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: log.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.medication_rounded, color: log.color, size: 22),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(log.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(log.instruction, style: const TextStyle(fontSize: 12, color: Colors.black45)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: isMissed ? const Color(0xFFE53935) : const Color(0xFF2BB673),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(isMissed ? Icons.close : Icons.check, color: Colors.white, size: 18),
            ),
          ),
        ],
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