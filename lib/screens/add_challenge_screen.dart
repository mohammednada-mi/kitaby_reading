import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:kitaby_flutter/models/challenge.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:kitaby_flutter/utils/constants.dart'; // Import constants
import 'package:kitaby_flutter/widgets/app_drawer.dart'; // Import AppDrawer
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
// Intl package might not be strictly needed here if not formatting dates for display

class AddChallengeScreen
    extends
        StatefulWidget {
  const AddChallengeScreen({
    super.key,
  });

  @override
  State<
    AddChallengeScreen
  >
  createState() =>
      _AddChallengeScreenState();
}

class _AddChallengeScreenState
    extends
        State<
          AddChallengeScreen
        > {
  final _formKey =
      GlobalKey<
        FormState
      >();
  final _uuid =
      const Uuid();

  // Form field values
  ChallengeType?
  _selectedType;
  ChallengeDuration?
  _selectedDuration;
  final _goalController =
      TextEditingController();
  bool
  _isSubmitting =
      false;

  @override
  void
  dispose() {
    _goalController
        .dispose();
    super
        .dispose();
  }

  DateTime
  _calculateEndDate(
    DateTime
    startDate,
    ChallengeDuration
    duration,
  ) {
    switch (duration) {
      case ChallengeDuration.day:
        return startDate.add(
          const Duration(
            days:
                1,
          ),
        );
      case ChallengeDuration.week:
        return startDate.add(
          const Duration(
            days:
                7,
          ),
        );
      case ChallengeDuration.month:
        // Add one month
        return DateTime(
          startDate.year,
          startDate.month +
              1,
          startDate.day,
          startDate.hour,
          startDate.minute,
          startDate.second,
        );
      case ChallengeDuration.year:
        // Add one year
        return DateTime(
          startDate.year +
              1,
          startDate.month,
          startDate.day,
          startDate.hour,
          startDate.minute,
          startDate.second,
        );
    }
  }

  Future<
    void
  >
  _submitForm() async {
    // Hide keyboard
    FocusScope.of(
      context,
    ).unfocus();

    if (_formKey
        .currentState!
        .validate()) {
      setState(
        () =>
            _isSubmitting =
                true,
      );

      final challengeProvider = Provider.of<
        ChallengeProvider
      >(
        context,
        listen:
            false,
      );
      final String
      challengeId =
          'challenge_${_uuid.v4()}';
      final startDate =
          DateTime.now();
      // Ensure end date calculation happens *after* validation confirms duration is selected
      final endDate = _calculateEndDate(
        startDate,
        _selectedDuration!,
      );

      final newChallenge = Challenge(
        id:
            challengeId,
        type:
            _selectedType!, // Validation ensures non-null
        goal: int.parse(
          _goalController.text,
        ),
        duration:
            _selectedDuration!, // Validation ensures non-null
        startDate:
            startDate,
        endDate:
            endDate,
        currentProgress:
            0, // Initialize progress
      );

      try {
        await challengeProvider.addChallenge(
          newChallenge,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'تم إنشاء تحدي قراءة ${newChallenge.goal} ${AppConstants.challengeTypeDisplayNames[newChallenge.type] ?? newChallenge.type.name} بنجاح.',
            ),
            duration: const Duration(
              seconds:
                  2,
            ),
          ),
        );
        Navigator.pop(
          context,
        ); // Go back
      } catch (
        e
      ) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إضافة التحدي: $e',
            ),
            duration: const Duration(
              seconds:
                  2,
            ),
          ),
        );
        if (mounted) {
          setState(
            () =>
                _isSubmitting =
                    false,
          );
        }
      }
      // No finally block needed here as navigation pops the screen
    }
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'إضافة تحدي جديد',
        ),
      ),
      drawer:
          const AppDrawer(), // Add drawer if needed consistently
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          AppConstants.paddingLarge,
        ),
        child: Form(
          key:
              _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              // Challenge Type Dropdown
              DropdownButtonFormField<
                ChallengeType
              >(
                value:
                    _selectedType,
                hint: const Text(
                  'اختر نوع التحدي... *',
                ),
                decoration: const InputDecoration(
                  labelText:
                      'نوع التحدي *',
                ),
                items:
                    ChallengeType.values.map(
                      (
                        ChallengeType type,
                      ) {
                        return DropdownMenuItem<
                          ChallengeType
                        >(
                          value:
                              type,
                          child: Text(
                            AppConstants.challengeTypeDisplayNames[type] ??
                                type.name,
                          ),
                        );
                      },
                    ).toList(),
                onChanged: (
                  ChallengeType? newValue,
                ) {
                  setState(
                    () =>
                        _selectedType =
                            newValue,
                  );
                  // Trigger validation or update hint text for goal if needed
                  _formKey.currentState?.validate();
                },
                validator:
                    (
                      value,
                    ) =>
                        value ==
                                null
                            ? 'يرجى تحديد نوع التحدي.'
                            : null,
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // Goal Input
              TextFormField(
                controller:
                    _goalController,
                decoration: InputDecoration(
                  labelText:
                      'الهدف *',
                  hintText:
                      _selectedType ==
                              ChallengeType.books
                          ? 'مثال: 10 (كتب)'
                          : _selectedType ==
                              ChallengeType.pages
                          ? 'مثال: 1000 (صفحة)'
                          : 'مثال: 10 أو 1000', // Generic hint
                ),
                keyboardType:
                    TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textInputAction:
                    TextInputAction.next,
                validator: (
                  value,
                ) {
                  if (value ==
                          null ||
                      value.isEmpty)
                    return 'الهدف مطلوب.';
                  final goal = int.tryParse(
                    value,
                  );
                  if (goal ==
                          null ||
                      goal <=
                          0)
                    return 'أدخل هدف صحيح موجب.';
                  return null;
                },
              ),
              const SizedBox(
                height:
                    AppConstants.spacingMedium,
              ),

              // Duration Dropdown
              DropdownButtonFormField<
                ChallengeDuration
              >(
                value:
                    _selectedDuration,
                hint: const Text(
                  'اختر مدة التحدي... *',
                ),
                decoration: const InputDecoration(
                  labelText:
                      'مدة التحدي *',
                ),
                items:
                    ChallengeDuration.values.map(
                      (
                        ChallengeDuration duration,
                      ) {
                        return DropdownMenuItem<
                          ChallengeDuration
                        >(
                          value:
                              duration,
                          child: Text(
                            AppConstants.challengeDurationDisplayNames[duration] ??
                                duration.name,
                          ),
                        );
                      },
                    ).toList(),
                onChanged: (
                  ChallengeDuration? newValue,
                ) {
                  setState(
                    () =>
                        _selectedDuration =
                            newValue,
                  );
                },
                // Add focus node or onFieldSubmitted if needed
                validator:
                    (
                      value,
                    ) =>
                        value ==
                                null
                            ? 'يرجى تحديد مدة التحدي.'
                            : null,
              ),
              const SizedBox(
                height:
                    AppConstants.spacingLarge *
                    1.5,
              ), // More space before buttons
              // Submit Button
              ElevatedButton.icon(
                icon:
                    _isSubmitting
                        ? Container(
                          width:
                              20,
                          height:
                              20,
                          margin: const EdgeInsetsDirectional.only(
                            end:
                                AppConstants.spacingSmall,
                          ),
                          child: CircularProgressIndicator(
                            strokeWidth:
                                2,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                          ),
                        )
                        : const Icon(
                          Icons.add_task_outlined,
                        ), // Changed icon
                label: Text(
                  _isSubmitting
                      ? 'جاري الإنشاء...'
                      : 'إنشاء التحدي',
                ),
                onPressed:
                    _isSubmitting
                        ? null
                        : _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    45,
                  ),
                ),
              ),
              const SizedBox(
                height:
                    AppConstants.spacingSmall,
              ),
              // Cancel Button
              TextButton(
                child: const Text(
                  'إلغاء',
                ),
                onPressed:
                    _isSubmitting
                        ? null
                        : () => Navigator.pop(
                          context,
                        ),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
