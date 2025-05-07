import 'dart:convert';
import 'dart:io'; // Import dart:io for File operations
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/models/challenge.dart';
import 'package:kitaby_flutter/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart'; // For storing image files
import 'package:path/path.dart'
    as p; // For path manipulation

class LocalStorageService {
  static const String
  _booksKey =
      'kitaby_books';
  static const String
  _challengesKey =
      'kitaby_challenges';
  static const String
  _coverImageDir =
      'book_covers'; // Directory name for covers

  Future<
    SharedPreferences
  >
  _getPrefs() async {
    try {
      return await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Error getting SharedPreferences: $e');
      throw Exception(AppConstants.messages['error']);
    }
  }

  // --- Book Functions ---

  Future<
    List<
      Book
    >
  >
  getBooks() async {
    try {
      final prefs =
          await _getPrefs();
      final String?
      booksString = prefs.getString(
        _booksKey,
      );
      if (booksString !=
              null &&
          booksString.isNotEmpty) {
        final List<
          dynamic
        >
        bookList = json.decode(
          booksString,
        );
        return bookList
            .map(
              (
                json,
              ) => Book.fromMap(
                json
                    as Map<
                      String,
                      dynamic
                    >,
              ),
            )
            .toList();
      }
      return [];
    } catch (
      e
    ) {
      debugPrint(
        'Error reading books from SharedPreferences: $e',
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  _saveBooks(
    List<
      Book
    >
    books,
  ) async {
    try {
      final prefs =
          await _getPrefs();
      final String
      booksString = json.encode(
        books
            .map(
              (
                book,
              ) =>
                  book.toMap(),
            )
            .toList(),
      );
      await prefs.setString(
        _booksKey,
        booksString,
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error saving books to SharedPreferences: $e',
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  addBook(
    Book
    newBook,
  ) async {
    try {
      final books =
          await getBooks();
      if (books.any(
        (
          book,
        ) =>
            book.id ==
            newBook.id,
      )) {
        throw Exception(AppConstants.messages['error']);
      }
      books.add(
        newBook,
      );
      await _saveBooks(
        books,
      );
    } catch (
      e
    ) {
      debugPrint(
        "Error in addBook: $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  updateBook(
    Book
    updatedBook,
  ) async {
    try {
      final books =
          await getBooks();
      final index = books.indexWhere(
        (
          book,
        ) =>
            book.id ==
            updatedBook.id,
      );
      if (index ==
          -1) {
        throw Exception(AppConstants.messages['error']);
      }
      
      final oldBook =
          books[index];
      if (oldBook.coverImagePath !=
              null &&
          oldBook.coverImagePath !=
              updatedBook.coverImagePath) {
        try {
          await deleteCoverImage(
            oldBook.coverImagePath!,
          );
        } catch (e) {
          debugPrint(
            'Warning: Failed to delete old cover image: $e',
          );
        }
      }
      
      books[index] =
          updatedBook;
      await _saveBooks(
        books,
      );
    } catch (
      e
    ) {
      debugPrint(
        "Error in updateBook: $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  deleteBook(
    String
    bookId,
  ) async {
    try {
      final books =
          await getBooks();
      final book = books.firstWhere(
        (
          book,
        ) =>
            book.id ==
            bookId,
        orElse: () => throw Exception(AppConstants.messages['error']),
      );
      
      if (book.coverImagePath !=
          null) {
        try {
          await deleteCoverImage(
            book.coverImagePath!,
          );
        } catch (e) {
          debugPrint(
            'Warning: Failed to delete cover image: $e',
          );
        }
      }
      
      books.removeWhere(
        (
          book,
        ) =>
            book.id ==
            bookId,
      );
      await _saveBooks(
        books,
      );
    } catch (
      e
    ) {
      debugPrint(
        "Error in deleteBook: $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  // --- Challenge Functions ---

  Future<
    List<
      Challenge
    >
  >
  getChallenges() async {
    try {
      final prefs =
          await _getPrefs();
      final String?
      challengesString = prefs.getString(
        _challengesKey,
      );
      if (challengesString !=
              null &&
          challengesString.isNotEmpty) {
        final List<
          dynamic
        >
        challengeList = json.decode(
          challengesString,
        );
        return challengeList
            .map(
              (
                json,
              ) => Challenge.fromMap(
                json
                    as Map<
                      String,
                      dynamic
                    >,
              ),
            )
            .toList();
      }
      return [];
    } catch (
      e
    ) {
      debugPrint(
        'Error reading challenges from SharedPreferences: $e',
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  _saveChallenges(
    List<
      Challenge
    >
    challenges,
  ) async {
    try {
      final prefs =
          await _getPrefs();
      final String
      challengesString = json.encode(
        challenges
            .map(
              (
                challenge,
              ) =>
                  challenge.toMap(),
            )
            .toList(),
      );
      await prefs.setString(
        _challengesKey,
        challengesString,
      );
    } catch (
      e
    ) {
      debugPrint(
        'Error saving challenges to SharedPreferences: $e',
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  addChallenge(
    Challenge
    newChallenge,
  ) async {
    try {
      final challenges =
          await getChallenges();
      if (challenges.any(
        (
          c,
        ) =>
            c.id ==
            newChallenge.id,
      )) {
        throw Exception(AppConstants.messages['error']);
      }
      challenges.add(
        newChallenge,
      );
      await _saveChallenges(
        challenges,
      );
    } catch (
      e
    ) {
      debugPrint(
        "Error in addChallenge: $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  updateChallenge(
    Challenge
    updatedChallenge,
  ) async {
    try {
      final challenges =
          await getChallenges();
      final index = challenges.indexWhere(
        (
          challenge,
        ) =>
            challenge.id ==
            updatedChallenge.id,
      );
      if (index ==
          -1) {
        throw Exception(AppConstants.messages['error']);
      }
      
      challenges[index] =
          updatedChallenge;
      await _saveChallenges(
        challenges,
      );
    } catch (
      e
    ) {
      debugPrint(
        "Error in updateChallenge: $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  deleteChallenge(
    String
    challengeId,
  ) async {
    try {
      final challenges =
          await getChallenges();
      final initialLength =
          challenges.length;
      challenges.removeWhere(
        (
          challenge,
        ) =>
            challenge.id ==
            challengeId,
      );
      if (challenges.length <
          initialLength) {
        // Only save if something was removed
        await _saveChallenges(
          challenges,
        );
      } else {
        debugPrint(
          'Challenge with id $challengeId not found for deletion.',
        );
      }
    } catch (
      e
    ) {
      debugPrint(
        "Error in deleteChallenge: $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }

  // --- Image Handling ---

  // Helper to get the directory for storing cover images
  Future<
    Directory
  >
  _getCoverImageDirectory() async {
    final appDocDir =
        await getApplicationDocumentsDirectory();
    final imageDir = Directory(
      p.join(
        appDocDir.path,
        _coverImageDir,
      ),
    );
    if (!await imageDir
        .exists()) {
      await imageDir.create(
        recursive:
            true,
      );
    }
    return imageDir;
  }

  Future<
    String?
  >
  saveCoverImage(
    File
    imageFile,
    String
    bookId,
  ) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final coverDir = Directory(p.join(appDir.path, _coverImageDir));
      
      if (!await coverDir.exists()) {
        await coverDir.create(recursive: true);
      }
      
      final fileName = 'cover_$bookId${p.extension(imageFile.path)}';
      final savedFile = await imageFile.copy(p.join(coverDir.path, fileName));
      
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving cover image: $e');
      throw Exception(AppConstants.messages['error']);
    }
  }

  Future<
    void
  >
  deleteCoverImage(
    String
    imagePath,
  ) async {
    try {
      final file = File(
        imagePath,
      );
      if (await file.exists()) {
        await file.delete();
        debugPrint(
          "Deleted cover image: $imagePath",
        );
      } else {
        // This might not be an error, the path could be invalid or already deleted
        debugPrint(
          "Cover image not found for deletion: $imagePath",
        );
      }
    } catch (
      e
    ) {
      // Log error but don't necessarily throw, as book deletion should proceed
      debugPrint(
        "Error deleting cover image '$imagePath': $e",
      );
      throw Exception(AppConstants.messages['error']);
    }
  }
}
