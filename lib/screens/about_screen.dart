import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart'; // ganti sesuai path kamu

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF8FD),
      appBar: const CustomAppBar(
        showBackButton: true,
        showInfoButton: false,
        ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tentang Aplikasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Informasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 350,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 140, 206, 249),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: const Text(
                'WATERLENS (Water Analysis and Tracking with Evaluation Lens) adalah sebuah sistem cerdas berbasis IoT dan machine learning yang dirancang untuk memantau kualitas air secara real-time. Sistem ini menggunakan mikrokontroler ESP32 yang terhubung ke berbagai sensor lingkungan seperti sensor pH, suhu, kekeruhan (turbidity), dan TDS (Total Dissolved Solids). Data dari sensor dikirim setiap lima menit melalui protokol MQTT ke backend di Google Cloud, di mana model machine learning dengan algoritma Support Vector Machine (SVM) melakukan klasifikasi untuk menentukan kelayakan air. Jika air terdeteksi tidak layak konsumsi, data akan disimpan secara otomatis di Firestore sebagai histori dan dapat diakses oleh pengguna melalui aplikasi mobile yang user-friendly. Dengan pemrosesan cepat, notifikasi otomatis, dan antarmuka visual, WaterLENS membantu masyarakat dan industri untuk mengambil keputusan berbasis data mengenai penggunaan air secara efisien dan aman.',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Pengembang',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 140, 206, 249),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Dikembangkan oleh Mahasiswa IT Politeknik Negeri Madiun untuk keperluan tugas akhir mengenai monitoring dan prediksi kualitas air.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
