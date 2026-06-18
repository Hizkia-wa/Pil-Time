import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog pemilih jam khusus lansia:
/// - Mode TOMBOL: tombol +/− besar untuk jam dan menit (default)
/// - Mode KETIK: ketik langsung jam dan menit (cocok saat jam masih jauh)
/// - Format 24 jam (tanpa AM/PM)
/// - Angka besar mudah dibaca
///
/// Kembalikan [TimeOfDay] yang dipilih, atau null jika dibatalkan.
Future<TimeOfDay?> showLansiaTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _LansiaTimePickerDialog(initialTime: initialTime),
  );
}

class _LansiaTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;
  const _LansiaTimePickerDialog({required this.initialTime});

  @override
  State<_LansiaTimePickerDialog> createState() => _LansiaTimePickerDialogState();
}

class _LansiaTimePickerDialogState extends State<_LansiaTimePickerDialog> {
  static const Color _green = Color(0xFF15BE77);
  static const Color _bg = Color(0xFFF8FAFC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textGray = Color(0xFF64748B);

  late int _hour;
  late int _minute;

  /// true = mode tombol +/−, false = mode ketik
  bool _isButtonMode = true;

  // Controller dan FocusNode diinisialisasi langsung (bukan late)
  // agar tidak ada LateInitializationError
  final TextEditingController _hourCtrl = TextEditingController();
  final TextEditingController _minuteCtrl = TextEditingController();
  final FocusNode _hourFocus = FocusNode();
  final FocusNode _minuteFocus = FocusNode();

  String? _hourError;
  String? _minuteError;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    // Set nilai awal controller setelah _hour & _minute tersedia
    _hourCtrl.text = _hour.toString().padLeft(2, '0');
    _minuteCtrl.text = _minute.toString().padLeft(2, '0');
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _hourFocus.dispose();
    _minuteFocus.dispose();
    super.dispose();
  }

  void _changeHour(int delta) {
    setState(() {
      _hour = (_hour + delta + 24) % 24;
      _hourCtrl.text = _hour.toString().padLeft(2, '0');
    });
  }

  void _changeMinute(int delta) {
    setState(() {
      _minute = (_minute + delta + 60) % 60;
      _minuteCtrl.text = _minute.toString().padLeft(2, '0');
    });
  }

  String get _formattedTime =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  void _switchMode() {
    if (_isButtonMode) {
      // Beralih ke mode ketik — sinkronisasi nilai
      _hourCtrl.text = _hour.toString().padLeft(2, '0');
      _minuteCtrl.text = _minute.toString().padLeft(2, '0');
      _hourError = null;
      _minuteError = null;
    } else {
      // Beralih ke mode tombol — validasi & sinkronisasi nilai dari field ketik
      if (!_validateAndApplyTyped()) return;
    }
    setState(() => _isButtonMode = !_isButtonMode);
  }

  /// Validasi input ketik, update _hour/_minute.
  /// Kembalikan true jika valid.
  bool _validateAndApplyTyped() {
    final h = int.tryParse(_hourCtrl.text.trim());
    final m = int.tryParse(_minuteCtrl.text.trim());

    String? hErr;
    String? mErr;

    if (h == null || h < 0 || h > 23) hErr = 'Jam: 0–23';
    if (m == null || m < 0 || m > 59) mErr = 'Menit: 0–59';

    setState(() {
      _hourError = hErr;
      _minuteError = mErr;
    });

    if (hErr != null || mErr != null) return false;

    _hour = h!;
    _minute = m!;
    return true;
  }

  void _onConfirm() {
    if (!_isButtonMode) {
      // Mode ketik — validasi dulu
      if (!_validateAndApplyTyped()) return;
    }
    Navigator.of(context).pop(TimeOfDay(hour: _hour, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header baris: Judul + toggle mode ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: const Text(
                      'Pilih Jam',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ),
                  // Tombol toggle mode
                  GestureDetector(
                    onTap: _switchMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isButtonMode
                            ? const Color(0xFFF1F5F9)
                            : _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isButtonMode
                              ? const Color(0xFFCBD5E1)
                              : _green,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isButtonMode
                                ? Icons.keyboard_alt_outlined
                                : Icons.tune_rounded,
                            size: 16,
                            color: _isButtonMode ? _textGray : _green,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _isButtonMode ? 'Ketik' : 'Tombol',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isButtonMode ? _textGray : _green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                _isButtonMode
                    ? 'Tekan ＋ / － untuk mengubah jam & menit'
                    : 'Ketik jam (0–23) dan menit (0–59) secara langsung',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: _textGray),
              ),
              const SizedBox(height: 20),

              // ── Display waktu besar ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Text(
                  _formattedTime,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                    letterSpacing: 4,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Konten mode ──
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _isButtonMode
                    ? _buildButtonMode()
                    : _buildTypingMode(),
              ),

              const SizedBox(height: 24),

              // ── Tombol Aksi ──
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textGray,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Pilih',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── MODE TOMBOL ──────────────────────────────────────────────────────────
  Widget _buildButtonMode() {
    return Row(
      key: const ValueKey('button_mode'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TimeColumn(
          label: 'Jam',
          value: _hour.toString().padLeft(2, '0'),
          onIncrease: () => _changeHour(1),
          onDecrease: () => _changeHour(-1),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 48),
          child: Text(
            ':',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
          ),
        ),
        _TimeColumn(
          label: 'Menit',
          value: _minute.toString().padLeft(2, '0'),
          onIncrease: () => _changeMinute(5),
          onDecrease: () => _changeMinute(-5),
          stepLabel: '±5',
        ),
      ],
    );
  }

  // ── MODE KETIK ──────────────────────────────────────────────────────────
  Widget _buildTypingMode() {
    return Column(
      key: const ValueKey('typing_mode'),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field JAM
            _TypeField(
              controller: _hourCtrl,
              focusNode: _hourFocus,
              label: 'Jam',
              hint: '00–23',
              errorText: _hourError,
              nextFocus: _minuteFocus,
              onChanged: (v) {
                final h = int.tryParse(v);
                if (h != null && h >= 0 && h <= 23) {
                  setState(() {
                    _hour = h;
                    _hourError = null;
                  });
                }
              },
            ),
            // Pemisah
            const Padding(
              padding: EdgeInsets.only(top: 14),
              child: Text(
                ' : ',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ),
            // Field MENIT
            _TypeField(
              controller: _minuteCtrl,
              focusNode: _minuteFocus,
              label: 'Menit',
              hint: '00–59',
              errorText: _minuteError,
              onChanged: (v) {
                final m = int.tryParse(v);
                if (m != null && m >= 0 && m <= 59) {
                  setState(() {
                    _minute = m;
                    _minuteError = null;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Shortcut menit umum
        _buildMinuteSuggestions(),
      ],
    );
  }

  /// Shortcut cepat untuk menit yang sering dipakai
  Widget _buildMinuteSuggestions() {
    const suggestions = [0, 15, 30, 45];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Menit cepat: ', style: TextStyle(fontSize: 12, color: _textGray)),
        ...suggestions.map((m) => GestureDetector(
          onTap: () {
            setState(() {
              _minute = m;
              _minuteCtrl.text = m.toString().padLeft(2, '0');
              _minuteError = null;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _minute == m
                  ? _green.withValues(alpha: 0.15)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _minute == m ? _green : const Color(0xFFE2E8F0),
              ),
            ),
            child: Text(
              ':${m.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _minute == m ? _green : _textGray,
              ),
            ),
          ),
        )),
      ],
    );
  }
}

// ── FIELD KETIK ─────────────────────────────────────────────────────────────
class _TypeField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final String? errorText;
  final FocusNode? nextFocus;
  final ValueChanged<String> onChanged;

  const _TypeField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.errorText,
    this.nextFocus,
  });

  static const Color _green = Color(0xFF15BE77);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textGray = Color(0xFF64748B);
  static const Color _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textGray,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 82,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 2,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: hasError ? _red : _textDark,
              fontFamily: 'Roboto',
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: hint.split('–').first.padLeft(2, '0'),
              hintStyle: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _textGray.withValues(alpha: 0.4),
              ),
              filled: true,
              fillColor: hasError
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? _red : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: hasError ? _red : _green,
                  width: 2,
                ),
              ),
            ),
            onChanged: onChanged,
            onSubmitted: (_) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
            },
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 11,
                color: _red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (!hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              hint,
              style: const TextStyle(fontSize: 11, color: _textGray),
            ),
          ),
      ],
    );
  }
}

// ── KOLOM TOMBOL +/- ────────────────────────────────────────────────────────
class _TimeColumn extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final String? stepLabel;

  const _TimeColumn({
    required this.label,
    required this.value,
    required this.onIncrease,
    required this.onDecrease,
    this.stepLabel,
  });

  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textGray = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _textGray,
          ),
        ),
        const SizedBox(height: 8),
        _CircleButton(icon: Icons.add_rounded, onTap: onIncrease),
        const SizedBox(height: 8),
        SizedBox(
          width: 72,
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _textDark,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _CircleButton(icon: Icons.remove_rounded, onTap: onDecrease),
        if (stepLabel != null) ...[
          const SizedBox(height: 4),
          Text(
            stepLabel!,
            style: const TextStyle(fontSize: 11, color: _textGray),
          ),
        ],
      ],
    );
  }
}

// ── TOMBOL LINGKARAN ────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  static const Color _green = Color(0xFF15BE77);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: _green.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30, color: _green),
      ),
    );
  }
}
