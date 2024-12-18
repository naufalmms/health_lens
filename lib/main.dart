import 'package:flutter/material.dart';
import 'package:health_lens/applications/database/firestore_service.dart';
import 'package:health_lens/providers/assesment_provider.dart';
import 'package:health_lens/screens/detection/viewmodel/depression_detection_viewmodel.dart';
import 'package:health_lens/screens/main/assessment_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/auth_provider.dart';
import 'providers/health_provider.dart';
import 'screens/wrapper.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize FirestoreService (singleton)
  final firestoreService = FirestoreService();

  // Initialize HealthProvider
  final healthProvider = HealthProvider();
  await healthProvider.initialize();

  final depressionProvider2 = DepressionDetectionProvider();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(
          value: firestoreService,
        ),
        // Provide the initialized HealthProvider
        ChangeNotifierProvider.value(
          value: healthProvider,
        ),

        ChangeNotifierProvider.value(
          value: depressionProvider2,
        ),
        // Create AuthProvider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AssessmentProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Health Lens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const Wrapper(),
      routes: {
        '/assessment': (context) => const AssessmentScreen(),
      },
    );
  }
}
