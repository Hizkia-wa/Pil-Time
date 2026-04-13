import 'package:flutter/material.dart';
import './../obat_mandiri/jadwal_konsumsi_obat_mandiri.dart';
import './../rutinitas_mandiri/jadwal_rutinitas_screen.dart';

class RutinitasSehatScreen extends StatefulWidget {
  const RutinitasSehatScreen({super.key});

  @override
  State<RutinitasSehatScreen> createState() => _RutinitasSehatScreenState();
}

class _RutinitasSehatScreenState extends State<RutinitasSehatScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  static const Color _bgPage = Color(0xFFF8FAF9);
  static const Color _tabActive = Color(0xFF0F172A);
  static const Color _tabInactive = Color(0xFF64748B);
  static const Color _indicator = Color(0xFF13ECA4);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [

            // Header
            Container(
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
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: _tabActive,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Rutinitas Sehat',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _tabActive,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),

            // TabBar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: _tabActive,
                unselectedLabelColor: _tabInactive,
                indicatorColor: _indicator,
                indicatorWeight: 2.5,
                tabs: const [
                  Tab(text: 'Obat'),
                  Tab(text: 'Rutinitas'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  JadwalKonsumsiObatMandiriStyled(streakHari: 12),
                  JadwalRutinitasScreen(), // TANPA parameter
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}