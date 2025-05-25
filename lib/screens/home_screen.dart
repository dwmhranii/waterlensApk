import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

import '../widgets/custom_app_bar.dart';

class ParameterData {
  final List<double> ph;
  final List<double> turbidity;
  final List<double> solids;
  final List<double> temperature;

  ParameterData({
    required this.ph,
    required this.turbidity,
    required this.solids,
    required this.temperature,
  });

  factory ParameterData.fromJson(Map<String, dynamic> json) {
    List<double> parseList(dynamic list) =>
        (list as List).map((e) => (e as num).toDouble()).toList();

    return ParameterData(
      ph: parseList(json['ph']),
      turbidity: parseList(json['turbidity']),
      solids: parseList(json['solids']),
      temperature: parseList(json['temperature']),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ParameterData> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchParameterData();
  }

  Future<ParameterData> fetchParameterData() async {
    final response = await http.get(
      Uri.parse('https://waterlens-backend-429035419724.asia-southeast2.run.app/parameters'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return ParameterData.fromJson(jsonData);
    } else {
      throw Exception('Gagal memuat data parameter');
    }
  }

  List<FlSpot> convertToFlSpots(List<double> data) {
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<ParameterData>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo !",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: Text("📸 Carousel atau Gambar")),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Kualitas Air Terkini",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SensorChart(
                    title: 'Suhu (°C)',
                    color: Colors.orange,
                    data: convertToFlSpots(data.temperature),
                  ),
                  SensorChart(
                    title: 'pH',
                    color: Colors.blue,
                    data: convertToFlSpots(data.ph),
                  ),
                  SensorChart(
                    title: 'Total Padatan Terlarut (TDS)',
                    color: Colors.green,
                    data: convertToFlSpots(data.solids),
                  ),
                  SensorChart(
                    title: 'Kekeruhan (Turbidity)',
                    color: Colors.purple,
                    data: convertToFlSpots(data.turbidity),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class SensorChart extends StatelessWidget {
  final String title;
  final Color color;
  final List<FlSpot> data;

  const SensorChart({
    super.key,
    required this.title,
    required this.color,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map((spot) => LineTooltipItem(
                              '${spot.y.toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            ))
                        .toList(),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: _calculateInterval(data),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: Colors.black26),
                    bottom: BorderSide(color: Colors.black26),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 3,
                        color: color,
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Otomatis menentukan jarak antar garis Y
  double _calculateInterval(List<FlSpot> data) {
    if (data.isEmpty) return 1;
    double min = data.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double max = data.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double range = max - min;
    if (range <= 1) return 0.2;
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    return (range / 5).roundToDouble();
  }
}