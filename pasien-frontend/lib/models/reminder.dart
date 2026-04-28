class Reminder {
  final int id;
  final String time;
  final String namaObat;
  final int jumlahDosis;
  final String satuan;
  final String kategoriObat;
  final String jadwalId;
  final String status;

  Reminder({
    required this.id,
    required this.time,
    required this.namaObat,
    required this.jumlahDosis,
    required this.satuan,
    required this.kategoriObat,
    required this.jadwalId,
    this.status = 'pending',
  });

  String get dosageLabel => '$jumlahDosis $satuan';

  String get fullInfo => '$namaObat . $dosageLabel';
}

class ReminderGroup {
  final String time;
  final List<Reminder> reminders;

  ReminderGroup({required this.time, required this.reminders});

  int get totalDosis => reminders.fold<int>(0, (sum, r) => sum + r.jumlahDosis);
}
