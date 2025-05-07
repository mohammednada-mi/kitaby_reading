import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:kitaby_flutter/models/challenge.dart';
// import 'package:intl/intl.dart'; // Removed unused import
import 'package:percent_indicator/percent_indicator.dart';
import 'package:kitaby_flutter/screens/challenges_screen.dart'; // For navigation

class ChallengeProgressCard extends StatelessWidget {
  const ChallengeProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, child) {
        final activeChallenge = challengeProvider.getActiveChallenge();

        if (activeChallenge == null) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, size: 40, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text(
                    'لا توجد تحديات نشطة حاليًا.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddChallengeScreen()),
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('ابدأ تحديًا جديدًا'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary, backgroundColor: Theme.of(context).colorScheme.primary, // Text color
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        double progressPercent = 0.0;
        if (activeChallenge.goal > 0) {
          progressPercent = (activeChallenge.currentProgress / activeChallenge.goal).clamp(0.0, 1.0);
        }

        final typeText = activeChallenge.type == ChallengeType.books ? 'كتب' : 'صفحات';
        final remainingTime = formatRemainingTime(activeChallenge.endDate); // Use helper

        return GestureDetector(
           onTap: () {
              // Navigate to the main Challenges screen
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (context) => const ChallengesScreen()),
               );
           },
           child: Card(
             margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.flag_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                         Text(
                          'التحدي النشط',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الهدف: ${activeChallenge.goal} $typeText - ينتهي $remainingTime',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                         SizedBox(
                             width: 40, // Adjust size as needed
                             height: 40,
                           child: CircularPercentIndicator(
                             radius: 20.0,
                             lineWidth: 4.0,
                             percent: progressPercent,
                             center: Text(
                               "${(progressPercent * 100).toStringAsFixed(0)}%",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              progressColor: Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.grey.shade300,
                            ),
                         ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                'التقدم: ${activeChallenge.currentProgress} / ${activeChallenge.goal} $typeText',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                               const SizedBox(height: 4),
                              LinearPercentIndicator(
                                // Use LinearPercentIndicator here if preferred, or keep Circular
                                // width: MediaQuery.of(context).size.width - 150, // Adjust width
                                lineHeight: 8.0,
                                percent: progressPercent,
                                backgroundColor: Colors.grey.shade300,
                                progressColor: Theme.of(context).colorScheme.primary,
                                barRadius: const Radius.circular(5),
                              ),

                            ],
                          ),
                        ),
                      ],
                    ),
                     const SizedBox(height: 8),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                            onPressed: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (context) => const ChallengesScreen()),
                               );
                            },
                            child: const Text('عرض التفاصيل'),
                         ),
                      ),
                  ],
                ),
              ),
            ),
         );
      },
    );
  }

  // Helper function to format remaining time nicely
  String formatRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);

    if (difference.isNegative) {
      return 'منذ فترة'; // Challenge ended
    } else if (difference.inDays >= 1) {
       final days = difference.inDays;
      return 'خلال $days يوم${days > 1 ? '' : ''}';
    } else if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return 'خلال $hours ساعة${hours > 1 ? '' : ''}';
    } else {
       final minutes = difference.inMinutes;
       return 'خلال $minutes دقيقة${minutes > 1 ? '' : ''}';
    }
  }
}

// Placeholder AddChallengeScreen for navigation
class AddChallengeScreen extends StatelessWidget {
  const AddChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة تحدي جديد')),
      body: const Center(child: Text('شاشة إضافة التحدي')),
    );
  }
}
