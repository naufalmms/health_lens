import 'package:flutter/material.dart';
import 'package:health_lens/applications/assets/i_assets.dart';
import 'package:health_lens/providers/assesment_provider.dart';
import 'package:health_lens/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:health_lens/applications/components/dialog/i_dialog.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssessmentProvider>().resetAssessment();
    });
  }

  String _getAssessmentResult(int score) {
    if (score >= 20) {
      return 'Severe depression symptoms detected. Please seek professional help immediately.';
    } else if (score >= 10) {
      return 'Moderate depression symptoms detected. Consider consulting with a mental health professional.';
    } else if (score >= 5) {
      return 'Mild depression symptoms detected. Monitor your mood and consider talking to someone you trust.';
    } else {
      return 'No significant depression symptoms detected. Continue maintaining your mental well-being.';
    }
  }

  void _showResultDialog(BuildContext context, int score) {
    String result = _getAssessmentResult(score);

    IDialog().info(
      context,
      title: 'Assessment Result',
      description: 'Your assessment score: $score\n\n$result',
      image: IAssets.imgBannerLogin,
      onTapOk: () {
        Navigator.of(context).pop(); // Close the assessment screen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final assessmentProvider = context.watch<AssessmentProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Depression Assessment')),
      body: ListView.builder(
        itemCount: assessmentProvider.questions.length,
        itemBuilder: (context, index) {
          var question = assessmentProvider.questions[index];
          return Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ...List.generate(
                  question['options'].length,
                  (optionIndex) => RadioListTile(
                    title: Text(question['options'][optionIndex]['text']),
                    value: optionIndex,
                    groupValue:
                        assessmentProvider.selectedAnswers.length > index
                            ? assessmentProvider.selectedAnswers[index]
                            : null,
                    onChanged: (value) {
                      assessmentProvider.answerQuestion(index, value as int);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          child: const Text('Submit Assessment'),
          onPressed: () async {
            try {
              await assessmentProvider.submitAssessment(
                context.read<AuthProvider>().user!.uid,
              );
              if (mounted) {
                _showResultDialog(context, assessmentProvider.totalScore);
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
