import 'package:flutter/material.dart';
import 'package:frontend_pasien/models/obat.dart';

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class DetailInfoObatScreen extends StatelessWidget {
  final ObatDetail obat;

  const DetailInfoObatScreen({super.key, required this.obat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Premium soft background
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  const Text(
                    'Detail Obat',
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
            
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    _buildInfoRow(),
                    const SizedBox(height: 20),
                    _buildSection(
                      icon: '💊',
                      title: 'Dosis & Takaran',
                      content: '${obat.jumlahDosis} ${obat.satuan} - ${obat.takaranObat}',
                    ),
                    _buildSection(
                      icon: '📋',
                      title: 'Aturan Konsumsi',
                      content: obat.aturanKonsumsi,
                    ),
                    if (obat.catatan.isNotEmpty)
                      _buildSection(
                        icon: '📝',
                        title: 'Catatan Tambahan',
                        content: obat.catatan,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    final categoryColor = _getCategoryColor(obat.kategoriObat);
    final categoryBgColor = _getCategoryBgColor(obat.kategoriObat);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: categoryBgColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              _getCategoryIcon(obat.kategoriObat),
              color: categoryColor,
              size: 56,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            obat.namaObat,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Roboto',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: categoryBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              obat.kategoriObat.isEmpty ? 'Kategori Umum' : obat.kategoriObat,
              style: TextStyle(
                fontSize: 13, 
                color: categoryColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          _infoChip(
            icon: Icons.access_time_rounded,
            label: obat.frekuensiPerHari,
          ),
          _divider(),
          _infoChip(
            icon: Icons.calendar_today_rounded, 
            label: obat.tipeDurasi,
          ),
          _divider(),
          _infoChip(
            icon: Icons.restaurant_rounded, 
            label: obat.waktuMinum,
          ),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F8F1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF15BE77), size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1.5, height: 44, color: const Color(0xFFF1F5F9));
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

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
