import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './tambah_jadwal_konsumsi_obat_mandiri.dart';
import '../../services/auth_service.dart';
import '../../bloc/rutinitas/rutinitas_bloc.dart';
import '../../bloc/rutinitas/rutinitas_event.dart';
import '../../bloc/rutinitas/rutinitas_state.dart';

class JadwalKonsumsiObatMandiriStyled extends StatefulWidget {
  final int streakHari;

  const JadwalKonsumsiObatMandiriStyled({super.key, required this.streakHari});

  @override
  State<JadwalKonsumsiObatMandiriStyled> createState() =>
      _JadwalKonsumsiObatMandiriStyledState();
}

class _JadwalKonsumsiObatMandiriStyledState
    extends State<JadwalKonsumsiObatMandiriStyled> {
  late final RutinitasBloc _rutinitasBloc;
  List<dynamic> _jadwalList = [];
  int? _pasienId;

  @override
  void initState() {
    super.initState();
    _rutinitasBloc = RutinitasBloc();
    _loadSessionAndFetch();
  }

  @override
  void dispose() {
    _rutinitasBloc.close();
    super.dispose();
  }

  Future<void> _loadSessionAndFetch() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null && session['pasien_id'] != null) {
        _pasienId = session['pasien_id'] as int;
        _rutinitasBloc.add(FetchRutinitasSehat(pasienId: _pasienId!));
      }
    } catch (e) {
      debugPrint("Error loading session: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RutinitasBloc, RutinitasState>(
      bloc: _rutinitasBloc,
      listener: (context, state) {
        if (state is RutinitasSehatLoaded) {
          _jadwalList = state.listObat;
        } else if (state is RutinitasActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: const Color(0xFF15BE77),
            ),
          );
          if (_pasienId != null) {
            _rutinitasBloc.add(FetchRutinitasSehat(pasienId: _pasienId!));
          }
        } else if (state is RutinitasActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red[400],
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is RutinitasSehatLoading || state is RutinitasActionLoading;

        return RefreshIndicator(
          onRefresh: () async {
            if (_pasienId != null) {
              _rutinitasBloc.add(FetchRutinitasSehat(pasienId: _pasienId!));
            }
          },
          color: const Color(0xFF15BE77),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            children: [
              _buildStreakCard(),
              const SizedBox(height: 16),
              const Text(
                "Daftar Obat",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (isLoading && _jadwalList.isEmpty)
                const Center(child: CircularProgressIndicator(color: Color(0xFF15BE77)))
              else if (_jadwalList.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "Belum ada jadwal obat",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                )
              else
                ..._jadwalList.map(_buildObatCard),
              const SizedBox(height: 30),
              _buildTambahButton(),
            ],
          ),
        );
      },
    );
  }

  // ================= STREAK CARD =================
  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10221C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🏆 STREAK KAMU!",
            style: TextStyle(
              color: Color(0xFF13ECA4),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "${widget.streakHari} Hari",
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ================= OBAT CARD =================
  Widget _buildObatCard(dynamic item) {
    // Handling potential map structure from obat-mandiri endpoint (id vs jadwal_id)
    final id = item['id'] ?? item['jadwal_id'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['nama_jadwal'] ?? item['nama_obat'] ?? '-',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            item['dosis'] ?? '${item['jumlah_dosis'] ?? ""} ${item['satuan'] ?? ""}'.trim(), 
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _actionButton(
                icon: Icons.delete_rounded,
                color: Colors.red,
                bg: const Color(0xFFFEE2E2),
                onTap: () {
                  if (id != null) {
                    _showDeleteConfirmation(id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DELETE CONFIRMATION =================
  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Jadwal?"),
        content: const Text(
          "Data ini akan dihapus permanen dari riwayat kamu.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              _rutinitasBloc.add(DeleteObatMandiri(obatId: id));
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ================= ACTION BUTTON =================
  Widget _actionButton({
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  // ================= TAMBAH BUTTON =================
  Widget _buildTambahButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahJadwalKonsumsi()),
          ).then((_) {
            if (_pasienId != null) {
              _rutinitasBloc.add(FetchRutinitasSehat(pasienId: _pasienId!));
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF13EC5B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: const Icon(Icons.add_rounded, color: Color(0xFF0F172A)),
        label: const Text(
          "Tambahkan Jadwal Konsumsi Obat",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
    );
  }
}
