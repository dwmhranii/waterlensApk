import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../widgets/custom_app_bar.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final String backendUrl =
      'https://waterlens-backend-429035419724.asia-southeast2.run.app/histories/latest';

  Future<Map<String, dynamic>> fetchLatestData() async {
    final response = await http.get(Uri.parse(backendUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat data air terkini');
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
      appBar: const CustomAppBar(),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchLatestData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("Belum ada data terkini."));
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
                    'Pantau Kualitas Air Saat Ini!',
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
                    "Terakhir diperbarui: $waktu",
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

class IndicatorCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const IndicatorCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class ParameterBox extends StatelessWidget {
  final String title;
  final String content;
  final Color color;

  const ParameterBox({
    super.key,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}
