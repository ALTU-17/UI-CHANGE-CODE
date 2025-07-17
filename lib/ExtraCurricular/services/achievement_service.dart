// lib/services/achievement_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../models/achivment.dart';

class AchievementService {
  final String baseUrl;
  final String token;

  AchievementService({required this.baseUrl, required this.token});

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  // Get all children for logged-in parent
  Future<List<Student>> getChildren(int studentId) async {
    try {
      if (studentId <= 0) {
        return [];
      }

      final response = await http.get(
        Uri.parse(
          '${baseUrl}student/achievements/childrens?student_id=$studentId',
        ),
        headers: _headers,
      );

      print('Children Status: ${response.statusCode}');
      print('Children Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData == null) {
          return [];
        }

        final List<dynamic> data =
            jsonData['data'] as List<dynamic>? ?? [];

        return data
            .where((e) => e != null)
            .map((e) => Student.fromJson(e))
            .toList();
      }

      return [];
    } catch (e, stack) {
      print('getChildren Error: $e');
      print(stack);
      return [];
    }
  }

  // Get all achievements for a student
  Future<List<Achievement>> getAchievements(int studentId, String academicYear) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}student/achievements?student_id=$studentId&academic_year=$academicYear'),
        headers: _headers,
      );
      print('achievements Response body: ${baseUrl}student/achievements/childrens ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((e) => Achievement.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load achievements');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get achievement types
  Future<List<AchievementType>> getAchievementTypes() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}master/dropdowns/code/ACHIEVEMENT_TYPE/options'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((e) => AchievementType.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load achievement types');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get achievement levels
  Future<List<AchievementLevel>> getAchievementLevels() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}master/dropdowns/code/ACHIEVEMENT_LEVEL/options'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'];
        return data.map((e) => AchievementLevel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load achievement levels');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Create achievement
  Future<Achievement> createAchievement(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}student/achievements'),
        headers: _headers,
        body: json.encode(data),
      );

      print('achievements Save Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Achievement.fromJson(jsonData['data'] ?? jsonData);
      } else {
        throw Exception('Failed to create achievement: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Upload file for achievement
  Future<String> uploadAchievementFile(int achievementId, File file) async {
    try {
      print('Uploading file for achievement ID: $achievementId');
      print('File path: ${file.path}');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}student/achievements/$achievementId/files'),
      );

      // Add headers (including token)
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        // Don't add Content-Type here, it will be set automatically for multipart
      });

      // Add the file
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      // Send request
      var response = await request.send();
      print('File upload response status: ${response.statusCode}');

      // Read response
      var responseData = await response.stream.bytesToString();
      print('File upload response body: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonData = json.decode(responseData);

        // Extract file URL from response
        String fileUrl;
        if (jsonData.containsKey('data')) {
          fileUrl = jsonData['data']['file_url'] ?? jsonData['data']['url'] ?? '';
        } else {
          fileUrl = jsonData['file_url'] ?? jsonData['url'] ?? '';
        }

        print('File uploaded successfully: $fileUrl');
        return fileUrl;
      } else {
        throw Exception('Failed to upload file. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
      throw Exception('Error uploading file: $e');
    }
  }

  Future<void> deleteAchievement(int achievementId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}student/achievements/$achievementId'),
        headers: _headers,
      );

      print('Delete achievement response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return; // {"message": "Deleted"} — nothing to parse
      } else {
        throw Exception('Failed to delete achievement: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete achievement file by file ID
  Future<void> deleteAchievementFile(int fileId) async {
    try {
      final response = await http.delete(
        Uri.parse('${baseUrl}student/achievements/files/$fileId'),
        headers: _headers,
      );

      print('Delete file response status: ${response.statusCode}');
      print('Delete file response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['message'] == 'File deleted successfully') {
          print('File deleted successfully');
        } else {
          throw Exception('Failed to delete file');
        }
      } else {
        throw Exception('Failed to delete file: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting file: $e');
      throw Exception('Error deleting file: $e');
    }
  }

  // Update achievement
  Future<void> updateAchievement(Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl}student/achievements/${data['id']}'), // Add ID to URL
        headers: _headers,
        body: json.encode(data),
      );

      print('achievements update Response body: ${response.body}');
      print('Update status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Check if response is just {"message": "updated"}
        if (jsonData.containsKey('message') && jsonData['message'] == 'updated') {
          print('Achievement updated successfully');
          return; // Success, no need to parse achievement data
        }
        // else {
        //   // If response contains achievement data, return it
        //   return Achievement.fromJson(jsonData['data'] ?? jsonData);
        // }
      } else {
        throw Exception('Failed to update achievement: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateAchievement: $e');
      throw Exception('Error: $e');
    }
  }

  // Get achievement details
  Future<Achievement> getAchievementDetails(int achievementId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}student/achievements/$achievementId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return Achievement.fromJson(jsonData);
      } else {
        throw Exception('Failed to load achievement details');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }



  // Get achievement files
  Future<List<AchievementFile>> getAchievementFiles(int achievementId) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl}student/achievements/$achievementId/files'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => AchievementFile.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load files');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}