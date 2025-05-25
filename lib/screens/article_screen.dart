import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart'; // pastikan path sesuai

class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        showBackButton: true,
        showInfoButton: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar di atas
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.network(
                'https://via.placeholder.com/600x300.png?text=Gambar+Artikel',
                fit: BoxFit.cover,
              ),
            ),
            // Artikel
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '''
Air adalah sumber kehidupan yang sangat penting bagi semua makhluk hidup di bumi ini. Tanpa air, manusia, hewan, dan tumbuhan tidak akan mampu bertahan hidup. Oleh karena itu, menjaga kualitas dan ketersediaan air bersih merupakan tanggung jawab kita bersama.

Artikel ini bertujuan untuk memberikan wawasan mengenai pentingnya kualitas air, khususnya dalam konteks konsumsi sehari-hari. Air yang tercemar dapat membawa berbagai risiko kesehatan, seperti penyakit diare, keracunan logam berat, dan gangguan pencernaan. Salah satu indikator utama kualitas air adalah nilai pH, kekeruhan (turbidity), suhu, serta kandungan zat padat terlarut (solids).

Pemantauan kualitas air secara berkala dapat membantu mendeteksi potensi bahaya sebelum berdampak buruk terhadap kesehatan. Teknologi berbasis IoT dan sistem deteksi otomatis seperti aplikasi Waterlens dapat menjadi solusi modern dalam memantau dan menganalisis kualitas air dari waktu ke waktu.

Melalui edukasi dan inovasi teknologi, diharapkan masyarakat dapat lebih sadar akan pentingnya air bersih dan mengambil langkah preventif untuk menjaganya.
                ''',
                textAlign: TextAlign.justify,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
