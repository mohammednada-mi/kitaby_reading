import 'package:flutter/material.dart';
// For date formatting
import 'package:kitaby_flutter/models/challenge.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:kitaby_flutter/utils/constants.dart';
import 'package:kitaby_flutter/widgets/app_drawer.dart'; // Import AppDrawer
import 'package:kitaby_flutter/widgets/challenge_card.dart';
import 'package:provider/provider.dart';

class ChallengesScreen
    extends StatelessWidget {
  const ChallengesScreen({
    super.key,
  });

  @override
  Widget
      build(
    BuildContext
        context,
  ) {
    return Scaffold(
      appBar:
          AppBar(
        title: const Text(
          'تحديات القراءة',
        ),
        // Actions moved to FAB for consistency, or keep here if preferred
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.add_circle_outline),
        //     tooltip: 'إضافة تحدي جديد',
        //     onPressed: () => Navigator.pushNamed(context, '/add-challenge'),
        //   ),
        // ],
      ),
      drawer:
          const AppDrawer(), // Add the AppDrawer here
      body:
          RefreshIndicator(
        onRefresh: () async {
          try {
            await Provider.of<ChallengeProvider>(
              context,
              listen: false,
            ).loadChallenges();
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppConstants.messages['error']}: ${e.toString()}',
                ),
                duration: const Duration(
                  seconds: 3,
                ),
              ),
            );
          }
        },
        child: Consumer<ChallengeProvider>(
          builder: (
            context,
            provider,
            child,
          ) {
            // Show loading indicator only when loading AND no challenges are loaded yet
            if (provider.isLoading && provider.challenges.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.challenges.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(
                    AppConstants.paddingLarge,
                  ), // Use constant
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 60,
                        color: Theme.of(
                          context,
                        ).colorScheme.secondary,
                      ),
                      const SizedBox(
                        height: AppConstants.spacingMedium,
                      ), // Use constant
                      Text(
                        'لم تقم بإضافة أي تحديات بعد.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ), // Use theme
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: AppConstants.spacingMedium,
                      ), // Use constant
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add,
                        ),
                        label: const Text(
                          'ابدأ تحديًا جديدًا',
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          '/add-challenge',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use ListView.separated for better spacing between items/sections
            return ListView.separated(
              padding: const EdgeInsets.all(
                AppConstants.paddingMedium,
              ), // Use constant
              itemCount: (provider.activeChallenges.isNotEmpty ? 1 : 0) + // Header for active
                  provider.activeChallenges.length +
                  (provider.pastChallenges.isNotEmpty ? 1 : 0) + // Header for past
                  provider.pastChallenges.length,
              separatorBuilder: (
                context,
                index,
              ) {
                // Add extra space after the active challenges section if past challenges exist
                if (provider.activeChallenges.isNotEmpty && index == provider.activeChallenges.length) {
                  return const SizedBox(
                    height: AppConstants.spacingLarge,
                  ); // Larger separator
                }
                // Default small separator between cards
                return const SizedBox(
                  height: AppConstants.spacingSmall,
                ); // Use constant
              },
              itemBuilder: (
                context,
                index,
              ) {
                // Active Challenges Header
                if (provider.activeChallenges.isNotEmpty && index == 0) {
                  return _buildSectionHeader(
                    context,
                    'التحديات النشطة',
                    Icons.check_circle_outline,
                    Colors.green,
                  );
                }
                // Active Challenge Cards
                if (provider.activeChallenges.isNotEmpty && index <= provider.activeChallenges.length) {
                  final challenge = provider.activeChallenges[index - 1];
                  return ChallengeCard(
                    challenge: challenge,
                    onDelete: () => _confirmDelete(
                      context,
                      provider,
                      challenge,
                    ),
                    onEditProgress: () => _showEditProgressDialog(
                      context,
                      provider,
                      challenge,
                    ),
                  );
                }

                // Past Challenges Header
                int pastHeaderIndex = provider.activeChallenges.isNotEmpty ? provider.activeChallenges.length + 1 : 0;
                if (provider.pastChallenges.isNotEmpty && index == pastHeaderIndex) {
                  return _buildSectionHeader(
                    context,
                    'التحديات السابقة',
                    Icons.archive_outlined,
                    Colors.grey.shade600,
                  );
                }

                // Past Challenge Cards
                if (provider.pastChallenges.isNotEmpty && index > pastHeaderIndex) {
                  int pastChallengeIndex = index - pastHeaderIndex - 1;
                  final challenge = provider.pastChallenges[pastChallengeIndex];
                  return Opacity(
                    // Make past challenges visually distinct
                    opacity: 0.8, // Slightly less opaque
                    child: ChallengeCard(
                      challenge: challenge,
                      onDelete: () => _confirmDelete(
                        context,
                        provider,
                        challenge,
                      ),
                      // Disable editing progress for past challenges
                      onEditProgress: null,
                      isPastChallenge: true,
                    ),
                  );
                }
                return const SizedBox.shrink(); // Should not happen
              },
            );
          },
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/add-challenge',
        ),
        tooltip: 'إضافة تحدي',
        child: const Icon(
          Icons.add,
        ),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.tertiary, // Accent color
        foregroundColor: Theme.of(
          context,
        ).colorScheme.onTertiary,
        elevation: 4,
      ),
    );
  }

  Widget
      _buildSectionHeader(
    BuildContext
        context,
    String
        title,
    IconData
        icon,
    Color
        iconColor,
  ) {
    return Padding(
      // Add bottom padding to separate header from first card
      padding:
          const EdgeInsets.only(
        top: AppConstants.spacingMedium,
        bottom: AppConstants.spacingSmall,
        right: AppConstants.paddingSmall, // RTL padding
        left: AppConstants.paddingSmall,
      ),
      child:
          Row(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(
            width: AppConstants.spacingSmall,
          ), // Use constant
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Expanded(
            child: Divider(
              indent: AppConstants.spacingSmall,
              endIndent: AppConstants.spacingSmall,
            ),
          ), // Add divider line
        ],
      ),
    );
  }

  // --- Dialogs --- (Keep these as they are, but ensure context is passed correctly)

  Future<void>
      _confirmDelete(
    BuildContext
        context,
    ChallengeProvider
        provider,
    Challenge
        challenge,
  ) async {
    final bool?
        confirm =
        await showDialog<bool>(
      context:
          context,
      builder:
          (
        BuildContext dialogContext,
      ) {
        // Use different context name
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius,
            ),
          ),
          title: const Text(
            AppConstants.messages['confirm']!,
          ),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف هذا التحدي؟',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppConstants.messages['cancel']!,
              ),
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(
                false,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppConstants.errorColor,
              ),
              child: Text(
                AppConstants.messages['delete']!,
              ),
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(
                true,
              ),
            ),
          ],
        );
      },
    );

    if (confirm ==
        true) {
      try {
        // Use listen: false when calling provider methods in callbacks
        await provider.deleteChallenge(
          challenge.id,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              AppConstants.messages['success']!,
            ),
            duration: const Duration(
              seconds: 3,
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '${AppConstants.messages['error']}: ${e.toString()}',
            ),
            duration: const Duration(
              seconds: 3,
            ),
          ),
        );
      }
    }
  }

  Future<void>
      _showEditProgressDialog(
    BuildContext
        context,
    ChallengeProvider
        provider,
    Challenge
        challenge,
  ) async {
    final TextEditingController
        progressController =
        TextEditingController(
      text:
          challenge.currentProgress.toString(),
    );
    final formKey =
        GlobalKey<FormState>(); // For validation

    final bool? confirm = await showDialog<
        bool>(
      context:
          context,
      builder:
          (
        BuildContext dialogContext,
      ) {
        // Use different context name
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadius,
            ),
          ),
          title: Text(
            AppConstants.messages['edit']!,
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: progressController,
              decoration: InputDecoration(
                labelText: 'التقدم الحالي',
                border: const OutlineInputBorder(),
                suffixText: AppConstants.challengeTypeDisplayNames[challenge.type],
              ),
              keyboardType: TextInputType.number,
              validator: (
                value,
              ) {
                if (value == null || value.isEmpty) {
                  return AppConstants.validationMessages['required'];
                }
                final progress = int.tryParse(
                  value,
                );
                if (progress == null || progress < 0) {
                  return AppConstants.validationMessages['positiveNumber'];
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppConstants.messages['cancel']!,
              ),
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(
                false,
              ),
            ),
            TextButton(
              child: Text(
                AppConstants.messages['save']!,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(
                    dialogContext,
                  ).pop(
                    true,
                  );
                }
              },
            ),
          ],
        );
      },
    );

    if (confirm ==
        true) {
      try {
        final newProgress = int.parse(
          progressController.text,
        );
        await provider.updateChallengeProgress(
          challenge.id,
          newProgress,
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              AppConstants.messages['success']!,
            ),
            duration: const Duration(
              seconds: 3,
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              '${AppConstants.messages['error']}: ${e.toString()}',
            ),
            duration: const Duration(
              seconds: 3,
            ),
          ),
        );
      }
    }
  }
}
