import 'package:flutter/foundation.dart';
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/services/local_storage_service.dart';

class BookProvider
    with
        ChangeNotifier {
  final LocalStorageService
  _storageService =
      LocalStorageService();
  List<
    Book
  >
  _books =
      [];
  bool
  _isLoading =
      false;
  String?
  _errorMessage; // To store potential error messages

  List<
    Book
  >
  get books =>
      _books;
  bool
  get isLoading =>
      _isLoading;
  String?
  get errorMessage =>
      _errorMessage; // Getter for error message

  // Filtered lists for convenience
  List<
    Book
  >
  get readingBooks =>
      _books
          .where(
            (
              b,
            ) =>
                b.category ==
                BookCategory.reading,
          )
          .toList();
  List<
    Book
  >
  get readBooks =>
      _books
          .where(
            (
              b,
            ) =>
                b.category ==
                BookCategory.read,
          )
          .toList();
  List<
    Book
  >
  get wantToReadBooks =>
      _books
          .where(
            (
              b,
            ) =>
                b.category ==
                BookCategory.wantToRead,
          )
          .toList();
  List<
    Book
  >
  get completeLaterBooks =>
      _books
          .where(
            (
              b,
            ) =>
                b.category ==
                BookCategory.completeLater,
          )
          .toList();

  BookProvider() {
    loadBooks();
  }

  // Helper to set loading state and notify listeners
  void
  _setLoading(
    bool
    loading,
  ) {
    _isLoading =
        loading;
    notifyListeners();
  }

  // Helper to set error message and notify listeners
  void
  _setError(
    String?
    message,
  ) {
    _errorMessage =
        message;
    notifyListeners(); // Notify about error change as well
  }

  // Clear error message
  void
  clearError() {
    if (_errorMessage !=
        null) {
      _setError(
        null,
      );
    }
  }

  Future<
    void
  >
  loadBooks() async {
    _setLoading(
      true,
    );
    _setError(
      null,
    );
    try {
      _books =
          await _storageService.getBooks();
      _sortBooks();
    } catch (
      e
    ) {
      debugPrint(
        "Error loading books: $e",
      );
      _setError(
        "حدث خطأ أثناء تحميل الكتب. يرجى المحاولة مرة أخرى.",
      );
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<
    void
  >
  addBook(
    Book
    book,
  ) async {
    _setLoading(
      true,
    );
    _setError(
      null,
    );
    try {
      if (_books.any((b) => b.id == book.id)) {
        throw Exception("يوجد كتاب بنفس المعرف بالفعل");
      }
      await _storageService.addBook(
        book,
      );
      _books.add(
        book,
      );
      _sortBooks();
      notifyListeners();
    } catch (
      e
    ) {
      debugPrint(
        "Error adding book: $e",
      );
      _setError(
        e.toString().contains("يوجد كتاب") 
            ? e.toString() 
            : "حدث خطأ أثناء إضافة الكتاب. يرجى المحاولة مرة أخرى.",
      );
      throw e;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<
    void
  >
  updateBook(
    Book
    updatedBook,
  ) async {
    _setLoading(
      true,
    );
    _setError(
      null,
    );
    try {
      final index = _books.indexWhere(
        (
          b,
        ) =>
            b.id ==
            updatedBook.id,
      );
      if (index ==
          -1) {
        throw Exception("الكتاب غير موجود");
      }
      await _storageService.updateBook(
        updatedBook,
      );
      _books[index] =
          updatedBook;
      _sortBooks();
      notifyListeners();
    } catch (
      e
    ) {
      debugPrint(
        "Error updating book: $e",
      );
      _setError(
        e.toString().contains("الكتاب غير موجود") 
            ? e.toString() 
            : "حدث خطأ أثناء تحديث الكتاب. يرجى المحاولة مرة أخرى.",
      );
      throw e;
    } finally {
      _setLoading(
        false,
      );
    }
  }

  Future<
    void
  >
  updateBookCurrentPage(
    String
    bookId,
    int
    newPage,
  ) async {
    final index = _books.indexWhere(
      (
        b,
      ) =>
          b.id ==
          bookId,
    );
    if (index !=
        -1) {
      final currentBook =
          _books[index];
      if (newPage >=
              0 &&
          newPage <=
              currentBook.totalPages) {
        final updatedBook = currentBook.copyWith(
          currentPage:
              newPage,
        );
        // Call updateBook which handles loading state and errors
        await updateBook(
          updatedBook,
        );
      } else {
        debugPrint(
          "Invalid page number: $newPage for book ${currentBook.title}",
        );
        _setError(
          "رقم الصفحة غير صالح.",
        ); // Provide feedback
        // No re-throw here, just set error message
      }
    } else {
      debugPrint(
        "Book not found for page update: $bookId",
      );
      // Optionally set an error if this shouldn't happen
    }
  }

  Future<
    void
  >
  deleteBook(
    String
    bookId,
  ) async {
    // Optimistic UI update: remove immediately
    final index = _books.indexWhere(
      (
        b,
      ) =>
          b.id ==
          bookId,
    );
    if (index ==
        -1)
      return; // Book already removed or doesn't exist

    final bookToRemove =
        _books[index];
    _books.removeAt(
      index,
    );
    notifyListeners(); // Update UI immediately

    _setError(
      null,
    ); // Clear previous errors related to this action
    try {
      await _storageService.deleteBook(
        bookId,
      );
      // Deletion successful, UI is already updated
    } catch (
      e
    ) {
      debugPrint(
        "Error deleting book from storage: $e",
      );
      _setError(
        "فشل حذف الكتاب. حاول مرة أخرى.",
      );
      // Rollback: Add the book back to the list if storage deletion failed
      _books.insert(
        index,
        bookToRemove,
      );
      _sortBooks(); // Ensure order is maintained
      notifyListeners(); // Update UI again to show the book
      throw e;
    }
    // No loading state needed for optimistic update
  }

  // Helper to get books by category
  List<
    Book
  >
  getBooksByCategory(
    BookCategory
    category,
  ) {
    return _books
        .where(
          (
            b,
          ) =>
              b.category ==
              category,
        )
        .toList();
  }

  // Optional: Sorting logic (e.g., by title)
  void
  _sortBooks() {
    _books.sort(
      (
        a,
        b,
      ) => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
    );
  }

  // Method to get counts for sidebar
  int
  getCountForCategory(
    BookCategory
    category,
  ) {
    // Directly count without creating a new list if only count is needed
    return _books
        .where(
          (
            b,
          ) =>
              b.category ==
              category,
        )
        .length;
  }
}
