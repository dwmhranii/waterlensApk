import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        showInfoButton: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar utama
              SizedBox(
                width: double.infinity,
                height: 200,
                child: Image.network(
                  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
                  fit: BoxFit.cover,
                ),
              ),

              // Konten artikel
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul artikel
                    Text(
                      'Pentingnya Menjaga Kualitas Air',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tanggal
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '1 Juni 2025',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Isi artikel
                    const Text(
                      '''
Air adalah sumber kehidupan yang sangat penting bagi semua makhluk hidup di bumi ini. Tanpa air, manusia, hewan, dan tumbuhan tidak akan mampu bertahan hidup. Oleh karena itu, menjaga kualitas dan ketersediaan air bersih merupakan tanggung jawab kita bersama.

Artikel ini bertujuan untuk memberikan wawasan mengenai pentingnya kualitas air, khususnya dalam konteks konsumsi sehari-hari. Air yang tercemar dapat membawa berbagai risiko kesehatan, seperti penyakit diare, keracunan logam berat, dan gangguan pencernaan. Salah satu indikator utama kualitas air adalah nilai pH, kekeruhan (turbidity), suhu, serta kandungan zat padat terlarut (solids).

Pemantauan kualitas air secara berkala dapat membantu mendeteksi potensi bahaya sebelum berdampak buruk terhadap kesehatan. Teknologi berbasis IoT dan sistem deteksi otomatis seperti aplikasi Waterlens dapat menjadi solusi modern dalam memantau dan menganalisis kualitas air dari waktu ke waktu.

Melalui edukasi dan inovasi teknologi, diharapkan masyarakat dapat lebih sadar akan pentingnya air bersih dan mengambil langkah preventif untuk menjaganya.
                      ''',
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16, height: 1.6),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
