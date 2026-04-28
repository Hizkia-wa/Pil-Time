class ObatDetail {
  final int id;
  final String namaObat;
  final String kategoriObat;
  final int jumlahDosis;
  final String satuan;
  final String takaranObat;
  final String frekuensiPerHari;
  final String waktuMinum;
  final String aturanKonsumsi;
  final String catatan;
  final String tipeDurasi;
  final int jumlahHari;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String waktuReminderPagi;
  final String waktuReminderMalam;
  final String status;

  ObatDetail({
    required this.id,
    required this.namaObat,
    required this.kategoriObat,
    required this.jumlahDosis,
    required this.satuan,
    required this.takaranObat,
    required this.frekuensiPerHari,
    required this.waktuMinum,
    required this.aturanKonsumsi,
    required this.catatan,
    required this.tipeDurasi,
    required this.jumlahHari,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.waktuReminderPagi,
    required this.waktuReminderMalam,
    required this.status,
  });

  factory ObatDetail.fromJson(Map<String, dynamic> json) {
    return ObatDetail(
      id: json['id'] ?? 0,
      namaObat: json['nama_obat'] ?? '',
      kategoriObat: json['kategori_obat'] ?? '',
      jumlahDosis: json['jumlah_dosis'] ?? 0,
      satuan: json['satuan'] ?? '',
      takaranObat: json['takaran_obat'] ?? '',
      frekuensiPerHari: json['frekuensi_per_hari'] ?? '',
      waktuMinum: json['waktu_minum'] ?? '',
      aturanKonsumsi: json['aturan_konsumsi'] ?? '',
      catatan: json['catatan'] ?? '',
      tipeDurasi: json['tipe_durasi'] ?? '',
      jumlahHari: json['jumlah_hari'] ?? 0,
      tanggalMulai: json['tanggal_mulai'] ?? '',
      tanggalSelesai: json['tanggal_selesai'] ?? '',
      waktuReminderPagi: json['waktu_reminder_pagi'] ?? '',
      waktuReminderMalam: json['waktu_reminder_malam'] ?? '',
      status: json['status'] ?? 'aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_obat': namaObat,
      'kategori_obat': kategoriObat,
      'jumlah_dosis': jumlahDosis,
      'satuan': satuan,
      'takaran_obat': takaranObat,
      'frekuensi_per_hari': frekuensiPerHari,
      'waktu_minum': waktuMinum,
      'aturan_konsumsi': aturanKonsumsi,
      'catatan': catatan,
      'tipe_durasi': tipeDurasi,
      'jumlah_hari': jumlahHari,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'waktu_reminder_pagi': waktuReminderPagi,
      'waktu_reminder_malam': waktuReminderMalam,
      'status': status,
    };
  }
}
