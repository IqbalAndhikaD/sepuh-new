import 'package:flutter/material.dart';
import '../../../model/schedule.dart';
import '../../../widget/color.dart';

class ListJadwalScreen extends StatelessWidget {
  final List<Schedule> schedules;

  const ListJadwalScreen({Key? key, required this.schedules}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'List Jadwal',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: biruNavy,
      ),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(
                schedule.pasien.nama,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: biruNavy,
                  fontFamily: 'Poppins',
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hari: ${schedule.waktu.hari}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    "Jam: ${schedule.waktu.jamMulai} - ${schedule.waktu.jamSelesai}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    "Status: ${schedule.status ? "Aktif" : "Menunggu Antrian"}",
                    style: TextStyle(
                      color: schedule.status ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: biruToska,
                child: Text(
                  schedule.antrian.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              isThreeLine: true,
              onTap: () => _showScheduleInfo(context, schedule),
            ),
          );
        },
      ),
    );
  }

  void _showScheduleInfo(BuildContext context, Schedule schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Informasi Jadwal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: biruNavy,
              fontFamily: 'Poppins',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nama Pasien : ${schedule.pasien.nama}'),
                Text('Hari : ${schedule.waktu.hari}'),
                Text(
                    'Jam : ${schedule.waktu.jamMulai} - ${schedule.waktu.jamSelesai}'),
                Text('Antrian : ${schedule.antrian}'),
                Text('Status : ${schedule.status ? "Aktif" : "Tidak Aktif"}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
