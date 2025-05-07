import 'package:flutter/material.dart';
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/widgets/book_card.dart';

class BookList
    extends
        StatelessWidget {
  final List<
    Book
  >
  books;
  final BookCategory
  category; // To determine if edit button should be shown

  const BookList({
    super.key,
    required this.books,
    required this.category,
  });

  @override
  Widget
  build(
    BuildContext
    context,
  ) {
    if (books
        .isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical:
                40.0,
          ),
          child: Text(
            'لا توجد كتب لعرضها في هذا التصنيف.',
            style: TextStyle(
              color:
                  Colors.grey,
              fontSize:
                  16,
            ),
            textAlign:
                TextAlign.center,
          ),
        ),
      );
    }

    // Determine if the edit current page button should be shown
    final bool
    showEditOption =
        category ==
            BookCategory.reading ||
        category ==
            BookCategory.completeLater;

    // Use ListView.builder for potentially long lists
    return ListView.builder(
      shrinkWrap:
          true, // Important if nested in another scroll view
      physics:
          const NeverScrollableScrollPhysics(), // Disable internal scrolling if nested
      itemCount:
          books.length,
      itemBuilder: (
        context,
        index,
      ) {
        final book =
            books[index];
        return BookCard(
          book:
              book,
          showEditCurrentPage:
              showEditOption,
        );
      },
    );

    /*
    // Alternative using Column (simpler for short lists)
    return Column(
      children: books.map((book) => BookCard(
          book: book,
          showEditCurrentPage: showEditOption,
      )).toList(),
    );
    */
  }
}
