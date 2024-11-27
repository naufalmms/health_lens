import 'package:flutter/material.dart';
import 'package:health_lens/providers/assesment_provider.dart';
import 'package:provider/provider.dart';

class AssessmentHistoryPage extends StatelessWidget {
  const AssessmentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Load assessment history when page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().loadAssessmentHistory();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Asesmen'),
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AssessmentProvider>().loadAssessmentHistory();
            },
          ),
        ],
      ),
      body: Consumer<AssessmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAssessmentHistory(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (provider.assessmentHistory.isEmpty) {
            return const Center(
              child: Text('Belum ada riwayat asesmen'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.assessmentHistory.length,
            itemBuilder: (context, index) {
              final assessment = provider.assessmentHistory[index];
              // final formattedDate = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID')
              //     .format(assessment.submittedAt);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () =>
                      provider.showAssessmentDetail(context, assessment),
                  leading: CircleAvatar(
                    backgroundColor:
                        provider.getScoreColor(assessment.totalScore),
                    child: Text(
                      assessment.totalScore.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Skor Total: ${assessment.totalScore}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      // Text('Tanggal: $formattedDate'),
                      Text(assessment.submittedAt.toString()),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${assessment.isDepressed ? 'Berisiko Depresi' : 'Normal'}',
                        style: TextStyle(
                          color: assessment.isDepressed
                              ? Colors.red
                              : Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
