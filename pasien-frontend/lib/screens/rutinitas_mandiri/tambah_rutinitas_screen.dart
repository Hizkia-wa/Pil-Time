import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../bloc/rutinitas/rutinitas_bloc.dart';
import '../../bloc/rutinitas/rutinitas_event.dart';
import '../../bloc/rutinitas/rutinitas_state.dart';
import '../../utils/dialog_helper.dart';
import '../../widgets/lansia_time_picker.dart';

class TambahRutinitasScreen extends StatefulWidget {
  final dynamic rutinitas;
  const TambahRutinitasScreen({super.key, this.rutinitas});

  @override
  State<TambahRutinitasScreen> createState() => _TambahRutinitasScreenState();
}

class _TambahRutinitasScreenState extends State<TambahRutinitasScreen> {
  // ── Warna & Konstanta ───────────────────────────────────────────────────
  static const Color _bgPage = Color(0xFFF8FAF9);
  static const Color _green = Color(0xFF13EC5B);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  TimeOfDay _waktuMulai = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _waktuSelesai = const TimeOfDay(hour: 8, minute: 0);

  final List<String> _hariList = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
  final Set<String> _selectedHari = {'Sen', 'Sel', 'Rab', 'Kam', 'Jum'};

  int? _pasienId;
  bool _isSaving = false;
  bool _isLoading = true;
  late final RutinitasBloc _rutinitasBloc;

  @override
  void initState() {
    super.initState();
    _rutinitasBloc = RutinitasBloc();
    if (widget.rutinitas != null) {
      _namaCtrl.text = widget.rutinitas['nama_rutinitas'] ?? '';
      
      String desc = widget.rutinitas['deskripsi'] ?? '';
      if (desc.contains(' (Hari: ')) {
        final parts = desc.split(' (Hari: ');
        _deskripsiCtrl.text = parts.first;
        final dayPart = parts.last.replaceAll(')', '');
        final days = dayPart.split(', ').map((d) => d.trim()).toSet();
        _selectedHari.clear();
        _selectedHari.addAll(days);
      } else if (desc.startsWith('Rutinitas harian. Hari: ')) {
        _deskripsiCtrl.text = '';
        if (desc.contains('Hari: ')) {
          final dayPart = desc.split('Hari: ').last.split('.').first;
          final days = dayPart.split(', ').map((d) => d.trim()).toSet();
          _selectedHari.clear();
          _selectedHari.addAll(days);
        }
      } else {
        _deskripsiCtrl.text = desc;
      }

      final timeStr = widget.rutinitas['waktu_reminder'] ?? '07:00';
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        _waktuMulai = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        _waktuSelesai = TimeOfDay(hour: (int.parse(parts[0]) + 1) % 24, minute: int.parse(parts[1]));
      }

      if (desc.contains(' Waktu: ')) {
        final timePart = desc.split(' Waktu: ').last.trim();
        final timeClean = timePart.replaceAll('.', ''); // clean trailing periods if any
        final times = timeClean.split(' - ');
        if (times.length >= 2) {
          final startParts = times[0].split(':');
          final endParts = times[1].split(':');
          if (startParts.length >= 2 && endParts.length >= 2) {
            try {
              _waktuMulai = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
              _waktuSelesai = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
            } catch (e) {
              debugPrint("Error parsing time range: $e");
            }
          }
        }
      }
    }
    _loadPasienSession();
  }

  Future<void> _loadPasienSession() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null && mounted) {
        setState(() {
          _pasienId = session['pasien_id'] as int;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading pasien session: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _deskripsiCtrl.dispose();
    _rutinitasBloc.close();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // Validasi agar waktu selesai tidak sebelum waktu mulai
  bool _isValidTimeRange() {
    final double start = _waktuMulai.hour + _waktuMulai.minute / 60.0;
    final double end = _waktuSelesai.hour + _waktuSelesai.minute / 60.0;
    return end > start;
  }

  Future<void> _pickTime({required bool isMulai}) async {
    final picked = await showLansiaTimePicker(
      context: context,
      initialTime: isMulai ? _waktuMulai : _waktuSelesai,
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

  // ── Fungsi Simpan (Kirim Data ke Backend) ────────────────────────────────
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isValidTimeRange()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu selesai harus setelah waktu mulai!'),
        ),
      );
      return;
    }

    if (_selectedHari.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal 1 hari pengulangan.')),
      );
      return;
    }

    if (_pasienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session tidak ditemukan. Silakan login kembali.'),
        ),
      );
      return;
    }

    // Build deskripsi from selected days
    final String hariStr = _selectedHari.join(', ');
    final String deskripsi = _deskripsiCtrl.text.trim().isNotEmpty
        ? '${_deskripsiCtrl.text.trim()} (Hari: $hariStr)'
        : 'Rutinitas harian. Hari: $hariStr. Waktu: ${_formatTime(_waktuMulai)} - ${_formatTime(_waktuSelesai)}';

    final Map<String, dynamic> payload = {
      "pasien_id": _pasienId,
      "nama_rutinitas": _namaCtrl.text.trim(),
      "deskripsi": deskripsi,
      "waktu_reminder": _formatTime(_waktuMulai),
    };

    final isEdit = widget.rutinitas != null;
    if (isEdit) {
      _rutinitasBloc.add(UpdateRutinitasSehat(id: widget.rutinitas['id'], payload: payload));
    } else {
      _rutinitasBloc.add(CreateRutinitasSehat(payload));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _bgPage,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.rutinitas != null ? 'Edit Rutinitas' : 'Tambah Rutinitas',
          style: const TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocConsumer<RutinitasBloc, RutinitasState>(
          bloc: _rutinitasBloc,
          listener: (context, state) {
            if (state is RutinitasActionLoading) {
              setState(() {
                _isSaving = true;
              });
            } else if (state is RutinitasActionSuccess) {
              setState(() {
                _isSaving = false;
              });
              DialogHelper.showSuccessDialog(
                context: context,
                title: 'Berhasil',
                message: state.message,
                onClose: () => Navigator.pop(context, true),
              );
            } else if (state is RutinitasActionFailure) {
              setState(() {
                _isSaving = false;
              });
              DialogHelper.showErrorDialog(
                context: context,
                title: 'Gagal Menyimpan',
                message: state.error,
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Nama Rutinitas'),
                          const SizedBox(height: 10),
                          _buildNamaField(),
                          const SizedBox(height: 24),
                          _sectionLabel('Deskripsi', isRequired: false),
                          const SizedBox(height: 10),
                          _buildDeskripsiField(),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTimeInput(
                                  'Waktu Mulai',
                                  _waktuMulai,
                                  true,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTimeInput(
                                  'Waktu Selesai',
                                  _waktuSelesai,
                                  false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _sectionLabel('Pengulangan Hari'),
                          const SizedBox(height: 12),
                          _buildHariSelector(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildSimpanButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── UI Helpers ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String text, {bool isRequired = true}) => RichText(
    text: TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: _textPrimary,
        fontFamily: 'Inter',
      ),
      children: [
        if (isRequired)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          )
        else
          const TextSpan(
            text: ' (Opsional)',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
      ],
    ),
  );

  Widget _buildNamaField() {
    return TextFormField(
      controller: _namaCtrl,
      decoration: InputDecoration(
        hintText: 'Misal: Yoga Pagi',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 2),
        ),
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Nama rutinitas tidak boleh kosong' : null,
    );
  }

  Widget _buildDeskripsiField() {
    return TextFormField(
      controller: _deskripsiCtrl,
      decoration: InputDecoration(
        hintText: 'Contoh: Olahraga ringan di pagi hari',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _green, width: 2),
        ),
      ),
      maxLines: 2,
      minLines: 1,
    );
  }

  Widget _buildTimeInput(String label, TimeOfDay time, bool isMulai) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 8),
        _buildTimePickerCard(
          value: _formatTime(time),
          onTap: () => _pickTime(isMulai: isMulai),
        ),
      ],
    );
  }

  Widget _buildTimePickerCard({
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 18, color: _green),
            const SizedBox(width: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHariSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _hariList.map((hari) {
        final isSelected = _selectedHari.contains(hari);
        return GestureDetector(
          onTap: () => setState(
            () => isSelected
                ? _selectedHari.remove(hari)
                : _selectedHari.add(hari),
          ),
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? _green : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? _green : _cardBorder),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              hari,
              style: TextStyle(
                color: isSelected ? Colors.white : _textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSimpanButton() {
    return Container(
      width: double.infinity,
      height: 55,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _simpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.rutinitas != null ? 'Simpan Perubahan' : 'Simpan Rutinitas',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
