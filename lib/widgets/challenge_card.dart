import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:kitaby_flutter/models/challenge.dart';
import 'package:kitaby_flutter/utils/constants.dart'; // For display names
import 'package:percent_indicator/linear_percent_indicator.dart'; // For progress bar
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:provider/provider.dart';

class ChallengeCard
    extends
        StatelessWidget {
  final Challenge
  challenge;
  final VoidCallback
  onDelete;
  final VoidCallback?
  onEditProgress; // Make optional if not editable
  final bool
  isPastChallenge; // Flag for styling

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onDelete,
    this.onEditProgress,
    this.isPastChallenge =
        false,
  });

  String
  _getChallengeTypeText(
    ChallengeType
    type,
  ) {
    return AppConstants.challengeTypeDisplayNames[type] ??
        type.name;
  }

  String
  _formatDate(
    DateTime
    date,
  ) {
    // Format date as 'yyyy/MM/dd'
    return DateFormat(
      'yyyy/MM/dd',
      'ar',
    ).format(
      date,
    );
  }

  String
  _formatRemainingTime(
    DateTime
    endDate,
  ) {
    final now =
        DateTime.now();
    final difference = endDate.difference(
      now,
    );

    if (difference
        .isNegative) {
      return "منتهي"; // Already past
    } else if (difference.inDays >=
        1) {
      return 'بعد ${difference.inDays} يوم';
    } else if (difference.inHours >=
        1) {
      return 'بعد ${difference.inHours} ساعة';
    } else if (difference.inMinutes >=
        1) {
      return 'بعد ${difference.inMinutes} دقيقة';
    } else {
      return 'قريبًا جدًا';
    }
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    final theme = Theme.of(
      context,
    );
    final colorScheme =
        theme.colorScheme;
    final progressPercent =
        challenge.progressPercentage /
        100.0; // Convert to 0.0-1.0 range
    final bool
    goalAchieved =
        challenge.currentProgress >=
        challenge.goal;

    return Card(
      margin: const EdgeInsets.symmetric(
        vertical:
            AppConstants.spacingSmall,
      ),
      elevation:
          1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppConstants.borderRadius,
        ),
        side:
            isPastChallenge
                ? BorderSide(
                  color:
                      goalAchieved
                          ? Colors.green.shade200
                          : Colors.red.shade200,
                  width:
                      1,
                )
                : BorderSide(
                  color:
                      colorScheme.outline,
                ), // Default border
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          AppConstants.paddingMedium,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // Header: Title and Status (for past challenges)
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تحدي ${_getChallengeTypeText(challenge.type)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                if (isPastChallenge)
                  goalAchieved
                      ? const Icon(
                        Icons.check_circle,
                        color:
                            Colors.green,
                        size:
                            20,
                      )
                      : Text(
                        'لم يكتمل',
                        style: TextStyle(
                          color:
                              colorScheme.error,
                          fontSize:
                              12,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ],
            ),
            const SizedBox(
              height:
                  AppConstants.spacingXSmall,
            ),

            // Description: Goal and End Date/Time Remaining
            Text(
              'الهدف: ${challenge.goal} ${_getChallengeTypeText(challenge.type)} - ${isPastChallenge ? "انتهى في: ${_formatDate(challenge.endDate)}" : "ينتهي ${_formatRemainingTime(challenge.endDate)}"}',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    colorScheme.secondary,
              ),
            ),
            const SizedBox(
              height:
                  AppConstants.spacingMedium,
            ),

            // Progress Bar and Text
            LinearPercentIndicator(
              padding:
                  EdgeInsets.zero,
              percent:
                  progressPercent,
              lineHeight:
                  8.0,
              backgroundColor: colorScheme.secondary.withOpacity(
                0.3,
              ),
              progressColor:
                  goalAchieved
                      ? Colors.green
                      : colorScheme.primary, // Green if achieved
              barRadius: const Radius.circular(
                4,
              ),
            ),
            const SizedBox(
              height:
                  AppConstants.spacingXSmall,
            ),
            Center(
              // Center the progress text
              child: Text(
                '${challenge.currentProgress} / ${challenge.goal} (${challenge.progressPercentage.toStringAsFixed(0)}%)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color:
                      colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(
              height:
                  AppConstants.spacingSmall,
            ),

            // Footer: Actions
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                // Only show edit button if callback is provided (i.e., for active challenges)
                if (onEditProgress !=
                    null)
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size:
                          20,
                    ),
                    tooltip:
                        'تعديل التقدم',
                    onPressed:
                        onEditProgress,
                    visualDensity:
                        VisualDensity.compact,
                  ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size:
                        20,
                    color:
                        colorScheme.error,
                  ),
                  tooltip:
                      'حذف التحدي',
                  onPressed:
                      onDelete,
                  visualDensity:
                      VisualDensity.compact,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
