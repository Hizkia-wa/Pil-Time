import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';

class TambahJadwalKonsumsi extends StatefulWidget {
  const TambahJadwalKonsumsi({super.key});

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

  final String baseUrl = "http://10.0.2.2:8080/api";

  final _formKey = GlobalKey<FormState>();
  final _namaObatCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _frekuensiCtrl = TextEditingController();
  final _durasiHariCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  
  int? _pasienId;
  bool _isSaving = false;
  File? _pickedImage;
  Set<String> _selectedPengingat = {}; // Multiple selection

  final List<Map<String, String>> _pengingaatOptions = [
    {'label': 'Pagi', 'value': 'pagi', 'icon': '🌅'},
    {'label': 'Siang', 'value': 'siang', 'icon': '☀️'},
    {'label': 'Sore', 'value': 'sore', 'icon': '🌅'},
    {'label': 'Malam', 'value': 'malam', 'icon': '🌙'},
  ];

  final List<String> _frekuensiOptions = ['1x sehari', '2x sehari', '3x sehari', '4x sehari'];

  @override
  void initState() {
    super.initState();
    _frekuensiCtrl.text = '1x sehari';
    _durasiHariCtrl.text = '7';
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
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
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
    if (_selectedPengingat.length != requiredPengingat) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih $requiredPengingat waktu pengingat untuk ${_frekuensiCtrl.text}'),
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

    setState(() => _isSaving = true);

    final Map<String, dynamic> data = {
      "nama_obat": _namaObatCtrl.text.trim(),
      "dosis": _dosisCtrl.text.trim(),
      "pengingat": _selectedPengingat.toList(), // Convert Set to List
      "frekuensi": _frekuensiCtrl.text.trim(),
      "durasi_hari": int.parse(_durasiHariCtrl.text),
      "catatan": _catatanCtrl.text.trim(),
      "gambar": _pickedImage != null ? _convertImageToBase64(_pickedImage!) : "",
      "pasien_id": _pasienId,
    };

    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/pasien/obat-mandiri'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Obat berhasil ditambahkan')),
          );
        }
      } else {
        final errorBody = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorBody['error'] ?? 'Gagal menambahkan obat'),
            ),
          );
        }
        debugPrint("Gagal simpan: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      debugPrint("Error API: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          const Expanded(
            child: Center(
              child: Text(
                'Tambah Obat',
                textAlign: TextAlign.center,
                style: TextStyle(
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
      onTap: _pickImage,
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
    final selectedCount = _selectedPengingat.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Requirement label
        Text(
          'Pilih $requiredCount waktu pengingat',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selectedCount == requiredCount ? _green : _textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pengingaatOptions.map((option) {
            final selected = _selectedPengingat.contains(option['value']);
            final isDisabled = !selected && selectedCount >= requiredCount;

            return GestureDetector(
              onTap: isDisabled
                  ? null
                  : () => setState(() {
                        if (selected) {
                          _selectedPengingat.remove(option['value']);
                        } else {
                          _selectedPengingat.add(option['value']!);
                        }
                      }),
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected ? _green : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? _green : _cardBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option['icon']!,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option['label']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? _textPrimary : _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Selected counter
        const SizedBox(height: 8),
        Text(
          'Dipilih: $selectedCount/$requiredCount',
          style: TextStyle(
            fontSize: 11,
            color: selectedCount == requiredCount ? _green : _textSecondary,
            fontWeight: FontWeight.w500,
          ),
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
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _frekuensiCtrl.text = newValue;
                  _selectedPengingat.clear(); // Clear saat frekuensi berubah
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
            : const Text(
                'Simpan Obat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
      ),
    );
  }
}
