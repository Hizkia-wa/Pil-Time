import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.arrow_back),
                  SizedBox(width: 10),
                  Text(
                    "Reminder dan Alarm",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // CARD ALARM UTAMA
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF0B1F3A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Alarm berikutnya",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "12:00",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Ibuprofen . 1 tablet",
                    style: TextStyle(color: Colors.white70),
                  ),

                  SizedBox(height: 15),

                  Row(
                    children: [
                      _chip("Notifikasi Aktif"),
                      SizedBox(width: 10),
                      _chip("Alarm Aktif"),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // LIST ALARM
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text(
                    "Semua Alarm Hari ini",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 10),

                  _alarmItem("08.00", "Probiotic", Colors.green),
                  _alarmItem("12.00", "Ibu Profen", Colors.orange),
                  _alarmItem("18.00", "Vitamin C", Colors.red),
                  _alarmItem("20.00", "Aspirin 2", Colors.green),
                ],
              ),
            ),

            // BUTTON
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
                child: Text("Matikan Alarm", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.greenAccent),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: Colors.greenAccent, fontSize: 12),
      ),
    );
  }

  Widget _alarmItem(String time, String title, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.medication, color: Colors.orange),
          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(title, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: color, size: 18),
          ),
        ],
      ),
    );
  }
}
