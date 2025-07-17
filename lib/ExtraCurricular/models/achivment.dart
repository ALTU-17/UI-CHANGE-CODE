// lib/models/achievement.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class AchievementType {
  final int id;
  final String value;
  final String label;

  AchievementType({
    required this.id,
    required this.value,
    required this.label,
  });

  factory AchievementType.fromJson(Map<String, dynamic> json) {
    return AchievementType(
      id: json['id'],
      value: json['value'],
      label: json['label'],
    );
  }
}

class AchievementLevel {
  final int id;
  final String value;
  final String label;

  AchievementLevel({
    required this.id,
    required this.value,
    required this.label,
  });

  factory AchievementLevel.fromJson(Map<String, dynamic> json) {
    return AchievementLevel(
      id: json['id'],
      value: json['value'],
      label: json['label'],
    );
  }
}

class Student {
  final int studentId;
  final String firstName;
  final String midName;
  final String lastName;
  final String className;
  final String sectionName;
  final String regNo;
  final String imageName;

  Student({
    required this.studentId,
    required this.firstName,
    required this.midName,
    required this.lastName,
    required this.className,
    required this.sectionName,
    required this.regNo,
    required this.imageName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'],
      firstName: json['first_name'] ?? '',
      midName: json['mid_name'] ?? '',
      lastName: json['last_name'] ?? '',
      className: json['class_name'] ?? '',
      sectionName: json['section_name'] ?? '',
      regNo: json['reg_no'] ?? '',
      imageName: json['image_name'] ?? '',
    );
  }

  String get fullName => [firstName, midName, lastName]
      .where((e) => e.isNotEmpty)
      .join(' ');

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }
}

class Achievement {
  final int id;
  final String regNo;
  final int studentId;
  final String academicYear;
  final String title;
  final String description;
  final DateTime achievementDate;
  final String type;
  final String level;
  final String organizationName;
  final String eventName;
  final String score;
  final int? position;
  final int isVerified;
  final int isExternal;
  final DateTime createdAt;
  List<AchievementFile> files;

  Achievement({
    required this.id,
    required this.regNo,
    required this.studentId,
    required this.academicYear,
    required this.title,
    required this.description,
    required this.achievementDate,
    required this.type,
    required this.level,
    required this.organizationName,
    required this.eventName,
    required this.score,
    this.position,
    required this.isVerified,
    required this.isExternal,
    required this.createdAt,
    this.files = const [],
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] ?? 0,
      regNo: json['reg_no'] ?? '',
      studentId: json['student_id'] ?? 0,                          // ✅ was crashing here
      academicYear: json['academic_year'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      achievementDate: json['achievement_date'] != null            // ✅ was crashing here
          ? DateTime.parse(json['achievement_date'])
          : DateTime.now(),
      type: json['type'] ?? '',
      level: json['level'] ?? '',
      organizationName: json['organization_name'] ?? '',
      eventName: json['event_name'] ?? '',
      score: json['score'] ?? '',
      position: json['position'],
      isVerified: json['is_verified'] ?? 0,
      isExternal: json['is_external'] ?? 0,
      createdAt: json['created_at'] != null                        // ✅ was crashing here
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get positionText {
    switch (position) {
      case 1:
        return '🥇 1st Position';
      case 2:
        return '🥈 2nd Position';
      case 3:
        return '🥉 3rd Position';
      default:
        return 'Participate';
    }
  }

  Color get positionColor {
    switch (position) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Colors.blue;
    }
  }

  bool get isVerifiedBool => isVerified == 1;
  bool get isExternalBool => isExternal == 1;
}

class AchievementFile {
  final int id;
  final int achievementId;
  final String fileUrl;
  final String fileType;
  final DateTime uploadedAt;

  AchievementFile({
    required this.id,
    required this.achievementId,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  factory AchievementFile.fromJson(Map<String, dynamic> json) {
    return AchievementFile(
      id: json['id'],
      achievementId: json['achievement_id'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}