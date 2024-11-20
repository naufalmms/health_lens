import 'package:flutter/material.dart';
import 'package:health_lens/applications/assets/i_assets.dart';
import 'package:health_lens/applications/components/image/i_image_component.dart';
import 'package:health_lens/applications/theme/i_colors.dart';
import 'package:health_lens/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/providers/health_provider.dart';
import 'package:health_lens/widgets/health_data_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeHealth();
  }

  Future<void> _initializeHealth() async {
    final healthProvider = context.read<HealthProvider>();

    // Check if Health Connect is needed and available
    if (healthProvider.serviceStatus == HealthServiceStatus.needsInstallation) {
      // Show dialog to install Health Connect
      _showHealthConnectDialog();
    } else if (healthProvider.serviceStatus == HealthServiceStatus.available) {
      await healthProvider.requestAuthorization();
      await _fetchData();
    }
  }

  Future<void> _fetchData() async {
    final healthProvider = context.read<HealthProvider>();
    await healthProvider.fetchHealthData();
    await healthProvider.fetchSteps();
  }

  Future<void> _showHealthConnectDialog() async {
    final healthProvider = context.read<HealthProvider>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Health Connect Required'),
        content: const Text(
            'This app requires Health Connect to access health data. Would you like to install it now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final installed = await healthProvider.installHealthConnect();
              if (installed) {
                await _initializeHealth();
              }
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, _) {
          if (healthProvider.serviceStatus != HealthServiceStatus.available) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Health services are not available'),
                  if (healthProvider.serviceStatus ==
                      HealthServiceStatus.needsInstallation)
                    ElevatedButton(
                      onPressed: _showHealthConnectDialog,
                      child: const Text('Install Health Connect'),
                    ),
                ],
              ),
            );
          }

          if (healthProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (healthProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(healthProvider.error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchData,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hey ${context.read<AuthProvider>().user?.displayName}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            "How are u feeling today?",
                            style: TextStyle(
                              fontSize: 15,
                              color: Palette.primaryColor,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const IImage(
                                image: IAssets.iconCall,
                                width: 20,
                              ),
                            ),
                            Container(
                              width: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const IImage(
                                image: IAssets.iconChat,
                                width: 20,
                              ),
                            ),
                            Container(
                              width: 40,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const IImage(
                                image: IAssets.iconNotif,
                                width: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                // Steps Card
                Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.directions_walk, size: 40),
                    title: const Text('Today\'s Steps'),
                    subtitle: Text(
                      '${healthProvider.steps}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),

                // Health Data List
                Expanded(
                  child: healthProvider.healthData.isEmpty
                      ? const Center(child: Text('No health data available'))
                      : ListView.builder(
                          itemCount: healthProvider.healthData.length,
                          itemBuilder: (context, index) {
                            final data = healthProvider.healthData[index];
                            return HealthDataItem(data: data);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
