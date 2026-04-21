import 'package:flutter/material.dart';
import '../../models/jadwal_rutinitas_model.dart';

class EditRutinitasScreen extends StatefulWidget {
  final JadwalRutinitasItem item;

  const EditRutinitasScreen({super.key, required this.item});

  @override
  State<EditRutinitasScreen> createState() => _EditRutinitasScreenState();
}

class _EditRutinitasScreenState extends State<EditRutinitasScreen> {
  // ── Warna ────────────────────────────────────────────────────────────────
  static const Color _bgPage        = Color(0xFFF8FAF9);
  static const Color _green         = Color(0xFF13EC5B);
  static const Color _streakTeal    = Color(0xFF13ECA4);
  static const Color _textPrimary   = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder    = Color(0xFFE2E8F0);
  // ─────────────────────────────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;

  late TimeOfDay _waktuMulai;
  late TimeOfDay _waktuSelesai;

  final List<String> _hariList = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  late Set<String> _selectedHari;

  @override
  void initState() {
    super.initState();
    // Isi semua field dengan data lama
    _namaCtrl = TextEditingController(text: widget.item.namaAktivitas);

    final mulai   = widget.item.jamMulai.split(':');
    final selesai = widget.item.jamSelesai.split(':');
    _waktuMulai   = TimeOfDay(hour: int.parse(mulai[0]),   minute: int.parse(mulai[1]));
    _waktuSelesai = TimeOfDay(hour: int.parse(selesai[0]), minute: int.parse(selesai[1]));

    _selectedHari = Set<String>.from(widget.item.pengulangan);
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
            primary: Color(0xFF13EC5B),
            onPrimary: Color(0xFF0F172A),
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

  void _simpanPerubahan() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 hari pengulangan.')),
      );
      return;
    }

    final updatedItem = JadwalRutinitasItem(
      jadwalRutinitasId: widget.item.jadwalRutinitasId,
      namaAktivitas: _namaCtrl.text.trim(),
      jamMulai: _formatTime(_waktuMulai),
      jamSelesai: _formatTime(_waktuSelesai),
      pengulangan: _hariList.where(_selectedHari.contains).toList(),
      status: widget.item.status,
    );

    Navigator.pop(context, updatedItem);
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Waktu Mulai'),
                                const SizedBox(height: 8),
                                _buildTimePicker(
                                  value: _formatTime(_waktuMulai),
                                  onTap: () => _pickTime(isMulai: true),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionLabel('Waktu Selesai'),
                                const SizedBox(height: 8),
                                _buildTimePicker(
                                  value: _formatTime(_waktuSelesai),
                                  onTap: () => _pickTime(isMulai: false),
                                ),
                              ],
                            ),
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

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(Icons.chevron_left_rounded, color: _textPrimary),
            ),
          ),
          const Expanded(
            child: Text(
              'Edit Rutinitas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textPrimary,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textPrimary,
          fontFamily: 'Inter',
        ),
      );

  Widget _buildNamaField() {
    return TextFormField(
      controller: _namaCtrl,
      style: const TextStyle(fontSize: 14, color: _textPrimary, fontFamily: 'Inter'),
      decoration: InputDecoration(
        hintText: 'Contoh: Olahraga Pagi',
        hintStyle: const TextStyle(color: _textSecondary, fontSize: 14, fontFamily: 'Inter'),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _streakTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Nama aktivitas wajib diisi' : null,
    );
  }

  Widget _buildTimePicker({required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 16, color: _textSecondary),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: selected ? _green : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: selected ? _green : _cardBorder,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              hari,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? _textPrimary : _textSecondary,
                fontFamily: 'Inter',
              ),
            ),
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
        onPressed: _simpanPerubahan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          elevation: 4,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: const Text(
          'Simpan Perubahan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}