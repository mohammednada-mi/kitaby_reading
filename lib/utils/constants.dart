import 'package:flutter/material.dart';
import 'package:kitaby_flutter/models/book.dart';
import 'package:kitaby_flutter/models/challenge.dart';

class AppConstants {
  // Spacing
  static const double
  spacingXSmall =
      4.0;
  static const double
  spacingSmall =
      8.0;
  static const double
  spacingMedium =
      16.0;
  static const double
  spacingLarge =
      24.0;
  static const double
  spacingXLarge =
      32.0;

  // Padding
  static const double
  paddingSmall =
      8.0;
  static const double
  paddingMedium =
      16.0;
  static const double
  paddingLarge =
      24.0;

  // Border Radius (matching var(--radius): 0.5rem; assuming base font size 16px)
  static const double
  borderRadius =
      8.0; // 0.5 * 16
  static const double
  borderRadiusSmall =
      4.0; // calc(var(--radius) - 4px)
  static const double
  borderRadiusLarge =
      12.0; // Example

  // Image Sizes
  static const double coverImageWidth = 120.0;
  static const double coverImageHeight = 180.0;
  static const double coverImageAspectRatio = 2/3;
  static const int maxImageSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;

  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFF00BCD4);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color textColor = Color(0xFF212121);
  static const Color textColorLight = Color(0xFF757575);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;

  // Category Display Names (Arabic)
  static const Map<
    BookCategory,
    String
  >
  categoryDisplayNames = {
    BookCategory.reading:
        'أقرأ الآن',
    BookCategory.read:
        'قرأت',
    BookCategory.wantToRead:
        'أنوي القراءة',
    BookCategory.completeLater:
        'أكملها لاحقًا',
  };

  // Category Icons
  static const Map<
    BookCategory,
    IconData
  >
  categoryIcons = {
    BookCategory.reading:
        Icons.book_outlined, // Or AutoStoriesOutlined
    BookCategory.read:
        Icons.check_circle_outline,
    BookCategory.wantToRead:
        Icons.playlist_add_check_outlined,
    BookCategory.completeLater:
        Icons.bookmark_border_outlined, // Or WatchLaterOutlined
  };

  // Challenge Type Display Names (Arabic)
  static const Map<
    ChallengeType,
    String
  >
  challengeTypeDisplayNames = {
    ChallengeType.books:
        'كتب',
    ChallengeType.pages:
        'صفحات',
  };

  // Challenge Duration Display Names (Arabic)
  static const Map<
    ChallengeDuration,
    String
  >
  challengeDurationDisplayNames = {
    ChallengeDuration.day:
        'يوم واحد',
    ChallengeDuration.week:
        'أسبوع',
    ChallengeDuration.month:
        'شهر',
    ChallengeDuration.year:
        'سنة',
  };

  // General Messages
  static const Map<String, String> messages = {
    'loading': 'جاري التحميل...',
    'error': 'حدث خطأ',
    'success': 'تم بنجاح',
    'confirm': 'تأكيد',
    'cancel': 'إلغاء',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'required': 'مطلوب',
    'optional': 'اختياري',
    'invalidInput': 'إدخال غير صالح',
    'noData': 'لا توجد بيانات',
    'retry': 'إعادة المحاولة',
    'networkError': 'خطأ في الاتصال',
    'permissionDenied': 'تم رفض الإذن',
    'fileTooLarge': 'حجم الملف كبير جداً',
    'invalidImage': 'صورة غير صالحة',
  };

  // Validation Messages
  static const Map<String, String> validationMessages = {
    'required': 'هذا الحقل مطلوب',
    'invalidNumber': 'الرجاء إدخال رقم صحيح',
    'positiveNumber': 'الرجاء إدخال رقم موجب',
    'invalidDate': 'تاريخ غير صالح',
    'invalidEmail': 'بريد إلكتروني غير صالح',
    'invalidPhone': 'رقم هاتف غير صالح',
    'invalidUrl': 'رابط غير صالح',
    'minLength': 'يجب أن يكون الطول على الأقل {0}',
    'maxLength': 'يجب أن لا يتجاوز الطول {0}',
    'minValue': 'يجب أن تكون القيمة على الأقل {0}',
    'maxValue': 'يجب أن لا تتجاوز القيمة {0}',
  };

  // Default placeholder image path or logic can be defined here if needed
  // static const String defaultBookCoverPlaceholder = 'assets/images/default_cover.png';
}
