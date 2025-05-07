import 'dart:convert';
import 'package:flutter/foundation.dart'
    show
        immutable;
import 'package:flutter/foundation.dart'
    show
        debugPrint;

enum ChallengeType {
  books,
  pages,
}

enum ChallengeDuration {
  day,
  week,
  month,
  year,
}

String
challengeTypeToString(
  ChallengeType
  type,
) =>
    type.name;
ChallengeType
challengeTypeFromString(
  String
  typeString,
) {
  try {
    return ChallengeType.values.firstWhere(
      (e) => e.name == typeString,
      orElse: () => throw Exception('نوع التحدي غير صالح: $typeString'),
    );
  } catch (e) {
    debugPrint('خطأ في تحويل نوع التحدي: $e');
    return ChallengeType.books; // القيمة الافتراضية
  }
}

String
challengeDurationToString(
  ChallengeDuration
  duration,
) =>
    duration
        .name;
ChallengeDuration
challengeDurationFromString(
  String
  durationString,
) {
  try {
    return ChallengeDuration.values.firstWhere(
      (e) => e.name == durationString,
      orElse: () => throw Exception('مدة التحدي غير صالحة: $durationString'),
    );
  } catch (e) {
    debugPrint('خطأ في تحويل مدة التحدي: $e');
    return ChallengeDuration.week; // القيمة الافتراضية
  }
}

@immutable
class Challenge {
  final String
  id;
  final ChallengeType
  type;
  final int
  goal;
  final ChallengeDuration
  duration;
  final DateTime
  startDate;
  final DateTime
  endDate;
  final int
  currentProgress;

  const Challenge({
    required this.id,
    required this.type,
    required this.goal,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.currentProgress,
  });

  factory Challenge.fromMap(
    Map<
      String,
      dynamic
    >
    map,
  ) {
    try {
      // التحقق من وجود الحقول المطلوبة
      if (!map.containsKey('id') || map['id'] == null) {
        throw Exception('معرف التحدي مطلوب');
      }
      if (!map.containsKey('type') || map['type'] == null) {
        throw Exception('نوع التحدي مطلوب');
      }
      if (!map.containsKey('goal') || map['goal'] == null) {
        throw Exception('هدف التحدي مطلوب');
      }
      if (!map.containsKey('duration') || map['duration'] == null) {
        throw Exception('مدة التحدي مطلوبة');
      }
      if (!map.containsKey('startDate') || map['startDate'] == null) {
        throw Exception('تاريخ البداية مطلوب');
      }
      if (!map.containsKey('endDate') || map['endDate'] == null) {
        throw Exception('تاريخ النهاية مطلوب');
      }
      if (!map.containsKey('currentProgress') || map['currentProgress'] == null) {
        throw Exception('التقدم الحالي مطلوب');
      }

      // التحقق من صحة البيانات
      final goal = map['goal'] as int;
      if (goal <= 0) {
        throw Exception('الهدف يجب أن يكون أكبر من صفر');
      }

      final currentProgress = map['currentProgress'] as int;
      if (currentProgress < 0) {
        throw Exception('التقدم الحالي لا يمكن أن يكون سالباً');
      }

      final startDate = DateTime.parse(map['startDate'] as String);
      final endDate = DateTime.parse(map['endDate'] as String);
      
      if (endDate.isBefore(startDate)) {
        throw Exception('تاريخ النهاية يجب أن يكون بعد تاريخ البداية');
      }

      return Challenge(
        id: map['id'] as String,
        type: challengeTypeFromString(map['type'] as String),
        goal: goal,
        duration: challengeDurationFromString(map['duration'] as String),
        startDate: startDate,
        endDate: endDate,
        currentProgress: currentProgress,
      );
    } catch (e) {
      debugPrint('خطأ في تحويل البيانات إلى تحدي: $e');
      rethrow;
    }
  }

  Map<
    String,
    dynamic
  >
  toMap() {
    return {
      'id':
          id,
      'type': challengeTypeToString(
        type,
      ),
      'goal':
          goal,
      'duration': challengeDurationToString(
        duration,
      ),
      // Store dates as ISO 8601 strings for reliable serialization
      'startDate':
          startDate.toIso8601String(),
      'endDate':
          endDate.toIso8601String(),
      'currentProgress':
          currentProgress,
    };
  }

  String
  toJson() =>
      json.encode(
        toMap(),
      );

  factory Challenge.fromJson(
    String
    source,
  ) => Challenge.fromMap(
    json.decode(
          source,
        )
        as Map<
          String,
          dynamic
        >,
  );

  Challenge
  copyWith({
    String?
    id,
    ChallengeType?
    type,
    int?
    goal,
    ChallengeDuration?
    duration,
    DateTime?
    startDate,
    DateTime?
    endDate,
    int?
    currentProgress,
  }) {
    return Challenge(
      id:
          id ??
          this.id,
      type:
          type ??
          this.type,
      goal:
          goal ??
          this.goal,
      duration:
          duration ??
          this.duration,
      startDate:
          startDate ??
          this.startDate,
      endDate:
          endDate ??
          this.endDate,
      currentProgress:
          currentProgress ??
          this.currentProgress,
    );
  }

  // Helper method to calculate progress percentage
  double
  get progressPercentage {
    if (goal <=
        0) {
      return 0.0;
    }
    double
    progress =
        (currentProgress /
            goal) *
        100;
    return progress.clamp(
      0.0,
      100.0,
    ); // Ensure value is between 0 and 100
  }

  // Helper to check if challenge is active
  bool
  get isActive =>
      DateTime.now().isBefore(
        endDate,
      );

  @override
  String
  toString() {
    return 'Challenge(id: $id, type: $type, goal: $goal, duration: $duration, startDate: $startDate, endDate: $endDate, currentProgress: $currentProgress)';
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
            is Challenge &&
        other.id ==
            id &&
        other.type ==
            type &&
        other.goal ==
            goal &&
        other.duration ==
            duration &&
        other.startDate ==
            startDate &&
        other.endDate ==
            endDate &&
        other.currentProgress ==
            currentProgress;
  }

  @override
  int
  get hashCode {
    return id.hashCode ^
        type.hashCode ^
        goal.hashCode ^
        duration.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        currentProgress.hashCode;
  }
}
