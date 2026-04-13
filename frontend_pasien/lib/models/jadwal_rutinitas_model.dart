class JadwalRutinitasItem {
  final int jadwalRutinitasId;
  final String namaAktivitas;
  final String jamMulai;
  final String jamSelesai;
  final List<String> pengulangan;
  final String status;

  JadwalRutinitasItem({
    required this.jadwalRutinitasId,
    required this.namaAktivitas,
    required this.jamMulai,
    required this.jamSelesai,
    required this.pengulangan,
    required this.status,
  });

  bool get isDone => status == 'done';
  bool get isTerlewat => status == 'terlewat';
  bool get isPending => status == 'pending';
}