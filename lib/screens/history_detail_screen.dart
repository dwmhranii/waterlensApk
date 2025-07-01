import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/indicator_card.dart';
import '../widgets/parameter_box.dart';

class HistoryDetailScreen extends StatelessWidget {
  final String documentId;

  const HistoryDetailScreen({super.key, required this.documentId});

  Future<Map<String, dynamic>> fetchDetail() async {
    final url = 'https://waterlens-backend-429035419724.asia-southeast2.run.app/histories/$documentId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat detail histori');
    }
  }

  Color getPHColor(String value) {
    final ph = double.tryParse(value) ?? 0;
    if (ph >= 6.5 && ph <= 8.5) return Colors.green;
    return Colors.red;
  }

  Color getTurbidityColor(String value) {
    final turb = double.tryParse(value) ?? 0;
    if (turb <= 5) return Colors.green;
    if (turb <= 50) return Colors.orange;
    return Colors.red;
  }

  Color getSolidsColor(String value) {
    final solids = double.tryParse(value) ?? 0;
    return solids <= 500 ? Colors.green : Colors.red;
  }

  Color getTemperatureColor(String value) {
    final temp = double.tryParse(value) ?? 0;
    return (temp >= 20 && temp <= 30) ? Colors.green : Colors.red;
  }

  String interpretPH(String phStr) {
    final ph = double.tryParse(phStr) ?? 0;
    if (ph >= 6.5 && ph <= 8.5) return 'pH dalam batas aman.';
    if (ph < 6.5) return 'Air bersifat asam.';
    return 'Air bersifat basa.';
  }

  String interpretTurbidity(String turbStr) {
    final turb = double.tryParse(turbStr) ?? 0;
    if (turb <= 5) return 'Kekeruhan rendah (jernih).';
    if (turb <= 50) return 'Sedikit keruh.';
    return 'Sangat keruh.';
  }

  String interpretSolids(String solidsStr) {
    final solids = double.tryParse(solidsStr) ?? 0;
    if (solids <= 500) return 'Zat terlarut dalam batas normal.';
    return 'Zat terlarut tinggi.';
  }

  String interpretTemp(String tempStr) {
    final temp = double.tryParse(tempStr) ?? 0;
    if (temp >= 20 && temp <= 30) return 'Suhu normal untuk air alami.';
    return 'Suhu di luar kisaran normal.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF8FD),
      appBar: const CustomAppBar(
        showBackButton: true,
        showInfoButton: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Data tidak ditemukan."));
          }

          final data = snapshot.data!;
          final status = data['status'] ?? 'Tidak diketahui';
          final ph = data['ph']?.toString() ?? '-';
          final turbidity = data['turbidity']?.toString() ?? '-';
          final solids = data['solids']?.toString() ?? '-';
          final temperature = data['temperature']?.toString() ?? '-';

          String waktu = '-';
          if (data['timestamp'] != null) {
            final dt = DateTime.parse(data['timestamp']).toLocal();
            waktu = DateFormat('EEEE, dd MMMM yyyy – HH:mm', 'id_ID').format(dt);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Detail Riwayat Analisis Air',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: status == 'Layak' ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Waktu analisis: $waktu",
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Indikator Kualitas Air:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1,
                  children: [
                    IndicatorCard(
                      label: 'pH (Keasaman)',
                      value: ph,
                      icon: Icons.science,
                      iconColor: getPHColor(ph),
                    ),
                    IndicatorCard(
                      label: 'Kekeruhan (NTU)',
                      value: turbidity,
                      icon: Icons.blur_on,
                      iconColor: getTurbidityColor(turbidity),
                    ),
                    IndicatorCard(
                      label: 'Zat Terlarut (mg/L)',
                      value: solids,
                      icon: Icons.opacity,
                      iconColor: getSolidsColor(solids),
                    ),
                    IndicatorCard(
                      label: 'Suhu (°C)',
                      value: temperature,
                      icon: Icons.thermostat,
                      iconColor: getTemperatureColor(temperature),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ParameterBox(
                  title: "Status Kelayakan",
                  content: status,
                  color: status == 'Layak'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                ),
                const SizedBox(height: 16),
                ParameterBox(
                  title: "Rangkuman",
                  content:
                      "• pH: $ph (${interpretPH(ph)})\n"
                      "• Kekeruhan: $turbidity NTU (${interpretTurbidity(turbidity)})\n"
                      "• Zat Terlarut: $solids mg/L (${interpretSolids(solids)})\n"
                      "• Suhu: $temperature°C (${interpretTemp(temperature)})",
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
