import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/jadwal_rutinitas_model.dart';


class TambahJadwalKonsumsi extends StatefulWidget {
  final JadwalRutinitasItem? jadwalExist; 
  const TambahJadwalKonsumsi({super.key, this.jadwalExist});

  @override
  State<TambahJadwalKonsumsi> createState() => _TambahJadwalKonsumsiState();
}

class _TambahJadwalKonsumsiState extends State<TambahJadwalKonsumsi> {
  // --- KONFIGURASI WARNA ---
  static const Color _bgPage        = Color(0xFFF8FAF9);
  static const Color _green         = Color(0xFF13EC5B);
  static const Color _streakTeal    = Color(0xFF13ECA4);
  static const Color _textPrimary   = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder    = Color(0xFFE2E8F0);
  
  final String baseUrl = "http://10.0.2.2:8080/api";

  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();

  TimeOfDay _waktuMulai   = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _waktuSelesai = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _hariList = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final Set<String> _selectedHari = {};

  @override
  void initState() {
    super.initState();
    // Jika data ada (Mode Edit), isi field secara otomatis
    if (widget.jadwalExist != null) {
      _namaCtrl.text = widget.jadwalExist!.namaAktivitas;
      _waktuMulai = _parseTimeOfDay(widget.jadwalExist!.jamMulai);
      _waktuSelesai = _parseTimeOfDay(widget.jadwalExist!.jamSelesai);
      _selectedHari.addAll(widget.jadwalExist!.pengulangan);
    } else {
      // Default pengulangan hari kerja jika data baru
      _selectedHari.addAll(['Sen', 'Sel', 'Rab', 'Kam', 'Jum']);
    }
  }

  // Fungsi bantu untuk mengubah string jam ke TimeOfDay
  TimeOfDay _parseTimeOfDay(String time) {
    try {
      final parts = time.replaceAll('.', ':').split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickTime({required bool isMulai}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMulai ? _waktuMulai : _waktuSelesai,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: _textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isMulai) {
        _waktuMulai = picked;
      } else {
        _waktuSelesai = picked;
      }
    });
  }

  // --- LOGIKA SIMPAN KE BACKEND ---
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 hari pengulangan.')),
      );
      return;
    }

    final Map<String, dynamic> data = {
      "nama_aktivitas": _namaCtrl.text.trim(),
      "jam_mulai": _formatTime(_waktuMulai),
      "jam_selesai": _formatTime(_waktuSelesai),
      "pengulangan": _selectedHari.toList(),
      "pasien_id": 1, 
    };

    try {
      final url = widget.jadwalExist == null 
          ? '$baseUrl/rutinitas' 
          : '$baseUrl/rutinitas/${widget.jadwalExist!.jadwalRutinitasId}';
      
      final response = widget.jadwalExist == null
          ? await http.post(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: jsonEncode(data))
          : await http.put(Uri.parse(url), headers: {"Content-Type": "application/json"}, body: jsonEncode(data));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) Navigator.pop(context, true);
      } else {
        debugPrint("Gagal simpan: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionLabel('Nama Aktivitas'),
                      const SizedBox(height: 8),
                      _buildNamaField(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _timeColumn('Waktu Mulai', _waktuMulai, true),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _timeColumn('Waktu Selesai', _waktuSelesai, false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _sectionLabel('Pengulangan'),
                      const SizedBox(height: 12),
                      _buildHariSelector(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildSimpanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- WIDGET COMPONENTS ---
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left_rounded, color: _textPrimary),
            style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
          ),
          Expanded(
            child: Text(
              widget.jadwalExist == null ? 'Tambah Jadwal' : 'Edit Jadwal',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textPrimary),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary),
  );

  Widget _buildNamaField() {
    return TextFormField(
      controller: _namaCtrl,
      decoration: InputDecoration(
        hintText: 'Contoh: Olahraga Pagi',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _streakTeal, width: 1.5)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama aktivitas wajib diisi' : null,
    );
  }

  Widget _timeColumn(String label, TimeOfDay time, bool isMulai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickTime(isMulai: isMulai),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _cardBorder)),
            child: Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 16, color: _textSecondary),
                const SizedBox(width: 8),
                Text(_formatTime(time), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHariSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _hariList.map((hari) {
        final selected = _selectedHari.contains(hari);
        return GestureDetector(
          onTap: () => setState(() {
            selected ? _selectedHari.remove(hari) : _selectedHari.add(hari);
          }),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: selected ? _green : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? _green : _cardBorder, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(hari, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? _textPrimary : _textSecondary)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 52,
      child: ElevatedButton(
        onPressed: _simpan,
        style: ElevatedButton.styleFrom(backgroundColor: _green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: const Text('Simpan Jadwal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _textPrimary)),
      ),
    );
  }
}