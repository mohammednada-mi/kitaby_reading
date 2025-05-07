import 'package:flutter/material.dart';
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/providers/book_provider.dart';
import 'package:kitaby_flutter/utils/constants.dart';
import 'package:kitaby_flutter/widgets/app_drawer.dart'; // Import AppDrawer
import 'package:kitaby_flutter/widgets/book_list.dart';
import 'package:provider/provider.dart';

class CategoryScreen
    extends
        StatelessWidget {
  final BookCategory
  category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  String
  _getCategoryTitle(
    BookCategory
    category,
  ) {
    return AppConstants.categoryDisplayNames[category] ??
        category.name
            .replaceAll(
              '_',
              ' ',
            )
            .toUpperCase(); // Fallback title
  }

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getCategoryTitle(
            category,
          ),
        ),
      ),
      drawer:
          const AppDrawer(), // Add the AppDrawer here
      body: RefreshIndicator(
        // Add pull-to-refresh
        onRefresh: () async {
          await Provider.of<
            BookProvider
          >(
            context,
            listen:
                false,
          ).loadBooks();
        },
        child: Consumer<
          BookProvider
        >(
          builder: (
            context,
            bookProvider,
            child,
          ) {
            // Handle loading state more gracefully
            final books = bookProvider.getBooksByCategory(
              category,
            );
            // Show loading indicator only if loading AND the list for this category is currently empty
            if (bookProvider.isLoading &&
                books.isEmpty) {
              return const Center(
                child:
                    CircularProgressIndicator(),
              );
            }

            // Use ListView to handle potential overflow and allow scrolling if many books
            return ListView(
              padding: const EdgeInsets.all(
                AppConstants.paddingMedium,
              ), // Consistent padding
              children: [
                BookList(
                  books:
                      books,
                  category:
                      category,
                ), // BookList handles empty case internally now
              ],
            );
          },
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
            4,
      ),
    );
  }
}
