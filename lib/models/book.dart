import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/foundation.dart'
    show
        immutable; // For immutable annotation
import 'package:flutter/foundation.dart'
    show
        debugPrint; // For debugPrint

// Enum for book categories, matching the TypeScript version
enum BookCategory {
  read,
  reading,
  wantToRead, // Use camelCase for enum values in Dart
  completeLater,
}

// Helper function to convert enum to string for storage/display
String
bookCategoryToString(
  BookCategory
  category,
) {
  switch (category) {
    case BookCategory
        .read:
      return 'read';
    case BookCategory
        .reading:
      return 'reading';
    case BookCategory
        .wantToRead:
      return 'want-to-read';
    case BookCategory
        .completeLater:
      return 'complete-later';
  }
}

// Helper function to convert string back to enum
BookCategory
bookCategoryFromString(
  String
  categoryString,
) {
  try {
    switch (categoryString) {
      case 'read':
        return BookCategory.read;
      case 'reading':
        return BookCategory.reading;
      case 'want-to-read':
        return BookCategory.wantToRead;
      case 'complete-later':
        return BookCategory.completeLater;
      default:
        throw Exception('تصنيف غير صالح: $categoryString');
    }
  } catch (e) {
    debugPrint('خطأ في تحويل التصنيف: $e');
    return BookCategory.reading; // القيمة الافتراضية
  }
}

@immutable
class Book {
  final String
  id;
  final String
  title;
  final String
  author;
  final int
  totalPages;
  final String?
  description;
  final String?
  coverImagePath; // Store local file path instead of URL/Data URI
  final BookCategory
  category;
  final int
  currentPage;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.totalPages,
    this.description,
    this.coverImagePath,
    required this.category,
    required this.currentPage,
  });

  // Factory constructor to create a Book from a map (e.g., from JSON)
  factory Book.fromMap(
    Map<
      String,
      dynamic
    >
    map,
  ) {
    try {
      // التحقق من وجود الحقول المطلوبة
      if (!map.containsKey('id') || map['id'] == null) {
        throw Exception('معرف الكتاب مطلوب');
      }
      if (!map.containsKey('title') || map['title'] == null) {
        throw Exception('عنوان الكتاب مطلوب');
      }
      if (!map.containsKey('author') || map['author'] == null) {
        throw Exception('اسم المؤلف مطلوب');
      }
      if (!map.containsKey('totalPages') || map['totalPages'] == null) {
        throw Exception('عدد الصفحات مطلوب');
      }
      if (!map.containsKey('category') || map['category'] == null) {
        throw Exception('تصنيف الكتاب مطلوب');
      }
      if (!map.containsKey('currentPage') || map['currentPage'] == null) {
        throw Exception('الصفحة الحالية مطلوبة');
      }

      // التحقق من صحة البيانات
      final totalPages = map['totalPages'] as int;
      if (totalPages <= 0) {
        throw Exception('عدد الصفحات يجب أن يكون أكبر من صفر');
      }

      final currentPage = map['currentPage'] as int;
      if (currentPage < 0 || currentPage > totalPages) {
        throw Exception('الصفحة الحالية غير صالحة');
      }

      return Book(
        id:
            map['id']
                as String,
        title:
            map['title']
                as String,
        author:
            map['author']
                as String,
        totalPages:
            totalPages,
        description:
            map['description']
                as String?,
        coverImagePath:
            map['coverImagePath']
                as String?,
        category: bookCategoryFromString(
          map['category']
              as String,
        ),
        currentPage:
            currentPage,
      );
    } catch (e) {
      debugPrint('خطأ في تحويل البيانات إلى كتاب: $e');
      rethrow;
    }
  }

  // Method to convert a Book instance to a map (e.g., for JSON)
  Map<
    String,
    dynamic
  >
  toMap() {
    return {
      'id':
          id,
      'title':
          title,
      'author':
          author,
      'totalPages':
          totalPages,
      'description':
          description,
      'coverImagePath':
          coverImagePath, // Corrected key
      'category': bookCategoryToString(
        category,
      ),
      'currentPage':
          currentPage,
    };
  }

  // Helper methods for JSON serialization/deserialization
  String
  toJson() =>
      json.encode(
        toMap(),
      );

  factory Book.fromJson(
    String
    source,
  ) => Book.fromMap(
    json.decode(
          source,
        )
        as Map<
          String,
          dynamic
        >,
  );

  // CopyWith method for creating modified instances (useful with immutable classes)
  Book
  copyWith({
    String?
    id,
    String?
    title,
    String?
    author,
    int?
    totalPages,
    String?
    description,
    String?
    coverImagePath,
    BookCategory?
    category,
    int?
    currentPage,
  }) {
    return Book(
      id:
          id ??
          this.id,
      title:
          title ??
          this.title,
      author:
          author ??
          this.author,
      totalPages:
          totalPages ??
          this.totalPages,
      description:
          description ??
          this.description,
      coverImagePath:
          coverImagePath ??
          this.coverImagePath,
      category:
          category ??
          this.category,
      currentPage:
          currentPage ??
          this.currentPage,
    );
  }

  @override
  String
  toString() {
    return 'Book(id: $id, title: $title, author: $author, totalPages: $totalPages, description: $description, coverImagePath: $coverImagePath, category: $category, currentPage: $currentPage)';
  }

  @override
  bool
  operator ==(
    Object
    other,
  ) {
    if (identical(
      this,
      other,
    ))
      return true;

    return other
            is Book &&
        other.id ==
            id &&
        other.title ==
            title &&
        other.author ==
            author &&
        other.totalPages ==
            totalPages &&
        other.description ==
            description &&
        other.coverImagePath ==
            coverImagePath &&
        other.category ==
            category &&
        other.currentPage ==
            currentPage;
  }

  @override
  int
  get hashCode {
    return id.hashCode ^
        title.hashCode ^
        author.hashCode ^
        totalPages.hashCode ^
        description.hashCode ^
        coverImagePath.hashCode ^
        category.hashCode ^
        currentPage.hashCode;
  }
}
