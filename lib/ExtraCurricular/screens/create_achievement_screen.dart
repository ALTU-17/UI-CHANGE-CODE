// lib/screens/achievements/create_achievement_screen.dart
import 'dart:io';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../models/achivment.dart';
import '../providers/achievement_provider.dart';

class CreateAchievementScreen extends ConsumerStatefulWidget {
  final Student student;
  final Achievement? achievement;

  const CreateAchievementScreen({
    super.key,
    required this.student,
    this.achievement,
  });

  @override
  ConsumerState<CreateAchievementScreen> createState() =>
      _CreateAchievementScreenState();
}

class _CreateAchievementScreenState
    extends ConsumerState<CreateAchievementScreen> {
  static const _gradient = LinearGradient(
    colors: [Colors.pink, Colors.blue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _organizationController = TextEditingController();
  final _eventNameController = TextEditingController();
  final _scoreController = TextEditingController();

  AchievementType? selectedType;
  AchievementLevel? selectedLevel;
  DateTime selectedDate = DateTime.now();
  int? selectedPosition;
  List<File> selectedFiles = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.achievement != null) {
      _titleController.text = widget.achievement!.title;
      _descriptionController.text = widget.achievement!.description;
      _organizationController.text = widget.achievement!.organizationName;
      _eventNameController.text = widget.achievement!.eventName;
      _scoreController.text = widget.achievement!.score;
      selectedDate = widget.achievement!.achievementDate;
      selectedPosition = widget.achievement!.position;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _organizationController.dispose();
    _eventNameController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.pink,
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickFiles() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    setState(() {
      selectedFiles = files.map((file) => File(file.path)).toList();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedType == null) { _showSnack('Please select achievement type'); return; }
    if (selectedLevel == null) { _showSnack('Please select achievement level'); return; }

    setState(() => isSubmitting = true);

    final data = {
      'reg_no': widget.student.regNo,
      'student_id': widget.student.studentId,
      'academic_year': academic_yr,
      'title': _titleController.text,
      'description': _descriptionController.text,
      'achievement_date': selectedDate.toIso8601String().split('T')[0],
      'type': selectedType!.value,
      'level': selectedLevel!.value,
      'organization_name': _organizationController.text,
      'event_name': _eventNameController.text,
      'score': _scoreController.text,
      'position': selectedPosition ?? 0,
    };

    try {
      final service = ref.read(achievementServiceProvider);
      Achievement achievement;


        achievement = await service.createAchievement(data); // returns Achievement with id=11


      // ✅ Upload files using the id from the response above
      if (selectedFiles.isNotEmpty) {
        for (var file in selectedFiles) {
          await service.uploadAchievementFile(achievement.id, file);
        }
      }

      if (mounted) {
        _showSnack(
          widget.achievement != null
              ? 'Achievement updated successfully!'
              : 'Achievement created successfully!',
          color: Colors.green,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString()}', color: Colors.red);
        print('Error details: $e');
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(achievementTypesProvider);
    final levelsAsync = ref.watch(achievementLevelsProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _gradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Custom AppBar ─────────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            widget.achievement != null
                                ? 'Edit Achievement'
                                : 'Add Achievement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable body ───────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                      EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Student info — lives on gradient
                            _buildStudentCard(),
                            SizedBox(height: 20.h),

                            // ── White form card ───────────────────────────
                            _buildWhiteCard(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('Achievement Details'),
                                  SizedBox(height: 16.h),
                                  _buildField(
                                    controller: _titleController,
                                    label: 'Achievement Title *',
                                    icon: Icons.emoji_events,
                                    validator: (v) =>
                                    v?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _buildTypeDropdown(
                                              typesAsync)),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                          child: _buildLevelDropdown(
                                              levelsAsync)),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _eventNameController,
                                    label: 'Event Name *',
                                    icon: Icons.event,
                                    validator: (v) =>
                                    v?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _organizationController,
                                    label: 'Organization *',
                                    icon: Icons.business,
                                    validator: (v) =>
                                    v?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _buildDatePicker()),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                          child:
                                          _buildPositionDropdown()),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _scoreController,
                                    label: 'Score / Medal / Award *',
                                    icon: Icons.workspace_premium,
                                    validator: (v) =>
                                    v?.isEmpty ?? true
                                        ? 'Required'
                                        : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _descriptionController,
                                    label: 'Description',
                                    icon: Icons.description,
                                    maxLines: 4,
                                    alignLabelWithHint: true,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // ── White file upload card ────────────────────
                            _buildWhiteCard(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('Supporting Documents'),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Upload certificates, photos, or documents (Max 5 files)',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade500),
                                  ),
                                  SizedBox(height: 12.h),
                                  ElevatedButton.icon(
                                    onPressed: _pickFiles,
                                    icon: const Icon(
                                        Icons.cloud_upload),
                                    label: const Text('Select Files'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.grey.shade100,
                                      foregroundColor: Colors.black87,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10.r),
                                        side: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),
                                  if (selectedFiles.isNotEmpty) ...[
                                    SizedBox(height: 12.h),
                                    Wrap(
                                      spacing: 8.w,
                                      runSpacing: 4.h,
                                      children:
                                      selectedFiles.map((file) {
                                        return Chip(
                                          label: Text(file.path
                                              .split('/')
                                              .last),
                                          onDeleted: () => setState(
                                                  () => selectedFiles
                                                  .remove(file)),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Loading overlay
              if (isSubmitting)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child:
                    CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),

      // ── Bottom submit bar ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.blue,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              disabledBackgroundColor: Colors.pink.withOpacity(0.4),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
            child: Text(
              widget.achievement != null
                  ? 'Update Achievement'
                  : 'Add Achievement',
              style: TextStyle(
                  fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ── White card wrapper ────────────────────────────────────────────────────

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade800,
      ),
    );
  }

  // ── Student card (on gradient background) ─────────────────────────────────

  Widget _buildStudentCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1), blurRadius: 6)
              ],
            ),
            child: Center(
              child: Text(
                widget.student.initials,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.student.fullName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Class ${widget.student.className} - ${widget.student.sectionName}',
                  style:
                  TextStyle(fontSize: 13.sp, color: Colors.white70),
                ),
                // Text(
                //   'Reg No: ${widget.student.regNo}',
                //   style:
                //   TextStyle(fontSize: 12.sp, color: Colors.white60),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Field helpers ─────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.pink.shade300),
      alignLabelWithHint: alignLabelWithHint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.pink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:
        const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
  InputDecoration _spininputDecoration({
    required String label,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: label,labelStyle: TextStyle(fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.pink.shade300),
      alignLabelWithHint: alignLabelWithHint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.pink, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:
        const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool alignLabelWithHint = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        alignLabelWithHint: alignLabelWithHint,
      ),
    );
  }

  Widget _buildTypeDropdown(AsyncValue<List<AchievementType>> typesAsync) {
    return typesAsync.when(
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error'),
      data: (types) => DropdownButtonFormField<AchievementType>(
        value: selectedType,
        decoration:
        _spininputDecoration(label: 'Type *', icon: Icons.category),
        items: types
            .map((t) =>
            DropdownMenuItem(value: t, child: Text(t.label,style: TextStyle(fontSize: 13),)))
            .toList(),
        onChanged: (t) => setState(() => selectedType = t),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildLevelDropdown(
      AsyncValue<List<AchievementLevel>> levelsAsync) {
    return levelsAsync.when(
      loading: () =>
      const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error'),
      data: (levels) => DropdownButtonFormField<AchievementLevel>(
        value: selectedLevel,
        decoration:
        _spininputDecoration(label: 'Level *', icon: Icons.bar_chart),
        items: levels
            .map((l) =>
            DropdownMenuItem(value: l, child: Text(l.label,style: TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (l) => setState(() => selectedLevel = l),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding:
        EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: Colors.pink.shade300, size: 18),
            SizedBox(width: 8.w),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(
                  fontSize: 14.sp, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedPosition,
      decoration: _spininputDecoration(
          label: 'Position', icon: Icons.military_tech),
      items: const [
        DropdownMenuItem(value: 1, child: Text('🥇 1st',style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 2, child: Text('🥈 2nd',style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 3, child: Text('🥉 3rd',style: TextStyle(fontSize: 13))),
        DropdownMenuItem(
            value: 4, child: Text('Participate',style: TextStyle(fontSize: 13))),
      ],
      onChanged: (pos) => setState(() => selectedPosition = pos),
    );
  }
}