import 'package:flutter/material.dart';

class AlarmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF064E3B),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("ALARM OBAT",
                    style: TextStyle(color: Colors.greenAccent)),
                SizedBox(height: 10),
                Icon(Icons.medication, size: 50, color: Colors.white),
                SizedBox(height: 10),
                Text("Paracetamol 500mg",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text("2 tablet • Sesudah makan",
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 10),
                Chip(label: Text("Pagi"))
              ],
            ),
          ),

          SizedBox(height: 20),

          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Perhatian",
                    style: TextStyle(color: Colors.orange)),
                Text("- Jangan melebihi dosis"),
                Text("- Simpan di tempat sejuk"),
              ],
            ),
          ),

          Spacer(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {},
              child: Text("MATIKAN ALARM"),
            ),
          )
        ],
      ),
    );
  }
}