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
      'question': '',
      'options': [
        {'text': 'Saya tidak merasa sedih', 'score': 0},
        {'text': 'Saya merasa sedih', 'score': 1},
        {
          'text':
              'Sepanjang waktu saya sedih dan tidak bisa menghilangkan perasaan itu',
          'score': 2
        },
        {
          'text':
              'Saya sedemikian sedih dan tidak bahagia sehingga saya tidak tahan lagi rasanya',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak terlalu berkecil hati mengenai masa depan saya',
          'score': 0
        },
        {'text': 'Saya merasa kecil hati tentang masa depan', 'score': 1},
        {
          'text': 'Saya merasa tidak ada suatupun yang saya harapkan',
          'score': 2
        },
        {
          'text':
              'Saya merasa bahwa masa depan saya tanpa harapan dan bahkan semuanya tidak akan membaik',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak menganggap diri saya sebagai seorang yang gagal',
          'score': 0
        },
        {
          'text':
              'Saya merasa bahwa saya telah gagal lebih dari kebanyakan orang',
          'score': 1
        },
        {
          'text':
              'Saat saya menengok masa lalu, maka yang terlihat oleh saya hanya kegagalan',
          'score': 2
        },
        {
          'text': 'Saya merasa bahwa saya adalah seorang yang gagal total',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Saya memperoleh banyak kepuasan dari hal-hal yang saya lakukan, sama seperti sebelumnya',
          'score': 0
        },
        {
          'text':
              'Saya tidak lagi menikmati berbagai hal, seperti yang pernah saya rasakan dulu',
          'score': 1
        },
        {
          'text': 'Saya tidak memperoleh kepuasan sejati dari apapun lagi',
          'score': 2
        },
        {'text': 'Saya tidak puas dan bosan dengan segalanya', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {'text': 'Saya tidak terlalu merasa bersalah', 'score': 0},
        {'text': 'Saya merasa bersalah di hampir tiap waktu', 'score': 1},
        {
          'text': 'Saya merasa bersalah di hampir sebagian waktu saya',
          'score': 2
        },
        {'text': 'Saya merasa bersalah di sepanjang waktu', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {'text': 'Saya tidak merasa seolah saya sedang dihukum', 'score': 0},
        {'text': 'Saya merasa mungkin saya sedang dihukum', 'score': 1},
        {'text': 'Saya pikir saya akan dihukum', 'score': 2},
        {'text': 'Saya merasa bahwa saya sedang dihukum', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak merasa kecewa terhadap diri saya sendiri',
          'score': 0
        },
        {'text': 'Saya agak kecewa terhadap diri saya sendiri', 'score': 1},
        {'text': 'Saya kecewa terhadap diri saya sendiri', 'score': 2},
        {'text': 'Saya membenci diri saya sendiri', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak merasa lebih buruk daripada orang lain',
          'score': 0
        },
        {
          'text':
              'Saya cela diri saya sendiri karena kelemahan atau kesalahan saya',
          'score': 1
        },
        {
          'text':
              'Saya menyalahkan diri saya sepanjang waktu karena kesalahan-kesalahan saya',
          'score': 2
        },
        {
          'text':
              'Saya menyalahakan diri saya untuk semua hal buruk yang terjadi',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak punya pikiran sedikitpun untuk bunuh diri',
          'score': 0
        },
        {'text': 'Saya ingin bunuh diri', 'score': 1},
        {'text': 'Saya kecewa terhadap diri saya sendiri', 'score': 2},
        {'text': 'Saya akan bunuh diri jika ada kesempatan', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak lebih banyak menangis dibandingkan biasanya',
          'score': 0
        },
        {
          'text': 'Sekarang saya lebih banyak menangis daripada sebelumnya',
          'score': 1
        },
        {'text': 'Saya sekarang menangis sepanjang waktu', 'score': 2},
        {
          'text':
              'Biasanya saya mampu menangis, namunkini saya tidak lagi bisa menangis walaupun saya menginginkannya',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Saya tidak terganggu oleh berbagai hal dibandingkan biasanya',
          'score': 0
        },
        {
          'text': 'Kini saya sedikit lebih parah dibandingkan biasanya',
          'score': 1
        },
        {
          'text':
              'Saya agak jengkel dan terganggu di sebagian besar waktu saya',
          'score': 2
        },
        {'text': 'Kini saya merasa jengkel sepanjang waktu', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {'text': 'Saya tidak kehilangan minat terhadap orang lain', 'score': 0},
        {
          'text':
              'Saya agak kurang berminat terhadap orang lain dibandingkan biasanya',
          'score': 1
        },
        {
          'text': 'Saya kehilangan seluruh minat saya terhadap orang lain',
          'score': 2
        },
        {
          'text': 'Saya telah kehilangan minat saya pada orang lain',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Saya mengambil keputusan hampir sama baiknya dengan yang biasanya saya lakukan',
          'score': 0
        },
        {
          'text':
              'Saya menunda mengambil keputusan lebih sering dari yang biasanya saya lakukan',
          'score': 1
        },
        {
          'text':
              'Saya mengalami kesulitan besar dalam mengambil keputusan daripada sebelumnya',
          'score': 2
        },
        {
          'text': 'Saya sama sekali tidak dapat mengambil keputusan lagi',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Saya tidak merasa bahwa keadaan saya tampak lebih buruk dari yang biasanya',
          'score': 0
        },
        {'text': 'Saya kuatir tampak tua dan tidak menarik', 'score': 1},
        {
          'text':
              'Saya merasa ada perubahan yang permanent dalam penampilan saya sehingga membuat saya nampak tidak menarik',
          'score': 2
        },
        {'text': 'Saya yakin bahwa saya nampak jelek', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Saya dapat bekerja sama baiknya dengan waktu-waktu sebelumnya',
          'score': 0
        },
        {
          'text':
              'Saya membutuhkan suatu usaha ekstra untuk memulai melakukan sesuatu',
          'score': 1
        },
        {
          'text':
              'Saya harus memaksa diri sekuat tenaga untuk melakukan sesuatu',
          'score': 2
        },
        {'text': 'Saya tidak mampu melakuakan apapun lagi', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {'text': 'Saya dapat tidur seperti biasanya', 'score': 0},
        {'text': 'Tidur saya tidak nyenyak seperti biasanya', 'score': 1},
        {
          'text':
              'Saya bagun 1-2 jam lebih awal dari biasanya dan merasa sukar sekali untuk bisa tidur Kembali',
          'score': 2
        },
        {
          'text':
              'Saya bangun beberapa jam lebih awal daripada biasanya serta tidak dapat tidur kembali',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {'text': 'Saya tidak merasa lebih lelah dari biasanya', 'score': 0},
        {'text': 'Saya merasa lebih mudah lelah dari biasanya', 'score': 1},
        {'text': 'Saya merasa lelah setelah melakukan apa saja', 'score': 2},
        {'text': 'Saya terlalu lelah untuk melakukan apapun', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Nafsu makan saya tidak lebih buruk dari biasanya',
          'score': 0
        },
        {'text': 'Nafsu makan saya tidak sebaik biasanya', 'score': 1},
        {'text': 'Nafsu makan saya kini jauh lebih buruk', 'score': 2},
        {'text': 'Saya tidak memiliki nafsu makan lagi', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Berat badan saya tidak turun banyak, atau bahkan tetap akhir-akhir ini',
          'score': 0
        },
        {'text': 'Berat badan saya turun lebih dari 5 kilogram', 'score': 1},
        {'text': 'Berat badan saya turun lebih dari 10 kilogram', 'score': 2},
        {'text': 'Berat badan saya turun lebih dari 15 kilogram', 'score': 3},
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text': 'Saya tidak cemas mengenai kesehatan saya dari biasanya',
          'score': 0
        },
        {
          'text':
              'Saya cemas mengenai masalah fisik seperti masalah sakit dan tidak enak badan atau perut mual dan sembelit',
          'score': 1
        },
        {
          'text':
              'Saya cemas mengenai masalah fisik dan sukar memikirkan banyak hal lainnya',
          'score': 2
        },
        {
          'text':
              'Saya cemas mengenai masalah fisik saya sehingga tidak dapat berpikir tentang hal yang lainnya',
          'score': 3
        },
      ]
    },
    {
      'question': '',
      'options': [
        {
          'text':
              'Saya tidak melihat adanya perubahan dalam minat saya terhadap lawan jenis',
          'score': 0
        },
        {
          'text':
              'Saya kurang berminat terhadap lawan jenis dibandingkan biasanya',
          'score': 1
        },
        {
          'text': 'Kini saya sangat kurang berminat terhadap lawan jenis',
          'score': 2
        },
        {
          'text':
              'Saya telah kehilangan minat terhadap lawan jenis sama sekali',
          'score': 3
        },
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
    // Ubah threshold sesuai kebutuhan
    bool isDepressed = _totalScore >= 10;
    // Kirim notifikasi untuk depresi sedang hingga berat
    if (_totalScore >= 19) {
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
    if (score >= 30) return Colors.red;
    if (score >= 19) return Colors.orange;
    if (score >= 10) return Colors.amber;
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
