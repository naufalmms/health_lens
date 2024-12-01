import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:health_lens/providers/health_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PhysicalActivityDetailPage extends StatefulWidget {
  const PhysicalActivityDetailPage({super.key});

  @override
  _PhysicalActivityDetailPageState createState() =>
      _PhysicalActivityDetailPageState();
}

class _PhysicalActivityDetailPageState
    extends State<PhysicalActivityDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPhysicalActivityData();
    });
  }

  Future<void> _fetchPhysicalActivityData() async {
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    await healthProvider.fetchPhysicalActivityData();
  }

  // Fungsi untuk menghitung total durasi aktivitas keseluruhan
  double _calculateTotalActivityDuration(List<HealthDataPoint> data) {
    return data.isEmpty
        ? 0
        : data
                .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                .reduce((a, b) => a + b) /
            60.0;
  }

  // Fungsi untuk menghitung rata-rata durasi aktivitas keseluruhan
  double _calculateAvgActivityDuration(List<HealthDataPoint> data) {
    log("Total data: ${data.length}");

    final activityData = data
        .where((point) =>
            point.type == HealthDataType.STEPS &&
            point.dateTo.difference(point.dateFrom).inMinutes > 0)
        .toList();

    log("Jumlah data aktivitas: ${activityData.length}");

    if (activityData.isEmpty) return 0.0;

    // Hitung rata-rata durasi aktivitas dalam jam
    final totalDuration = activityData
            .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
            .reduce((a, b) => a + b) /
        60.0;

    final avgDuration = totalDuration / activityData.length;

    log("Total durasi: $totalDuration");
    log("Rata-rata durasi: $avgDuration");

    return avgDuration;
  }

  // Fungsi untuk menghitung total langkah keseluruhan
  int _calculateTotalSteps(List<HealthDataPoint> data) {
    final stepsData = data.where((point) => point.type == HealthDataType.STEPS);
    return stepsData.isNotEmpty
        ? stepsData.map((e) {
            // Langsung ambil numericValue dari NumericHealthValue
            if (e.value is NumericHealthValue) {
              return (e.value as NumericHealthValue).numericValue.toInt();
            }
            return 0;
          }).reduce((a, b) => a + b)
        : 0;
  }

  // Fungsi untuk memfilter data hanya untuk hari ini
  List<HealthDataPoint> _filterTodayData(List<HealthDataPoint> data) {
    final today = DateTime.now();
    return data
        .where((point) =>
            point.dateFrom.year == today.year &&
            point.dateFrom.month == today.month &&
            point.dateFrom.day == today.day)
        .toList();
  }

  // Fungsi untuk menghitung total durasi aktivitas harian
  double _calculateTodayActivityDuration(List<HealthDataPoint> data) {
    final todayData = _filterTodayData(data);
    return todayData.isEmpty
        ? 0
        : todayData
                .map((e) => e.dateTo.difference(e.dateFrom).inMinutes)
                .reduce((a, b) => a + b) /
            60.0;
  }

  // Fungsi untuk menghitung total langkah harian
  int _calculateTodaySteps(List<HealthDataPoint> data) {
    final todayData = _filterTodayData(data);
    final stepsData =
        todayData.where((point) => point.type == HealthDataType.STEPS);

    return stepsData.isNotEmpty
        ? stepsData.map((e) {
            // Langsung ambil numericValue dari NumericHealthValue
            if (e.value is NumericHealthValue) {
              return (e.value as NumericHealthValue).numericValue.toInt();
            }
            return 0;
          }).reduce((a, b) => a + b)
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Aktivitas Fisik'),
        backgroundColor: Colors.green[100],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.error.isNotEmpty) {
            return Center(
              child: Text(
                'Terjadi Kesalahan: ${healthProvider.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final activityData = healthProvider.physicalActivityData;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Ringkasan Aktivitas Harian
              _buildRingkasanHarian(activityData),

              const SizedBox(height: 16),

              // Ringkasan Statistik Keseluruhan
              _buildStatistikKeseluruhan(activityData),

              const SizedBox(height: 16),

              // Daftar Detail Aktivitas
              _buildDaftarDetailAktivitas(activityData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRingkasanHarian(List<HealthDataPoint> activityData) {
    final todayDate = DateTime.now();
    final todayData = _filterTodayData(activityData);

    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aktivitas Hari Ini (${DateFormat('dd MMMM yyyy').format(todayDate)})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailStatistik('Durasi Aktivitas',
                    '${_calculateTodayActivityDuration(activityData).toStringAsFixed(1)} jam'),
                _buildDetailStatistik('Rata-rata Aktivitas',
                    '${_calculateAvgActivityDuration(todayData).toStringAsFixed(1)} jam'),
                _buildDetailStatistik(
                    'Total Langkah', '${_calculateTodaySteps(activityData)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistikKeseluruhan(List<HealthDataPoint> activityData) {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Aktivitas Keseluruhan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDetailStatistik('Total Durasi',
                    '${_calculateTotalActivityDuration(activityData).toStringAsFixed(1)} jam'),
                _buildDetailStatistik('Rata-rata Aktivitas',
                    '${_calculateAvgActivityDuration(activityData).toStringAsFixed(1)} jam'),
                _buildDetailStatistik(
                    'Total Langkah', '${_calculateTotalSteps(activityData)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftarDetailAktivitas(List<HealthDataPoint> activityData) {
    return Card(
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Detail Aktivitas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activityData.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final dataPoint = activityData[index];
              final duration = dataPoint.dateTo.difference(dataPoint.dateFrom);

              return ListTile(
                title: Text('Jenis Aktivitas: ${dataPoint.type.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  'Durasi: ${duration.inHours} jam ${duration.inMinutes % 60} menit\n'
                  'Waktu: ${DateFormat('dd MMM yyyy HH:mm').format(dataPoint.dateFrom)} '
                  '- ${DateFormat('dd MMM yyyy HH:mm').format(dataPoint.dateTo)}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatistik(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
