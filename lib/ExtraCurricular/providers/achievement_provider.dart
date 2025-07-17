// lib/providers/achievement_provider.dart
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achivment.dart';
import '../services/achievement_service.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) {
  // Get token from your auth provider
  // final token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3Ntcy5ldm9sdnUuaW4vYXJub2xkc190ZXN0L3B1YmxpYy9hcGkvbG9naW4iLCJpYXQiOjE3Nzc5ODI0NDUsIm5iZiI6MTc3Nzk4MjQ0NSwianRpIjoiZDlrZ1g2VThvUjhhaVM3YSIsInN1YiI6ImRzb3V6YS5mcmFuY2lzQGdtYWlsLmNvbSIsInBydiI6ImE0MjNiNmQ4M2NiNzExMDI3ZjFlOTkwYjIwNzhmNmE2ODQ0OWNhZTkiLCJyb2xlX2lkIjoiUCIsInJlZ19pZCI6MTIwMywiYWNhZGVtaWNfeWVhciI6IjIwMjYtMjAyNyIsInNjaG9vbF9uYW1lIjoiRXZvbHZ1IFNtYXJ0IFNjaG9vbCIsInNldHRpbmdzIjp7InNjaG9vbF9zZXR0aW5nc19pZCI6MSwic2Nob29sX2lkIjoxLCJpbnN0aXR1dGVfbmFtZSI6IkV2b2x2dSBTY2hvb2wiLCJkZWZhdWx0X3B3ZCI6ImFybm9sZHMiLCJzaG9ydF9uYW1lIjoiU0FDUyIsInN0YWZmdXNlcl9zdWZmaXgiOiJhcm5vbGRzIiwic3VwcG9ydF9lbWFpbF9pZCI6InN1cHBvcnRzYWNzQGFjZXZlbnR1cmEuaW4iLCJzY2hvb2xfbG9nbyI6ImxvZ28uanBnIiwic2Nob29sX2ltYWdlIjoic2NoLmpwZyIsIndlYnNpdGVfdXJsIjoiaHR0cHM6Ly9zYWNzLmV2b2x2dS5pbiIsInNjaG9vbF9lbWFpbF9pZCI6InNjaG9vbEBhcm5vbGRjZW50cmFsc2Nob29sLm9yZyIsInVwbG9hZGZpbGVzX3VybCI6bnVsbCwicmVkaW5ndG9uX2FwaV9rZXkiOiJleUpoYkdjaU9pSklVekkxTmlJc0luUjVjQ0k2SWtwWFZDSjkuZXlKaGMzTnBjM1JoYm5SSlpDSTZJalk0TVdJd01HUTNOR0ZrWWpJMU1HSmxaRE00TW1RM1pDSXNJbU5zYVdWdWRFbGtJam9pTmpneFlqQXdaRFkwWVdSaU1qVXdZbVZrTXpneVpEYzJJaXdpYVdGMElqb3hOelEyTnprME1qVTVmUS45N1U2Q2tpOU1ZWjZwbHoyZ09abjhXWG40SG10aU9XcjZHR2JsamN4bkc0Iiwid2hhdHNhcHBfaW50ZWdyYXRpb24iOiJZIiwic21zX2ludGVncmF0aW9uIjoiTiIsImlzX2FjdGl2ZSI6IlkifSwic2hvcnRfbmFtZSI6IlNBQ1MiLCJzZXR0aW5nc19uZXciOnsic2V0dGluZ19pZCI6MTEsImluc3RpdHV0ZV9uYW1lIjoiRXZvbHZ1IFNtYXJ0IFNjaG9vbCIsImFkZHJlc3MiOiJBZGFyc2ggTmFnYXIsIFZhZGdhb24gU2hlcmksIFB1bmUsIE1haGFyYXNodHJhIDQxMTAxNCIsInBob25lX251bWJlciI6IjAyMCAyNzAzIDcwOCIsInBhZ2VfdGl0bGUiOiJFdm9sdnUgU21hcnQgU2Nob29sIiwicGFnZV9tZXRhX3RhZyI6IjAiLCJkZWZhdWx0X3B3ZCI6ImFybm9sZHMiLCJzaG9ydF9uYW1lIjoiU0FDUyIsInN0YWZmdXNlcl9zdWZmaXgiOiJhcm5vbGRzIiwic3VwcG9ydF9lbWFpbF9pZCI6InN1cHBvcnRzYWNzQGFjZXZlbnR1cmEuaW4iLCJzY2hvb2xfbG9nbyI6ImxvZ28uanBnIiwid2Vic2l0ZV91cmwiOiJodHRwczovL3NhY3N0ZXN0LmV2b2x2dS5pbiIsImFjYWRlbWljX3lyX2Zyb20iOiIyMDI2LTA0LTAxIiwiYWNhZGVtaWNfeXJfdG8iOiIyMDI3LTAzLTMxIiwiYWNhZGVtaWNfeXIiOiIyMDI2LTIwMjciLCJhY3RpdmUiOiJZIn19.WRI5rJS4LeYzud7Le2a1feS4ZdOd01hoYi3qedbmXp0'; // Get from your auth service
  final baseUrl = 'https://sms.evolvu.in/arnolds_test/public'; // Get from your config
  return AchievementService(baseUrl: laravel_project_url, token: token);
});

final childrenProvider =
FutureProvider.family<List<Student>, int>((ref, studentId) async {
  final service = ref.watch(achievementServiceProvider);

  if (studentId <= 0) {
    return [];
  }

  return service.getChildren(studentId);
});

final achievementTypesProvider = FutureProvider<List<AchievementType>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementTypes();
});

final achievementLevelsProvider = FutureProvider<List<AchievementLevel>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementLevels();
});

final studentAchievementsProvider = FutureProvider.family<List<Achievement>, int>((ref, studentId) async {
  final service = ref.watch(achievementServiceProvider);
  // You can get academic year from your app state
  final academicYear = academic_yrShow;
  return service.getAchievements(studentId, academicYear);
});

final achievementDetailsProvider = FutureProvider.family<Achievement, int>((ref, achievementId) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementDetails(achievementId);
});

final achievementFilesProvider = FutureProvider.family<List<AchievementFile>, int>((ref, achievementId) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementFiles(achievementId);
});