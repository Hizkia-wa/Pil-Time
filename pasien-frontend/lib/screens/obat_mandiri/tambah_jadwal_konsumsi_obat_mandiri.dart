import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../bloc/rutinitas/rutinitas_bloc.dart';
import '../../bloc/rutinitas/rutinitas_event.dart';
import '../../bloc/rutinitas/rutinitas_state.dart';
import '../../widgets/lansia_time_picker.dart';

class TambahJadwalKonsumsi extends StatefulWidget {
  final dynamic obat;
  const TambahJadwalKonsumsi({super.key, this.obat});

  @override
  State<TambahJadwalKonsumsi> createState() => _TambahJadwalKonsumsiState();
}

class _TambahJadwalKonsumsiState extends State<TambahJadwalKonsumsi> {
  // --- KONFIGURASI WARNA ---
  static const Color _bgPage = Color(0xFFF8FAF9);
  static const Color _green = Color(0xFF13EC5B);
  static const Color _streakTeal = Color(0xFF13ECA4);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);
  static const Color _cardBorder = Color(0xFFE2E8F0);

  final _formKey = GlobalKey<FormState>();
  final _namaObatCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _frekuensiCtrl = TextEditingController();
  final _durasiHariCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();

  int? _pasienId;
  bool _isSaving = false;
  File? _pickedImage;
  final List<String?> _selectedCustomTimes = [null, null, null, null];
  late final RutinitasBloc _rutinitasBloc;

  final List<String> _frekuensiOptions = [
    '1x sehari',
    '2x sehari',
    '3x sehari',
    '4x sehari',
  ];

  @override
  void initState() {
    super.initState();
    _rutinitasBloc = RutinitasBloc();
    if (widget.obat != null) {
      _namaObatCtrl.text = widget.obat['nama_obat'] ?? '';
      _dosisCtrl.text = widget.obat['fungsi'] ?? '';
      _frekuensiCtrl.text = widget.obat['frekuensi'] ?? '1x sehari';
      _durasiHariCtrl.text = (widget.obat['durasi_hari'] ?? '7').toString();
      _catatanCtrl.text = widget.obat['catatan'] ?? '';

      final List<dynamic>? times = widget.obat['pengingat'];
      if (times != null) {
        for (int i = 0; i < times.length && i < _selectedCustomTimes.length; i++) {
          _selectedCustomTimes[i] = times[i]?.toString();
        }
      }
    } else {
      _frekuensiCtrl.text = '1x sehari';
      _durasiHariCtrl.text = '7';
    }
    _loadPasienSession();
  }

  Future<void> _loadPasienSession() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null && session['pasien_id'] != null) {
        setState(() {
          _pasienId = session['pasien_id'] as int;
        });
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  @override
  void dispose() {
    _namaObatCtrl.dispose();
    _dosisCtrl.dispose();
    _frekuensiCtrl.dispose();
    _durasiHariCtrl.dispose();
    _catatanCtrl.dispose();
    _rutinitasBloc.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library, color: _green),
                title: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w500, color: _textPrimary)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: _green),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w500, color: _textPrimary)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _convertImageToBase64(File imageFile) {
    final bytes = imageFile.readAsBytesSync();
    return base64Encode(bytes);
  }

  // Helper: Extract jumlah frekuensi dari string (misal "3x sehari" -> 3)
  int _getRequiredPengingat() {
    final frekuensi = _frekuensiCtrl.text;
    if (frekuensi.startsWith('1x')) return 1;
    if (frekuensi.startsWith('2x')) return 2;
    if (frekuensi.startsWith('3x')) return 3;
    if (frekuensi.startsWith('4x')) return 4;
    return 1;
  }

  Future<void> _selectTime(int index) async {
    final initialTime = _selectedCustomTimes[index] != null
        ? TimeOfDay(
            hour: int.parse(_selectedCustomTimes[index]!.split(':')[0]),
            minute: int.parse(_selectedCustomTimes[index]!.split(':')[1]),
          )
        : TimeOfDay.now();

    final TimeOfDay? picked = await showLansiaTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      final String formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

      // Cek apakah waktu ini sudah digunakan di slot lain
      final int? duplicateSlot = _findDuplicateSlot(formattedTime, excludeIndex: index);
      if (duplicateSlot != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Waktu $formattedTime sudah dipakai di Waktu Ke-${duplicateSlot + 1}. Pilih waktu yang berbeda.',
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
        return; // Tolak pilihan — jangan update state
      }

      setState(() {
        _selectedCustomTimes[index] = formattedTime;
      });
    }
  }

  /// Kembalikan index slot yang sudah memakai [time], kecuali [excludeIndex].
  /// Kembalikan null jika tidak ada duplikat.
  int? _findDuplicateSlot(String time, {required int excludeIndex}) {
    final requiredCount = _getRequiredPengingat();
    for (int i = 0; i < requiredCount; i++) {
      if (i == excludeIndex) continue;
      if (_selectedCustomTimes[i] == time) return i;
    }
    return null;
  }

  // --- LOGIKA SIMPAN KE BACKEND ---
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frekuensiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih frekuensi penggunaan.')),
      );
      return;
    }

    final requiredPengingat = _getRequiredPengingat();
    final List<String> filledTimes = [];
    for (int i = 0; i < requiredPengingat; i++) {
      if (_selectedCustomTimes[i] != null) {
        filledTimes.add(_selectedCustomTimes[i]!);
      }
    }

    if (filledTimes.length != requiredPengingat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tentukan semua $requiredPengingat waktu pengingat untuk ${_frekuensiCtrl.text}',
          ),
        ),
      );
      return;
    }

    // Validasi: semua waktu harus unik
    final uniqueTimes = filledTimes.toSet();
    if (uniqueTimes.length != filledTimes.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Setiap waktu pengingat harus berbeda. Silakan ubah waktu yang duplikat.',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_pasienId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session tidak ditemukan. Silakan login ulang.'),
        ),
      );
      return;
    }

    final Map<String, dynamic> data = {
      "nama_obat": _namaObatCtrl.text.trim(),
      "dosis": _dosisCtrl.text.trim(),
      "pengingat": filledTimes,
      "frekuensi": _frekuensiCtrl.text.trim(),
      "durasi_hari": int.parse(_durasiHariCtrl.text),
      "catatan": _catatanCtrl.text.trim(),
      "gambar": _pickedImage != null
          ? _convertImageToBase64(_pickedImage!)
          : "",
      "pasien_id": _pasienId,
    };

    final isEdit = widget.obat != null;
    if (isEdit) {
      _rutinitasBloc.add(UpdateObatMandiri(obatId: widget.obat['obat_id'], data: data));
    } else {
      _rutinitasBloc.add(CreateObatMandiri(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF15BE77),
                ),
              );
              Navigator.pop(context, true);
            } else if (state is RutinitasActionFailure) {
              setState(() {
                _isSaving = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red[400],
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Obat
                      _sectionLabel('Nama Obat'),
                      const SizedBox(height: 8),
                      _buildNamaObatField(),
                      const SizedBox(height: 24),

                      // Dosis
                      _sectionLabel('Dosis'),
                      const SizedBox(height: 8),
                      _buildDosisField(),
                      const SizedBox(height: 24),

                      // Gambar
                      _sectionLabel('Gambar'),
                      const SizedBox(height: 8),
                      _buildImagePicker(),
                      const SizedBox(height: 24),

                      // Pengingat
                      _sectionLabel('Pengingat'),
                      const SizedBox(height: 12),
                      _buildPengingaatSelector(),
                      const SizedBox(height: 24),

                      // Frekuensi
                      _sectionLabel('Frekuensi'),
                      const SizedBox(height: 8),
                      _buildFrekuensiDropdown(),
                      const SizedBox(height: 24),

                      // Durasi Hari
                      _sectionLabel('Durasi (Hari)'),
                      const SizedBox(height: 8),
                      _buildDurasiHariField(),
                      const SizedBox(height: 24),

                      // Catatan
                      _sectionLabel('Catatan'),
                      const SizedBox(height: 8),
                      _buildCatatanField(),
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
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.obat != null ? 'Edit Obat' : 'Tambah Obat',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
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
    ),
  );

  Widget _buildNamaObatField() {
    return TextFormField(
      controller: _namaObatCtrl,
      decoration: InputDecoration(
        hintText: 'Contoh: Aspirin',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _streakTeal, width: 1.5),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Nama obat wajib diisi' : null,
    );
  }

  Widget _buildDosisField() {
    return TextFormField(
      controller: _dosisCtrl,
      decoration: InputDecoration(
        hintText: 'Contoh: 500mg / 2 tablet',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _streakTeal, width: 1.5),
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Dosis wajib diisi' : null,
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            Icon(
              Icons.image_outlined,
              size: 16,
              color: _pickedImage != null ? _green : _textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              _pickedImage != null ? 'Gambar Terpilih' : 'Pilih Gambar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _pickedImage != null ? _green : _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPengingaatSelector() {
    final requiredCount = _getRequiredPengingat();

    // Identifikasi slot mana saja yang memiliki waktu duplikat
    final Set<String> seen = {};
    final Set<String> duplicates = {};
    for (int i = 0; i < requiredCount; i++) {
      final t = _selectedCustomTimes[i];
      if (t != null) {
        if (!seen.add(t)) duplicates.add(t);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentukan $requiredCount waktu pengingat',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requiredCount,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final time = _selectedCustomTimes[index];
            final hasSelected = time != null;
            final isDuplicate = hasSelected && duplicates.contains(time);

            final Color borderColor = isDuplicate
                ? const Color(0xFFEF4444)
                : hasSelected
                    ? const Color(0xFF15BE77)
                    : _cardBorder;
            final Color iconColor = isDuplicate
                ? const Color(0xFFEF4444)
                : hasSelected
                    ? const Color(0xFF15BE77)
                    : _textSecondary;

            return InkWell(
              onTap: () => _selectTime(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDuplicate
                      ? const Color(0xFFFEF2F2)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: (hasSelected || isDuplicate) ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDuplicate
                          ? Icons.error_outline_rounded
                          : Icons.access_time_rounded,
                      color: iconColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Waktu Ke-${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              color: iconColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasSelected ? time : 'Ketuk untuk pilih jam',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: hasSelected ? _textPrimary : _textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                          if (isDuplicate) ...[
                            const SizedBox(height: 2),
                            const Text(
                              'Waktu ini duplikat — pilih waktu lain',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: _textSecondary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFrekuensiDropdown() {
    return FormField<String>(
      initialValue: _frekuensiCtrl.text,
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _streakTeal, width: 1.5),
            ),
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            isDense: true,
            underline: const SizedBox(),
            value: _frekuensiCtrl.text,
            items: _frekuensiOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _frekuensiCtrl.text = newValue;
                  // Reset all selected custom times when frequency changes
                  for (int i = 0; i < _selectedCustomTimes.length; i++) {
                    _selectedCustomTimes[i] = null;
                  }
                });
                state.didChange(newValue);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildDurasiHariField() {
    return TextFormField(
      controller: _durasiHariCtrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 'Contoh: 7',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _streakTeal, width: 1.5),
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Durasi wajib diisi';
        if (int.tryParse(v) == null || int.parse(v) <= 0) {
          return 'Durasi harus angka positif';
        }
        return null;
      },
    );
  }

  Widget _buildCatatanField() {
    return TextFormField(
      controller: _catatanCtrl,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Catatan tambahan (opsional)',
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _streakTeal, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _simpan,
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_textPrimary),
                ),
              )
            : Text(
                widget.obat != null ? 'Simpan Perubahan' : 'Simpan Obat',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
      ),
    );
  }
}
