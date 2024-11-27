import 'package:flutter/material.dart';
// import 'package:health_lens/providers/depression_provider.dart';
// import 'package:health_lens/providers/health_provider.dart';
// import 'package:health_lens/screens/main/assessment_screen.dart';
// import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
// import 'package:provider/provider.dart';

class DepressionDetectionScreen extends StatelessWidget {
  const DepressionDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Depression Detection')),
        body: const SizedBox()

        // Consumer2<HealthProvider, DepressionProvider>(
        //   builder: (context, healthProvider, depressionProvider, child) {
        //     if (healthProvider.isLoading || depressionProvider.isLoading) {
        //       return const Center(child: CircularProgressIndicator());
        //     }

        //     return Padding(
        //       padding: const EdgeInsets.all(16.0),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.stretch,
        //         children: [
        //           const Text(
        //             'Health Data Analysis',
        //           ),
        //           const SizedBox(height: 16),
        //           if (healthProvider.error.isNotEmpty)
        //             Text(
        //               healthProvider.error,
        //               style: const TextStyle(color: Colors.red),
        //             ),
        //           if (depressionProvider.error.isNotEmpty)
        //             Text(
        //               depressionProvider.error,
        //               style: const TextStyle(color: Colors.red),
        //             ),
        //           ElevatedButton(
        //             onPressed: () async {
        //               await depressionProvider.analyzeDepressionRisk();
        //             },
        //             child: const Text('Analyze Health Data'),
        //           ),
        //           // if (depressionProvider.isDepressed) ...[
        //           const SizedBox(height: 16),
        //           const Text(
        //             'Warning: Depression risk detected',
        //             style:
        //                 TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        //           ),
        //           const SizedBox(height: 8),
        //           ElevatedButton(
        //             onPressed: () {
        //               pushScreen(
        //                 context,
        //                 screen: const AssessmentScreen(),
        //                 withNavBar: false,
        //               );
        //             },
        //             child: const Text('Take Assessment'),
        //           ),
        //         ],
        //         // ],
        //       ),
        //     );
        //   },
        // ),
        );
  }
}
