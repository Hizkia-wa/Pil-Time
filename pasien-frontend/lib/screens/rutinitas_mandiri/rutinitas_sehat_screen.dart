import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import 'tambah_rutinitas_screen.dart';
import '../obat_mandiri/tambah_jadwal_konsumsi_obat_mandiri.dart';
import '../../bloc/rutinitas/rutinitas_bloc.dart';
import '../../bloc/rutinitas/rutinitas_event.dart';
import '../../bloc/rutinitas/rutinitas_state.dart';

class RutinitasSehatScreen extends StatefulWidget {
  final int initialIndex;
  const RutinitasSehatScreen({super.key, this.initialIndex = 0});

  @override
  State<RutinitasSehatScreen> createState() => _RutinitasSehatScreenState();
}

class _RutinitasSehatScreenState extends State<RutinitasSehatScreen>
    with SingleTickerProviderStateMixin {
  static const Color _bgPage = Color(0xFFF8FAFC); // Premium soft background
  static const Color _green = Color(0xFF15BE77); // Style guide Emerald Green
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textSecondary = Color(0xFF64748B);

  List<dynamic> _listObat = [];
  List<dynamic> _listRutinitas = [];
  int _streakHari = 0;
  bool _isLoading = true;
  int? _pasienId;
  late TabController _tabController;
  late final RutinitasBloc _rutinitasBloc;

  @override
  void initState() {
    super.initState();
    _rutinitasBloc = RutinitasBloc();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _tabController.addListener(() {
      if (mounted) setState(() {});
    });

    _loadPasienSession();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rutinitasBloc.close();
    super.dispose();
  }

  Future<void> _loadPasienSession() async {
    try {
      final session = await AuthService.getPasienSession();
      if (session != null && session['pasien_id'] != null) {
        setState(() {
          _pasienId = session['pasien_id'] as int;
        });
        _rutinitasBloc.add(FetchRutinitasSehat(pasienId: _pasienId!));
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Future<void> _initData() async {
    if (_pasienId != null) {
      _rutinitasBloc.add(FetchRutinitasSehat(pasienId: _pasienId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgPage,
        body: SafeArea(
          child: BlocConsumer<RutinitasBloc, RutinitasState>(
            bloc: _rutinitasBloc,
            listener: (context, state) {
              if (state is RutinitasSehatLoading) {
                setState(() {
                  _isLoading = true;
                });
              } else if (state is RutinitasSehatLoaded) {
                setState(() {
                  _listObat = state.listObat;
                  _listRutinitas = state.listRutinitas;
                  _streakHari = state.streakHari;
                  _isLoading = false;
                });
              } else if (state is RutinitasSehatFailure) {
                setState(() {
                  _isLoading = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}')),
                );
              } else if (state is RutinitasActionLoading) {
                setState(() {
                  _isLoading = true;
                });
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
                setState(() {
                  _isLoading = false;
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
                  // ─── APP BAR (CUSTOM ERGONOMIC) ──────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 24, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: _textPrimary,
                            size: 32,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Rutinitas Sehat',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            fontFamily: 'Roboto',
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildStreakCard(),
                  ),

                  const SizedBox(height: 12),

                  // Custom styled TabBar inside white container
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: _textPrimary.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab, // Membagi rata tab indikator antara Obat dan Rutinitas
                      indicatorColor: _green,
                      indicatorWeight: 0,
                      indicator: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: _textSecondary,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                      tabs: const [
                        Tab(text: "Obat"),
                        Tab(text: "Rutinitas"),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildObatSection(),
                        _buildListSection(_listRutinitas, "rutinitas"),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        floatingActionButton: _buildTambahButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Text("🏆", style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 10),
              const Text(
                "KEPATUHAN KAMU",
                style: TextStyle(
                  color: Color(0xFFA7F3D0),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "$_streakHari Hari Beruntun!",
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Roboto',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Mantap sekali! Pertahankan terus kebiasaan minum obat sehatmu ini ya.",
            style: TextStyle(
              color: Color(0xFFECFDF5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildObatSection() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _green,
          strokeWidth: 3,
        ),
      );
    }

    if (_listObat.isEmpty) {
      return _buildEmptyState("Belum Ada Jadwal Obat Mandiri", "Tambahkan obat mandiri pertama Anda sekarang.");
    }

    return RefreshIndicator(
      onRefresh: _initData,
      color: _green,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 84),
        itemCount: _listObat.length,
        itemBuilder: (context, index) {
          final item = _listObat[index];
          return _buildObatCard(item);
        },
      ),
    );
  }

  Widget _buildListSection(List<dynamic> list, String type) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _green,
          strokeWidth: 3,
        ),
      );
    }

    if (list.isEmpty) {
      return _buildEmptyState("Belum Ada Jadwal Rutinitas", "Mulai hidup sehat dengan menambahkan rutinitas baru.");
    }

    return RefreshIndicator(
      onRefresh: _initData,
      color: _green,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 84),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return _buildCard(item);
        },
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: 250,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_task_rounded,
                color: Color(0xFF94A3B8),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
                fontFamily: 'Roboto',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: _textSecondary,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObatCard(dynamic item) {
    final List<dynamic> pengingatRaw = item['pengingat'] ?? [];
    final pengingat = pengingatRaw.isNotEmpty ? pengingatRaw.join(', ') : '-';
    final frekuensi = item['frekuensi'] ?? '-';
    final dosis = item['fungsi'] ?? '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _textPrimary.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF), // Soft Blue
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medication_rounded,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_obat'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dosis: $dosis",
                  style: const TextStyle(
                    color: _textPrimary, 
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$frekuensi • $pengingat",
                  style: const TextStyle(
                    color: _textSecondary, 
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: _textSecondary,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 120),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 8,
            shadowColor: _textPrimary.withValues(alpha: 0.1),
            onSelected: (value) {
              if (value == 'edit') {
                _editObat(item);
              } else if (value == 'hapus') {
                _confirmHapusObat(item);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Ubah',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hapus',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(dynamic item) {
    final namaRutinitas = item['nama_rutinitas'] ?? '-';
    final waktuReminder = item['waktu_reminder'] ?? '';
    final deskripsi = item['deskripsi'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _textPrimary.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F3FF), // Soft Purple
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Color(0xFF8B5CF6),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaRutinitas,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _textPrimary,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (waktuReminder.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.alarm_rounded, color: _textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        waktuReminder,
                        style: const TextStyle(
                          color: _textSecondary, 
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ],
                if (deskripsi.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    deskripsi,
                    style: const TextStyle(
                      color: _textSecondary, 
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: _textSecondary,
              size: 22,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 120),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 8,
            shadowColor: _textPrimary.withValues(alpha: 0.1),
            onSelected: (value) {
              if (value == 'edit') {
                _editRutinitas(item);
              } else if (value == 'hapus') {
                _confirmHapusRutinitas(item);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined, color: Colors.blue, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Ubah',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'hapus',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTambahButton() {
    final isObatTab = _tabController.index == 0;
    final buttonLabel = isObatTab ? "Tambah Obat Mandiri" : "Tambah Rutinitas Sehat";

    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () async {
          if (_pasienId == null) return;

          if (!mounted) return;
          final dynamic result;
          if (isObatTab) {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TambahJadwalKonsumsi(),
              ),
            );
          } else {
            result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TambahRutinitasScreen(),
              ),
            );
          }

          if (result == true && mounted) {
            _initData();
          }
        },
        icon: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 22),
        label: Text(
          buttonLabel,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 4,
          shadowColor: _green.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Future<void> _editObat(dynamic item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahJadwalKonsumsi(obat: item),
      ),
    );
    if (result == true && mounted) {
      _initData();
    }
  }

  Future<void> _confirmHapusObat(dynamic item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Obat?',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus jadwal obat "${item['nama_obat']}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _rutinitasBloc.add(DeleteObatMandiri(obatId: item['obat_id']));
    }
  }

  Future<void> _editRutinitas(dynamic item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TambahRutinitasScreen(rutinitas: item),
      ),
    );
    if (result == true && mounted) {
      _initData();
    }
  }

  Future<void> _confirmHapusRutinitas(dynamic item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus Rutinitas?',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus rutinitas "${item['nama_rutinitas']}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(
            color: _textSecondary,
            fontSize: 14,
            fontFamily: 'Inter',
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: _textSecondary,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _rutinitasBloc.add(DeleteRutinitasSehat(id: item['id']));
    }
  }
}
