// lib/screens/achievements/achievement_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/achivment.dart';
import '../providers/achievement_provider.dart';
import 'achievement_detail_screen.dart';
import 'create_achievement_screen.dart';

class AchievementListScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String academicYear;

  /// Optional: pass a pre-selected student to skip the selector step.
  final Student? initialStudent;

  const AchievementListScreen({
    super.key,
    required this.studentId,
    required this.academicYear,
    this.initialStudent, // <-- new optional param
  });

  @override
  ConsumerState<AchievementListScreen> createState() =>
      _AchievementListScreenState();
}

class _AchievementListScreenState
    extends ConsumerState<AchievementListScreen> {
  Student? selectedStudent;

  // ── Gradient colours used throughout ──────────────────────────────────────
  static const _gradientColors = [Colors.pink, Colors.blue];
  static const _gradient = LinearGradient(
    colors: _gradientColors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  void initState() {
    super.initState();
    // Pre-select the student if one was passed in.
    selectedStudent = widget.initialStudent;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _openCreateScreen() {
    if (selectedStudent == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAchievementScreen(student: selectedStudent!),
      ),
    ).then(
          (_) => ref.refresh(
        studentAchievementsProvider(selectedStudent!.studentId),
      ),
    );
  }

  void _refreshAchievements(Student student) {
    ref.refresh(studentAchievementsProvider(student.studentId));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final childrenAsync = ref.watch(
      childrenProvider(
        int.tryParse(widget.studentId) ?? 0,
      ),
    );
    return Scaffold(
      // Full-screen gradient background
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              SizedBox(height: 10.h),

              _buildStudentSelector(childrenAsync),
              SizedBox(height: 10.h),

              _buildAchievementsList(),
            ],
          ),
        ),
      ),

      // FAB — bottom-right create button
      floatingActionButton: selectedStudent != null
          ? FloatingActionButton(
        onPressed: _openCreateScreen,
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      )
          : null,
    );
  }

  // ── Custom AppBar (transparent over gradient) ─────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Achievements & Activities',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Student Selector card ─────────────────────────────────────────────────

  Widget _buildStudentSelector(AsyncValue<List<Student>> childrenAsync) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: childrenAsync.when(
        // Show spinner while loading children list
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (err, _) => Text(
          'Error: $err',
          style: const TextStyle(color: Colors.white),
        ),
        data: (students) {
          if (students.isEmpty) {
            return const Text(
              'No students found',
              style: TextStyle(color: Colors.white),
            );
          }

          // Auto-select first student if none provided and none chosen yet
          selectedStudent ??= students.first;

          return DropdownButtonFormField<Student>(
            value: selectedStudent,
            dropdownColor: const Color(0xFF68646C),
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'Select Student',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: Colors.white),
              ),
              prefixIcon: const Icon(Icons.school, color: Colors.white70),
            ),
            items: students.map((student) {
              return DropdownMenuItem(
                value: student,
                child: Text(
                  '${student.fullName} (${student.className}-${student.sectionName})',
                  style: const TextStyle(color: Colors.white,fontSize: 13),
                ),
              );
            }).toList(),
            onChanged: (student) {
              setState(() => selectedStudent = student);
              if (student != null) _refreshAchievements(student);
            },
          );
        },
      ),
    );
  }

  // ── Achievements list / empty state ──────────────────────────────────────

  Widget _buildAchievementsList() {
    if (selectedStudent == null) {
      return Expanded(child: _emptyHint('Select a student to view achievements'));
    }

    return Expanded(
      child: ref
          .watch(studentAchievementsProvider(selectedStudent!.studentId))
          .when(
        // Spinner while loading achievements
        loading: () =>
        const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, stack) {
          print("Achievement Error => $err");
          print(stack);

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                "Unable to load achievements.\n$err",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
        data: (achievements) {
          if (achievements.isEmpty) {
            return _emptyHint(
              'No achievements added yet',
              showAddButton: true,
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 80.h), // room for FAB
            itemCount: achievements.length,
            itemBuilder: (_, index) =>
                _buildAchievementCard(achievements[index]),
          );
        },
      ),
    );
  }

  Widget _emptyHint(String message, {bool showAddButton = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 64.w, color: Colors.white54),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(fontSize: 16.sp, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          if (showAddButton) ...[
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _openCreateScreen,
              icon: const Icon(Icons.add),
              label: const Text('Add Achievement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Achievement card ──────────────────────────────────────────────────────

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Material(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16.r),
        elevation: 4,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AchievementDetailScreen(achievementId: achievement.id,student: selectedStudent!),
              ),
            ).then((_) => _refreshAchievements(selectedStudent!));
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(Icons.emoji_flags_sharp,color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              _buildChip(
                                  achievement.type.toString(), Colors.pink),
                              SizedBox(width: 8.w),
                              _buildChip(
                                  achievement.level.toString(), Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (achievement.isVerifiedBool)
                      const Icon(Icons.verified, color: Colors.green, size: 20),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Event details ───────────────────────────────────────────
                Row(
                  children: [
                    _buildInfoRow(
                        Icons.emoji_events_outlined, achievement.eventName),
                    SizedBox(width: 16.w),
                    _buildInfoRow(Icons.calendar_today,
                        achievement.achievementDate.toString().split(' ').first),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _buildInfoRow(
                        Icons.business, achievement.organizationName),
                    SizedBox(width: 16.w),
                    _buildInfoRow(
                        Icons.eighteen_mp_outlined, achievement.score),
                  ],
                ),
                SizedBox(height: 12.h),

                // ── Description ─────────────────────────────────────────────
                if (achievement.description.isNotEmpty)
                  Text(
                    achievement.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                    TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                  ),
                SizedBox(height: 12.h),

                // ── Position badge ──────────────────────────────────────────
                if(achievement.positionText != 'Participate')
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: achievement.positionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: achievement.positionColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    achievement.positionText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: achievement.positionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Small helpers ─────────────────────────────────────────────────────────

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11.sp, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: Colors.grey.shade500),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}