import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_app_bar.dart';

enum FilterMode { fifteenLatest, thirtyLatest, all, byDate }

class ParameterData {
  final List<String> timestamps;
  final List<double> ph;
  final List<double> turbidity;
  final List<double> solids;
  final List<double> temperature;

  ParameterData({
    required this.timestamps,
    required this.ph,
    required this.turbidity,
    required this.solids,
    required this.temperature,
  });

  factory ParameterData.fromJson(Map<String, dynamic> json) {
    List<double> parseList(dynamic list) =>
        (list as List).map((e) => (e as num).toDouble()).toList();

    List<String> timestamps = (json['timestamp'] as List).map((e) => e.toString()).toList();

    return ParameterData(
      timestamps: timestamps,
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
  late Future<PotabilityData> potabilityData;
  FilterMode selectedFilter = FilterMode.fifteenLatest;
  int selectedRange = 15;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    futureData = fetchParameterData();
    potabilityData = fetchPotabilityData();
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

  Future<PotabilityData> fetchPotabilityData() async {
    final response = await http.get(
      Uri.parse('https://waterlens-backend-429035419724.asia-southeast2.run.app/potability'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PotabilityData.fromJson(jsonData);
    } else {
      throw Exception('Gagal memuat data potabilitas');
    }
  }

  List<FlSpot> convertToFlSpots(List<double> values, List<String> timestamps) {
    List<double> filteredValues;

    switch (selectedFilter) {
      case FilterMode.fifteenLatest:
        filteredValues = values.length > 15 ? values.sublist(values.length - 15) : values;
        break;
      case FilterMode.thirtyLatest:
        filteredValues = values.length > 30 ? values.sublist(values.length - 30) : values;
        break;
      case FilterMode.all:
        filteredValues = values;
        break;
      case FilterMode.byDate:
        if (selectedDate == null) return [];
        filteredValues = [];
        for (int i = 0; i < timestamps.length; i++) {
          DateTime date = DateTime.parse(timestamps[i]);
          if (date.year == selectedDate!.year && date.month == selectedDate!.month && date.day == selectedDate!.day) {
            filteredValues.add(values[i]);
          }
        }
        break;
    }

    return List.generate(
      filteredValues.length,
      (index) => FlSpot(index.toDouble(), filteredValues[index]),
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
                  Text("Halo !", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                  const SizedBox(height: 20),

                  FutureBuilder<PotabilityData>(
                    future: potabilityData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final potable = snapshot.data!.potable.toDouble();
                        final notPotable = snapshot.data!.notPotable.toDouble();
                        final total = potable + notPotable;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Persentase Kelayakan Air", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(value: potable, color: Colors.green, title: '${(potable / total * 100).toStringAsFixed(1)}%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    PieChartSectionData(value: notPotable, color: Colors.red, title: '${(notPotable / total * 100).toStringAsFixed(1)}%', titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("Gagal memuat grafik potabilitas");
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),

                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text("Kualitas Air Terkini", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                      DropdownButton<int>(
                        value: selectedRange,
                        items: const [
                          DropdownMenuItem(value: 15, child: Text("15 Terakhir")),
                          DropdownMenuItem(value: 30, child: Text("30 Terakhir")),
                          DropdownMenuItem(value: -1, child: Text("Semua")),
                          DropdownMenuItem(value: -2, child: Text("Tanggal Tertentu")),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedRange = value;
                              if (value == 15) {
                                selectedFilter = FilterMode.fifteenLatest;
                              } else if (value == 30) {
                                selectedFilter = FilterMode.thirtyLatest;
                              } else if (value == -1) {
                                selectedFilter = FilterMode.all;
                              } else if (value == -2) {
                                selectedFilter = FilterMode.byDate;
                              }
                            });
                          }
                        },
                      ),
                      if (selectedRange == -2)
                        ElevatedButton.icon(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2024, 1, 1),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: Text(
                            selectedDate != null ? "${selectedDate!.toLocal()}".split(' ')[0] : 'Pilih Tanggal',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade50,
                            foregroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  SensorChart(title: 'Suhu (°C)', color: Colors.orange, data: convertToFlSpots(data.temperature, data.timestamps)),
                  SensorChart(title: 'pH (Keasaman)', color: Colors.blue, data: convertToFlSpots(data.ph, data.timestamps)),
                  SensorChart(title: 'Zat Terlarut (mg/L)', color: Colors.green, data: convertToFlSpots(data.solids, data.timestamps)),
                  SensorChart(title: 'Kekeruhan (NTU)', color: Colors.purple, data: convertToFlSpots(data.turbidity, data.timestamps)),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: \${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class PotabilityData {
  final int potable;
  final int notPotable;

  PotabilityData({required this.potable, required this.notPotable});

  factory PotabilityData.fromJson(Map<String, dynamic> json) {
    return PotabilityData(
      potable: json['potable'],
      notPotable: json['not_potable'],
    );
  }
}

class SensorChart extends StatelessWidget {
  final String title;
  final Color color;
  final List<FlSpot> data;

  const SensorChart({super.key, required this.title, required this.color, required this.data});

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
                BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
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
                    getTooltipItems: (touchedSpots) => touchedSpots.map(
                      (spot) => LineTooltipItem(
                        '${spot.y.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white),
                      ),
                    ).toList(),
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
                            child: Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
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
                      getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(1), style: const TextStyle(fontSize: 10)),
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
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: color.withOpacity(0.1)),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
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
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.schedule, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text("Diperbarui otomatis setiap 5 menit", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

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
