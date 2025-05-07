import 'package:flutter/material.dart';
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:kitaby_flutter/widgets/app_drawer.dart'; // Keep drawer import
import 'package:kitaby_flutter/widgets/book_list.dart';
import 'package:kitaby_flutter/widgets/challenge_progress_card.dart';
import 'package:provider/provider.dart';
import 'package:kitaby_flutter/models/book.dart'; // Import Book model
import 'package:kitaby_flutter/utils/constants.dart'; // Import constants

class HomeScreen
    extends
        StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    // Access providers
    final challengeProvider = Provider.of<
      ChallengeProvider
    >(
      context,
    );
    final bookProvider = Provider.of<
      BookProvider
    >(
      context,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'كتابي',
        ),
      ),
      drawer:
          const AppDrawer(), // Keep the AppDrawer here
      body: RefreshIndicator(
        // Allow pull-to-refresh
        onRefresh: () async {
          // Use listen: false when calling methods inside build/callbacks
          await Provider.of<
            ChallengeProvider
          >(
            context,
            listen:
                false,
          ).loadChallenges();
          await Provider.of<
            BookProvider
          >(
            context,
            listen:
                false,
          ).loadBooks();
        },
        child: ListView(
          // Use ListView for scrollability
          padding: const EdgeInsets.all(
            AppConstants.paddingMedium,
          ), // Use constant
          children: [
            // --- Active Challenge Section ---
            Consumer<
              ChallengeProvider
            >(
              builder: (
                context,
                provider,
                child,
              ) {
                // Show loading indicator only when loading AND no data is present yet
                if (provider.isLoading &&
                    provider.currentActiveChallenge ==
                        null) {
                  // Simple centered indicator
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            AppConstants.paddingLarge,
                      ),
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }
                if (provider.currentActiveChallenge !=
                    null) {
                  return ChallengeProgressCard(
                    challenge:
                        provider.currentActiveChallenge!,
                  );
                } else {
                  // Show a message or a prompt to add a challenge
                  return Card(
                    margin: const EdgeInsets.only(
                      bottom:
                          AppConstants.paddingMedium,
                    ), // Ensure margin
                    child: Padding(
                      padding: const EdgeInsets.all(
                        AppConstants.paddingLarge,
                      ), // Use constant
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size:
                                30,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.secondary,
                          ),
                          const SizedBox(
                            height:
                                AppConstants.spacingSmall,
                          ), // Use constant
                          const Text(
                            'لا توجد تحديات نشطة حاليًا.',
                            textAlign:
                                TextAlign.center,
                          ),
                          const SizedBox(
                            height:
                                AppConstants.spacingSmall,
                          ), // Use constant
                          OutlinedButton(
                            onPressed:
                                () => Navigator.pushNamed(
                                  context,
                                  '/add-challenge',
                                ),
                            child: const Text(
                              'إنشاء تحدي جديد',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(
              height:
                  AppConstants.spacingLarge,
            ), // Use constant
            const Divider(), // Visual separator
            const SizedBox(
              height:
                  AppConstants.spacingMedium,
            ), // Use constant
            // --- Reading Now Section ---
            Padding(
              padding: const EdgeInsets.only(
                bottom:
                    AppConstants.paddingSmall,
              ), // Add padding below title
              child: Text(
                'الكتب التي أقرأها الآن',
                style:
                    Theme.of(
                      context,
                    ).textTheme.titleLarge,
              ),
            ),

            // Removed SizedBox here, padding added above
            Consumer<
              BookProvider
            >(
              builder: (
                context,
                provider,
                child,
              ) {
                if (provider.isLoading &&
                    provider.readingBooks.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical:
                            AppConstants.paddingLarge,
                      ),
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }
                // Pass only the 'reading' books to the BookList widget
                return BookList(
                  books: provider.getBooksByCategory(
                    BookCategory.reading,
                  ),
                  category:
                      BookCategory.reading, // Pass category to enable edit page
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/add-book',
            ),
        tooltip:
            'إضافة كتاب',
        child: const Icon(
          Icons.add,
        ),
        backgroundColor:
            Theme.of(
              context,
            ).colorScheme.tertiary, // Accent color
        foregroundColor:
            Theme.of(
              context,
            ).colorScheme.onTertiary,
        elevation:
            4, // Add some elevation
      ),
    );
  }
}
