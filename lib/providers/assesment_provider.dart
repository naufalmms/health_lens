import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:health_lens/applications/database/firestore_service.dart';
import 'package:health_lens/screens/assesment/model/assesment_result_model.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AssessmentProvider with ChangeNotifier {
  FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _error = '';
  String get error => _error;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Seberapa sering Anda merasa sedih atau putus asa?',
      'options': [
        {'text': 'Tidak pernah', 'score': 0},
        {'text': 'Beberapa hari', 'score': 1},
        {'text': 'Lebih dari setengah hari', 'score': 2},
        {'text': 'Hampir setiap hari', 'score': 3},
      ]
    },
    {
      'question':
          'Apakah Anda mengalami kesulitan tidur atau tidur berlebihan?',
      'options': [
        {'text': 'Tidak ada masalah tidur', 'score': 0},
        {'text': 'Kadang-kadang sulit tidur', 'score': 1},
        {'text': 'Sering mengalami gangguan tidur', 'score': 2},
        {'text': 'Hampir setiap malam mengalami masalah tidur', 'score': 3},
      ]
    },
    {
      'question': 'Seberapa sering Anda merasa lelah atau kehilangan energi?',
      'options': [
        {'text': 'Tidak pernah merasa lelah', 'score': 0},
        {'text': 'Kadang-kadang merasa lelah', 'score': 1},
        {'text': 'Sering merasa lelah', 'score': 2},
        {'text': 'Selalu merasa tidak berenergi', 'score': 3},
      ]
    },
    {
      'question': 'Apakah Anda mengalami perubahan nafsu makan?',
      'options': [
        {'text': 'Nafsu makan normal', 'score': 0},
        {'text': 'Sedikit perubahan nafsu makan', 'score': 1},
        {'text': 'Perubahan nafsu makan signifikan', 'score': 2},
        {'text': 'Kehilangan nafsu makan sama sekali', 'score': 3},
      ]
    },
    {
      'question': 'Seberapa sering Anda merasa sulit berkonsentrasi?',
      'options': [
        {'text': 'Dapat berkonsentrasi dengan baik', 'score': 0},
        {'text': 'Kadang-kadang sulit fokus', 'score': 1},
        {'text': 'Sering kesulitan berkonsentrasi', 'score': 2},
        {'text': 'Hampir selalu tidak dapat berkonsentrasi', 'score': 3},
      ]
    },
    {
      'question': 'Apakah Anda merasa gelisah atau tidak tenang?',
      'options': [
        {'text': 'Tidak pernah', 'score': 0},
        {'text': 'Kadang-kadang merasa gelisah', 'score': 1},
        {'text': 'Sering merasa tidak tenang', 'score': 2},
        {'text': 'Selalu merasa sangat gelisah', 'score': 3},
      ]
    },
    {
      'question': 'Seberapa sering Anda merasa rendah diri atau gagal?',
      'options': [
        {'text': 'Tidak pernah', 'score': 0},
        {'text': 'Jarang', 'score': 1},
        {'text': 'Sering', 'score': 2},
        {'text': 'Hampir setiap saat', 'score': 3},
      ]
    },
    {
      'question': 'Apakah Anda memiliki pikiran ingin menyakiti diri sendiri?',
      'options': [
        {'text': 'Tidak sama sekali', 'score': 0},
        {'text': 'Kadang-kadang terlintas', 'score': 1},
        {'text': 'Sering terpikirkan', 'score': 2},
        {'text': 'Memiliki rencana konkret', 'score': 3},
      ]
    },
    {
      'question':
          'Seberapa sering Anda kesulitan melakukan aktivitas sehari-hari?',
      'options': [
        {'text': 'Dapat melakukan aktivitas normal', 'score': 0},
        {'text': 'Sedikit terganggu', 'score': 1},
        {'text': 'Cukup sulit melakukan aktivitas', 'score': 2},
        {'text': 'Hampir tidak dapat melakukan apa-apa', 'score': 3},
      ]
    },
    {
      'question':
          'Apakah Anda merasa kehilangan minat atau kesenangan dalam aktivitas?',
      'options': [
        {'text': 'Tetap menikmati aktivitas', 'score': 0},
        {'text': 'Sedikit kehilangan minat', 'score': 1},
        {'text': 'Banyak kehilangan minat', 'score': 2},
        {'text': 'Sama sekali tidak tertarik', 'score': 3},
      ]
    }
  ];

  int _totalScore = 0;
  bool _assessmentComplete = false;
  List<int> _selectedAnswers = [];
  List<int> get selectedAnswers => _selectedAnswers;

  List<Map<String, dynamic>> get questions => _questions;
  int get totalScore => _totalScore;
  bool get assessmentComplete => _assessmentComplete;

  void answerQuestion(int questionIndex, int selectedOptionIndex) {
    while (_selectedAnswers.length <= questionIndex) {
      _selectedAnswers.add(-1);
    }
    _selectedAnswers[questionIndex] = selectedOptionIndex;
    notifyListeners();
  }

  Future<void> submitAssessment(String userId) async {
    if (_selectedAnswers.length != _questions.length) {
      throw Exception('Please answer all questions');
    }

    _totalScore = _selectedAnswers.asMap().entries.map((entry) {
      return _questions[entry.key]['options'][entry.value]['score'];
    }).reduce((a, b) => a + b);

    _assessmentComplete = true;

    // Interpret Score
    bool isDepressed = _totalScore >= 10;
    if (isDepressed) {
      _notifyEmergencyContact();
    }

    bool success = await firestoreService.saveAssessmentResults(
        userId: userId,
        totalScore: _totalScore,
        isDepressed: isDepressed,
        selectedAnswers: _selectedAnswers);

    if (success) {
      if (kDebugMode) {
        print('Assessment results saved successfully');
      }
    } else {
      if (kDebugMode) {
        print('Failed to save assessment results');
      }
    }

    notifyListeners();
  }

  void resetAssessment() {
    _totalScore = 0;
    _assessmentComplete = false;
    _selectedAnswers = [];
    notifyListeners();
  }

  Future<void> _notifyEmergencyContact() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final firestoreService = FirestoreService();
      final contacts = await firestoreService.getUserEmergencyContacts(userId);

      if (contacts != null && contacts['emergencyEmail'] != null) {
        try {
          // Konfigurasi SMTP untuk Gmail
          final smtpServer = gmail(
            'naufalmms003@gmail.com', // Email pengirim
            'rwhztwhhmyvxqzqz', // App Password
          );

          // Buat pesan email
          final message = Message()
            ..from = Address(contacts['userEmail'])
            ..recipients.add(contacts['emergencyEmail'])
            ..subject = 'Depression Symptoms Alert'
            ..text =
                'Depression symptoms have been detected. Please contact the user and recommend seeking professional help'
            // Opsional: tambahkan versi HTML
            ..html = '''
              <h1>Depression Symptoms Alert</h1>
              <p>Depression symptoms have been detected. Please contact the user and recommend seeking professional help.</p>
            ''';

          try {
            final sendReport = await send(message, smtpServer);

            if (kDebugMode) {
              print('Email sent: ${sendReport.toString()}');
            }
          } catch (e) {
            _error = 'Error sending email: $e';
            if (kDebugMode) {
              print(_error);
            }
          }
        } catch (e) {
          _error = 'Failed to send emergency notification: $e';
          if (kDebugMode) {
            print(_error);
          }
        }
      }
    }
  }

  List<AssessmentResult> assessmentHistory = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAssessmentHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = 'Silakan login terlebih dahulu';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      assessmentHistory = await firestoreService.getAssessmentHistory(user.uid);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Gagal memuat riwayat asesmen';
      notifyListeners();
    }
  }

  Color getScoreColor(int score) {
    if (score >= 20) return Colors.red;
    if (score >= 10) return Colors.orange;
    return Colors.green;
  }

  void showAssessmentDetail(BuildContext context, AssessmentResult assessment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Detail Jawaban',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: assessment.answers.length,
                itemBuilder: (context, index) {
                  final questionData = questions[index];
                  final selectedAnswer = assessment.answers[index];
                  final selectedOption =
                      questionData['options'][selectedAnswer];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pertanyaan ${index + 1}:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(questionData['question']),
                        const SizedBox(height: 4),
                        Text(
                          'Jawaban: ${selectedOption['text']} (Skor: ${selectedOption['score']})',
                          style: const TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
