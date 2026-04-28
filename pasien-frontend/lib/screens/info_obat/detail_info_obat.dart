import 'package:flutter/material.dart';
import 'package:frontend_pasien/models/obat.dart';

// ─── SCREEN ───────────────────────────────────────────────────────────────────

class DetailInfoObatScreen extends StatelessWidget {
  final ObatDetail obat;

  const DetailInfoObatScreen({super.key, required this.obat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(),
            _buildInfoRow(),
            const SizedBox(height: 16),
            _buildSection(
              icon: '💊',
              title: 'Dosis & Takaran',
              content:
                  '${obat.jumlahDosis} ${obat.satuan} - ${obat.takaranObat}',
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
    );
  }

  Widget _buildHero() {
    final categoryColor = _getCategoryColor(obat.kategoriObat);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getCategoryIcon(obat.kategoriObat),
              color: categoryColor,
              size: 64,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            obat.namaObat,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            obat.kategoriObat.isEmpty ? 'Obat' : obat.kategoriObat,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          _infoChip(
            icon: Icons.access_time_rounded,
            label: obat.frekuensiPerHari,
          ),
          _divider(),
          _infoChip(icon: Icons.calendar_today_rounded, label: obat.tipeDurasi),
          _divider(),
          _infoChip(icon: Icons.restaurant_rounded, label: obat.waktuMinum),
        ],
      ),
    );
  }

  Widget _infoChip({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2BB673), size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    if (category.contains('Antibiotik')) return const Color(0xFF4CAF50);
    if (category.contains('Pereda')) return const Color(0xFFFFC107);
    if (category.contains('Suplemen')) return const Color(0xFF2196F3);
    if (category.contains('Flu')) return const Color(0xFF9C27B0);
    if (category.contains('Darah')) return const Color(0xFFF44336);
    return const Color(0xFF607D8B);
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Antibiotik')) return Icons.shield;
    if (category.contains('Pereda')) return Icons.healing;
    if (category.contains('Suplemen')) return Icons.energy_savings_leaf;
    if (category.contains('Flu')) return Icons.thermostat;
    return Icons.medication;
  }
}
