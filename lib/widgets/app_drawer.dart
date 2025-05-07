import 'package:flutter/material.dart';
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/providers/challenge_provider.dart';
import 'package:kitaby_flutter/utils/constants.dart'; // Import constants
import 'package:provider/provider.dart';

class AppDrawer
    extends
        StatelessWidget {
  const AppDrawer({
    super.key,
  });

  // Helper to build list tiles, reducing repetition
  Widget
  _buildDrawerItem({
    required BuildContext
    context,
    required IconData
    icon,
    required String
    title,
    required String
    routeName,
    String?
    currentRoute,
    int?
    badgeCount, // Optional badge count
    Object?
    arguments, // Optional arguments for named routes
  }) {
    final bool
    isSelected =
        currentRoute ==
        routeName;
    return ListTile(
      leading: Icon(
        icon,
        color:
            isSelected
                ? Theme.of(
                  context,
                ).primaryColor
                : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight:
              isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
      trailing:
          badgeCount !=
                      null &&
                  badgeCount >
                      0
              ? Chip(
                label: Text(
                  badgeCount.toString(),
                ),
                padding: const EdgeInsets.all(
                  0,
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal:
                      6,
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondary.withOpacity(
                  0.7,
                ),
                labelStyle: TextStyle(
                  fontSize:
                      11,
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                ),
              )
              : null,
      selected:
          isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.secondary.withOpacity(
        0.5,
      ),
      onTap: () {
        // Close the drawer first
        Navigator.pop(
          context,
        );
        // Navigate, replacing if it's the same route to avoid build-up
        if (isSelected)
          return; // Already on this page
        Navigator.pushReplacementNamed(
          context,
          routeName,
          arguments:
              arguments,
        );
      },
    );
  }

  // Helper to build category list tiles
  Widget
  _buildCategoryItem(
    BuildContext
    context,
    BookProvider
    bookProvider,
    BookCategory
    category,
    String
    currentRoute,
  ) {
    final routeName =
        '/category/${bookCategoryToString(category)}';
    final bool
    isSelected =
        currentRoute ==
        routeName;

    return ListTile(
      leading: Icon(
        AppConstants.categoryIcons[category] ??
            Icons.book,
        color:
            isSelected
                ? Theme.of(
                  context,
                ).primaryColor
                : null,
      ),
      title: Text(
        AppConstants.categoryDisplayNames[category] ??
            category.name,
        style: TextStyle(
          fontWeight:
              isSelected
                  ? FontWeight.bold
                  : FontWeight.normal,
        ),
      ),
      trailing: Consumer<
        BookProvider
      >(
        // Use Consumer to update count dynamically
        builder: (
          context,
          provider,
          child,
        ) {
          final count = provider.getCountForCategory(
            category,
          );
          return count >
                  0
              ? Chip(
                label: Text(
                  count.toString(),
                ),
                padding: const EdgeInsets.all(
                  0,
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal:
                      6,
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondary.withOpacity(
                  0.7,
                ),
                labelStyle: TextStyle(
                  fontSize:
                      11,
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                ),
              )
              : const SizedBox.shrink();
        },
      ),
      selected:
          isSelected,
      selectedTileColor: Theme.of(
        context,
      ).colorScheme.secondary.withOpacity(
        0.5,
      ),
      onTap: () {
        Navigator.pop(
          context,
        ); // Close drawer
        if (isSelected)
          return; // Don't navigate if already on the page
        // Navigate to category screen using the specific category
        Navigator.pushReplacementNamed(
          context,
          '/category',
          arguments:
              category,
        );
      },
    );
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    final bookProvider = Provider.of<
      BookProvider
    >(
      context,
      listen:
          false,
    ); // No need to listen for counts here, Consumer handles it
    final challengeProvider = Provider.of<
      ChallengeProvider
    >(
      context,
    );
    final String?
    currentRoute =
        ModalRoute.of(
          context,
        )?.settings.name;

    return Drawer(
      child: ListView(
        padding:
            EdgeInsets.zero,
        children: <
          Widget
        >[
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  Theme.of(
                    context,
                  ).primaryColor, // Use primary color
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.book_outlined,
                  size:
                      40,
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onPrimary,
                ),
                const SizedBox(
                  height:
                      8,
                ),
                Text(
                  'كتابي',
                  style: TextStyle(
                    color:
                        Theme.of(
                          context,
                        ).colorScheme.onPrimary, // Use primary foreground
                    fontSize:
                        24,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context:
                context,
            icon:
                Icons.home_outlined,
            title:
                'الرئيسية',
            routeName:
                '/',
            currentRoute:
                currentRoute,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  16.0,
              vertical:
                  8.0,
            ),
            child: Text(
              'التصنيفات',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.grey,
              ),
            ),
          ),
          _buildCategoryItem(
            context,
            bookProvider,
            BookCategory.reading,
            currentRoute ??
                '',
          ),
          _buildCategoryItem(
            context,
            bookProvider,
            BookCategory.read,
            currentRoute ??
                '',
          ),
          _buildCategoryItem(
            context,
            bookProvider,
            BookCategory.wantToRead,
            currentRoute ??
                '',
          ),
          _buildCategoryItem(
            context,
            bookProvider,
            BookCategory.completeLater,
            currentRoute ??
                '',
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal:
                  16.0,
              vertical:
                  8.0,
            ),
            child: Text(
              'التحديات',
              style: TextStyle(
                fontWeight:
                    FontWeight.bold,
                color:
                    Colors.grey,
              ),
            ),
          ),
          _buildDrawerItem(
            context:
                context,
            icon:
                Icons.emoji_events_outlined, // Target icon
            title:
                'التحديات النشطة',
            routeName:
                '/challenges',
            currentRoute:
                currentRoute,
            badgeCount:
                challengeProvider.activeChallengeCount, // Use dynamic count
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(
              16.0,
            ),
            child: Column(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                  label: const Text(
                    'إضافة كتاب جديد',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      40,
                    ), // Make button full width
                    alignment:
                        Alignment.centerRight, // Align text/icon right for RTL
                    padding: const EdgeInsets.only(
                      right:
                          12,
                    ), // Adjust padding
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Close drawer
                    Navigator.pushNamed(
                      context,
                      '/add-book',
                    );
                  },
                ),
                const SizedBox(
                  height:
                      8,
                ),
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.add_task_outlined,
                  ),
                  label: const Text(
                    'إضافة تحدي جديد',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      40,
                    ),
                    alignment:
                        Alignment.centerRight,
                    padding: const EdgeInsets.only(
                      right:
                          12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                    ); // Close drawer
                    Navigator.pushNamed(
                      context,
                      '/add-challenge',
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
