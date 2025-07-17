// lib/screens/achievements/achievement_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../models/achivment.dart';
import '../providers/achievement_provider.dart';

class AchievementEditScreen extends ConsumerStatefulWidget {
  final int achievementId;
  final Student student;
  final Achievement achievementData;

  const AchievementEditScreen({
    super.key,
    required this.achievementId,
    required this.student,
    required this.achievementData,
  });

  @override
  ConsumerState<AchievementEditScreen> createState() => _AchievementEditScreenState();
}

class _AchievementEditScreenState extends ConsumerState<AchievementEditScreen> {
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
  List<File> newFiles = [];
  List<ExistingFile> existingFiles = [];
  List<int> filesToDelete = []; // Track file IDs to delete
  bool isSubmitting = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievementData();
  }

  void _loadAchievementData() {
    final achievement = widget.achievementData;

    _titleController.text = achievement.title;
    _descriptionController.text = achievement.description;
    _organizationController.text = achievement.organizationName;
    _eventNameController.text = achievement.eventName;
    _scoreController.text = achievement.score;
    selectedDate = achievement.achievementDate;
    selectedPosition = achievement.position;

    // Load types and levels from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final typesAsync = ref.read(achievementTypesProvider);
      final levelsAsync = ref.read(achievementLevelsProvider);

      typesAsync.whenData((types) {
        selectedType = types.firstWhere(
              (t) => t.value == achievement.type,
          orElse: () => types.first,
        );
        setState(() {});
      });

      levelsAsync.whenData((levels) {
        selectedLevel = levels.firstWhere(
              (l) => l.value == achievement.level,
          orElse: () => levels.first,
        );
        setState(() {});
      });

      // Load existing files
      _loadExistingFiles();
    });
  }

  Future<void> _loadExistingFiles() async {
    setState(() => isLoading = true);
    try {
      final service = ref.read(achievementServiceProvider);
      final files = await service.getAchievementFiles(widget.achievementId);
      setState(() {
        existingFiles = files.map((file) => ExistingFile(
          id: file.id,
          fileName: file.fileUrl.split('/').last,
          fileUrl: file.fileUrl,
          fileType: file.fileType,
        )).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnack('Error loading files: $e', color: Colors.red);
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
      newFiles.addAll(files.map((file) => File(file.path)));
    });
  }

  void _removeNewFile(int index) {
    setState(() {
      newFiles.removeAt(index);
    });
  }

  void _removeExistingFile(int index) async {
    final fileToRemove = existingFiles[index];

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('Remove File'),
        content: Text('Are you sure you want to remove "${fileToRemove.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        // Add file ID to delete list
        filesToDelete.add(fileToRemove.id);
        // Remove from existing files list
        existingFiles.removeAt(index);
      });
      _showSnack('File marked for deletion', color: Colors.orange);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedType == null) {
      _showSnack('Please select achievement type');
      return;
    }
    if (selectedLevel == null) {
      _showSnack('Please select achievement level');
      return;
    }

    setState(() => isSubmitting = true);

    // Prepare data matching the API expected format
    final Map<String, dynamic> data = {
      'id': widget.achievementId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'achievement_date': selectedDate.toIso8601String().split('T')[0],
      'type': selectedType!.value,
      'level': selectedLevel!.value,
      'organization_name': _organizationController.text.trim(),
      'event_name': _eventNameController.text.trim(),
      'score': _scoreController.text.trim(),
      'position': _getPositionText(selectedPosition),
      'is_external': true,
    };

    // Remove position if it's null or empty
    if (data['position'] == null || data['position'].toString().isEmpty) {
      data.remove('position');
    }

    print('Updating achievement data: $data');

    try {
      final service = ref.read(achievementServiceProvider);

      // Step 1: Update achievement
      await service.updateAchievement(data);
      print('Achievement updated successfully');

      // Step 2: Delete files that were removed
      if (filesToDelete.isNotEmpty) {
        print('Deleting ${filesToDelete.length} files...');
        for (var fileId in filesToDelete) {
          try {
            await service.deleteAchievementFile(fileId);
            print('File deleted: $fileId');
          } catch (deleteError) {
            print('Error deleting file $fileId: $deleteError');
            // Continue with other operations even if one delete fails
          }
        }
      }

      // Step 3: Upload new files
      if (newFiles.isNotEmpty) {
        print('Uploading ${newFiles.length} new files...');
        for (var file in newFiles) {
          try {
            await service.uploadAchievementFile(widget.achievementId, file);
            print('File uploaded: ${file.path}');
          } catch (fileError) {
            print('Error uploading file: $fileError');
            _showSnack('Warning: Some files failed to upload', color: Colors.orange);
          }
        }
      }

      if (mounted) {
        _showSnack('Achievement updated successfully!', color: Colors.green);
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      print('Error in submission: $e');
      if (mounted) {
        _showSnack('Error: ${e.toString()}', color: Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  String _getPositionText(int? position) {
    if (position == null) return '';
    switch (position) {
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return 'Participate';
    }
  }

  void _showSnack(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(achievementTypesProvider);
    final levelsAsync = ref.watch(achievementLevelsProvider);

    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: _gradient),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

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
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Edit Achievement',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Delete button in app bar
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.white),
                          onPressed: _showDeleteConfirmation,
                        ),
                      ],
                    ),
                  ),

                  // ── Scrollable body ───────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderCard(),
                            SizedBox(height: 20.h),

                            // ── White form card ───────────────────────────
                            _buildWhiteCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('Achievement Details'),
                                  SizedBox(height: 16.h),
                                  _buildField(
                                    controller: _titleController,
                                    label: 'Achievement Title *',
                                    icon: Icons.emoji_events,
                                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  Row(
                                    children: [
                                      Expanded(child: _buildTypeDropdown(typesAsync)),
                                      SizedBox(width: 12.w),
                                      Expanded(child: _buildLevelDropdown(levelsAsync)),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _eventNameController,
                                    label: 'Event Name *',
                                    icon: Icons.event,
                                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _organizationController,
                                    label: 'Organization *',
                                    icon: Icons.business,
                                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                                  ),
                                  SizedBox(height: 14.h),
                                  Row(
                                    children: [
                                      Expanded(child: _buildDatePicker()),
                                      SizedBox(width: 12.w),
                                      Expanded(child: _buildPositionDropdown()),
                                    ],
                                  ),
                                  SizedBox(height: 14.h),
                                  _buildField(
                                    controller: _scoreController,
                                    label: 'Score / Medal / Award *',
                                    icon: Icons.workspace_premium,
                                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sectionTitle('Supporting Documents'),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Upload certificates, photos, or documents (Max 5 files)',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                                  ),
                                  SizedBox(height: 12.h),

                                  // Existing Files
                                  if (existingFiles.isNotEmpty) ...[
                                    Text(
                                      'Current Files:',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    ...existingFiles.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final file = entry.value;
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8.h),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(color: Colors.grey.shade200),
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            file.fileType == 'pdf'
                                                ? Icons.picture_as_pdf
                                                : Icons.image,
                                            color: file.fileType == 'pdf' ? Colors.red : Colors.blue,
                                            size: 24.w,
                                          ),
                                          title: Text(
                                            file.fileName,
                                            style: TextStyle(fontSize: 13.sp),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(Icons.close, size: 18.w, color: Colors.red),
                                            onPressed: () => _removeExistingFile(index),
                                          ),
                                          onTap: () {
                                            _previewFile(file.fileUrl, file.fileType);
                                          },
                                        ),
                                      );
                                    }).toList(),
                                    SizedBox(height: 12.h),
                                  ],

                                  // Add New Files Button
                                  ElevatedButton.icon(
                                    onPressed: _pickFiles,
                                    icon: const Icon(Icons.cloud_upload),
                                    label: const Text('Add New Files'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade100,
                                      foregroundColor: Colors.black87,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                        side: BorderSide(color: Colors.grey.shade300),
                                      ),
                                    ),
                                  ),

                                  // New Files List
                                  if (newFiles.isNotEmpty) ...[
                                    SizedBox(height: 12.h),
                                    Text(
                                      'New Files to Upload:',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    ...newFiles.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final file = entry.value;
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8.h),
                                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(10.r),
                                          border: Border.all(color: Colors.green.shade200),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.insert_drive_file, size: 20.w, color: Colors.green),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                file.path.split('/').last,
                                                style: TextStyle(fontSize: 13.sp),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.close, size: 18.w, color: Colors.red),
                                              onPressed: () => _removeNewFile(index),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
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
                    child: CircularProgressIndicator(color: Colors.white),
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
          color: Colors.white,
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
              'Update Achievement',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24.w),
            SizedBox(width: 8.w),
            Text(
              'Delete Achievement',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this achievement? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAchievement();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAchievement() async {
    setState(() => isSubmitting = true);

    try {
      final service = ref.read(achievementServiceProvider);
      await service.deleteAchievement(widget.achievementId);

      if (mounted) {
        _showSnack('Achievement deleted successfully!', color: Colors.green);
        Navigator.pop(context, true); // Return to detail screen
        Navigator.pop(context, true); // Return to list screen
      }
    } catch (e) {
      if (mounted) _showSnack('Error deleting achievement: $e', color: Colors.red);
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _previewFile(String fileUrl, String fileType) {
    // TODO: Implement file preview
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: const Text('File Preview'),
        content: const Text('Preview functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── UI Components ─────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
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
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6)
              ],
            ),
            child: const Center(
              child: Icon(Icons.edit_note, color: Colors.pink, size: 28),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.student.fullName}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Editing Achievement',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
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
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error'),
      data: (types) => DropdownButtonFormField<AchievementType>(
        value: selectedType,
        decoration: _inputDecoration(label: 'Type *', icon: Icons.category),
        items: types
            .map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: TextStyle(fontSize: 13))))
            .toList(),
        onChanged: (t) => setState(() => selectedType = t),
        validator: (v) => v == null ? 'Required' : null,
      ),
    );
  }

  Widget _buildLevelDropdown(AsyncValue<List<AchievementLevel>> levelsAsync) {
    return levelsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Error'),
      data: (levels) => DropdownButtonFormField<AchievementLevel>(
        value: selectedLevel,
        decoration: _inputDecoration(label: 'Level *', icon: Icons.bar_chart),
        items: levels
            .map((l) => DropdownMenuItem(value: l, child: Text(l.label, style: TextStyle(fontSize: 13))))
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
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.pink.shade300, size: 18),
            SizedBox(width: 8.w),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionDropdown() {
    return DropdownButtonFormField<int>(
      value: selectedPosition,
      decoration: _inputDecoration(label: 'Position', icon: Icons.military_tech),
      items: const [
        DropdownMenuItem(value: 1, child: Text('🥇 1st', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 2, child: Text('🥈 2nd', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 3, child: Text('🥉 3rd', style: TextStyle(fontSize: 13))),
        DropdownMenuItem(value: 4, child: Text('Participate', style: TextStyle(fontSize: 13))),
      ],
      onChanged: (pos) => setState(() => selectedPosition = pos),
    );
  }
}

// Helper class for existing files
class ExistingFile {
  final int id;
  final String fileName;
  final String fileUrl;
  final String fileType;

  ExistingFile({
    required this.id,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
  });
}