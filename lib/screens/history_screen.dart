import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/custom_app_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isInitialized = false;
  bool isRangeMode = false;
  DateTime? selectedDate;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      setState(() {
        _isInitialized = true;
      });
    });
  }

  final String backendUrl =
      'https://waterlens-backend-429035419724.asia-southeast2.run.app/histories';

  Future<List<dynamic>> fetchHistories() async {
    final response = await http.get(Uri.parse(backendUrl));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return jsonBody['histories'];
    } else {
      throw Exception('Gagal memuat data dari backend');
    }
  }

  Widget buildDateButton({
    required String label,
    required VoidCallback onPressed,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.blue.shade800,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECF8FD),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Riwayat Deteksi Air",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                Switch(
                  value: isRangeMode,
                  onChanged: (val) {
                    setState(() {
                      isRangeMode = val;
                      selectedDate = null;
                      startDate = null;
                      endDate = null;
                    });
                  },
                ),
                Text(isRangeMode ? 'Rentang' : 'Per Hari'),
              ],
            ),
            const SizedBox(height: 8),
            if (!isRangeMode)
              Row(
                children: [
                  buildDateButton(
                    icon: Icons.calendar_today,
                    label: selectedDate != null
                        ? DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate!)
                        : 'Pilih Tanggal',
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        locale: const Locale('id', 'ID'),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                ],
              )
            else
              Row(
                children: [
                  buildDateButton(
                    icon: Icons.date_range,
                    label: startDate != null
                        ? DateFormat('dd MMM yyyy', 'id_ID').format(startDate!)
                        : 'Mulai',
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        locale: const Locale('id', 'ID'),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  buildDateButton(
                    icon: Icons.date_range,
                    label: endDate != null
                        ? DateFormat('dd MMM yyyy', 'id_ID').format(endDate!)
                        : 'Sampai',
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        locale: const Locale('id', 'ID'),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchHistories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("Belum ada data deteksi.");
                  }

                  final filteredData = snapshot.data!.where((data) {
                    final timestamp = DateTime.parse(data['timestamp']).toLocal();

                    if (!isRangeMode && selectedDate != null) {
                      return timestamp.year == selectedDate!.year &&
                          timestamp.month == selectedDate!.month &&
                          timestamp.day == selectedDate!.day;
                    }

                    if (isRangeMode && startDate != null && endDate != null) {
                      final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
                      final end = DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);
                      return timestamp.isAfter(start.subtract(const Duration(seconds: 1))) &&
                          timestamp.isBefore(end.add(const Duration(seconds: 1)));
                    }

                    return true;
                  }).toList();

                  if (filteredData.isEmpty) {
                    return const Text("Tidak ada data untuk filter yang dipilih.");
                  }

                  return ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final data = filteredData[index];
                      final timestamp = DateTime.parse(data['timestamp']).toLocal();
                      final dateFormatted =
                          DateFormat('EEEE, dd MMM yyyy HH:mm', 'id_ID').format(timestamp);

                      return HistoryCard(
                        tanggal: dateFormatted,
                        ph: data['ph']?.toString() ?? '-',
                        status: data['status'] ?? '-',
                        turbidity: data['turbidity']?.toString() ?? '-',
                        solids: data['solids']?.toString() ?? '-',
                        temperature: data['temperature']?.toString() ?? '-',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String tanggal, ph, status, turbidity, solids, temperature;

  const HistoryCard({
    super.key,
    required this.tanggal,
    required this.ph,
    required this.status,
    required this.turbidity,
    required this.solids,
    required this.temperature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          tanggal,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Status: $status',
          style: TextStyle(
            color: status == 'Layak' ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.expand_more),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // rata kiri
              children: [
                Text('Suhu (°C): $temperature'),
                Text('Zat Terlarut (mg/L): $solids'),
                Text('Kekeruhan (NTU): $turbidity'),
                Text('pH (Keasaman): $ph'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
