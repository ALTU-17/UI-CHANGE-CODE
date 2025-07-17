// lib/screens/achievements/achievement_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

import '../models/achivment.dart';
import '../providers/achievement_provider.dart';
import 'achievement_edit_screen.dart';

class AchievementDetailScreen extends ConsumerStatefulWidget {
  final int achievementId;
  final Student student;

  const AchievementDetailScreen({
    super.key,
    required this.achievementId,
    required this.student,
  });

  @override
  ConsumerState<AchievementDetailScreen> createState() => _AchievementDetailScreenState();
}

class _AchievementDetailScreenState extends ConsumerState<AchievementDetailScreen> {
  bool _isDownloading = false;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);
  }

  @override
  Widget build(BuildContext context) {
    final achievementAsync = ref.watch(achievementDetailsProvider(widget.achievementId));
    final filesAsync = ref.watch(achievementFilesProvider(widget.achievementId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Achievement Details'),
        backgroundColor: const Color(0xFFDC2438),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Edit button in app bar
          achievementAsync.when(
            data: (achievement) => IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEditScreen(achievement),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: Stack(
        children: [
          achievementAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (achievement) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Header
                    _buildHeroHeader(achievement),

                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Position Badge
                          if(achievement.positionText != 'Participate')
                          _buildPositionBadge(achievement),
                          SizedBox(height: 24.h),

                          // Event Details Section
                          _buildDetailSection(
                            'Event Details',
                            Icons.event,
                            [
                              _buildDetailItem(Icons.event_repeat, 'Event Name', achievement.eventName),
                              _buildDetailItem(Icons.business, 'Organization', achievement.organizationName),
                              _buildDetailItem(Icons.calendar_today, 'Date', _formatDate(achievement.achievementDate)),
                              _buildDetailItem(Icons.emoji_events, 'Score/Award', achievement.score),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Description Section
                          if (achievement.description.isNotEmpty)
                            _buildDetailSection(
                              'Description',
                              Icons.description,
                              [
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Text(
                                    achievement.description,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade700,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: 16.h),

                          // Files Section with Download
                          filesAsync.when(
                            loading: () => const SizedBox(),
                            error: (_, __) => const SizedBox(),
                            data: (files) {
                              if (files.isEmpty) return const SizedBox();
                              return _buildDetailSection(
                                'Supporting Documents',
                                Icons.attach_file,
                                [
                                  SizedBox(height: 8.h),
                                  ...files.map((file) {
                                    return _buildFileItem(file);
                                  }),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: 10.h),

                          // Action Buttons
                          _buildActionButtons(achievement),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Loading overlay for download
          if (_isDownloading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40.w,
                        height: 40.h,
                        child: const CircularProgressIndicator(),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Downloading file...',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(Achievement achievement) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF1931), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 65.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events,
                size: 50,
                color: Colors.orangeAccent,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeroChip(achievement.type.toString(), Colors.white),
              SizedBox(width: 8.w),
              _buildHeroChip(achievement.level.toString(), Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionBadge(Achievement achievement) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: achievement.positionColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: achievement.positionColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events,
              color: achievement.positionColor,
              size: 20.w,
            ),
            SizedBox(width: 8.w),

            Text(
              achievement.positionText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: achievement.positionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(AchievementFile file) {
    final fileName = file.fileUrl.split('/').last;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(
          file.fileType == 'pdf'
              ? Icons.picture_as_pdf
              : Icons.image,
          color: file.fileType == 'pdf'
              ? Colors.red
              : Colors.blue,
          size: 24.w,
        ),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.sp),
        ),
        trailing: IconButton(
          icon: Icon(Icons.download, size: 20.w),
          onPressed: () => _downloadFile(file.fileUrl, fileName),
        ),
        // onTap: () => _previewFile(file.fileUrl, file.fileType),
      ),
    );
  }

  Widget _buildActionButtons(Achievement achievement) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToEditScreen(achievement),
            icon: Icon(Icons.edit_outlined, size: 18.w),
            label: Text(
              'Edit Achievement',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF307DD5),
              side: const BorderSide(color: Color(0xFF307DD5)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteConfirmation(achievement),
            icon: Icon(Icons.delete_outline, size: 18.w),
            label: Text(
              'Delete Achievement',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2438),
              side: const BorderSide(color: Color(0xFFDC2438)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadFile(String url, String fileName) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      if (Platform.isAndroid) {
        await _downloadFileAndroid(url, fileName);
      } else if (Platform.isIOS) {
        await _downloadFileIOS(url, fileName);
      }
    } catch (e) {
      _showNotification(
        title: 'Download Failed',
        body: 'Failed to download file: $e',
      );
      _showSnack('Failed to download file: $e', color: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  Future<void> _downloadFileAndroid(String url, String fileName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Create directory
    var directory = Directory("/storage/emulated/0/Download/Evolvuschool/Parent");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    var path = "${directory.path}/$fileName";
    var file = File(path);

    // Show downloading notification
    await _notifications.show(
      0,
      'Downloading File',
      'Downloading $fileName...',
      platformChannelSpecifics,
    );

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        await _notifications.show(
          0,
          'Download Complete',
          'File saved to Download/Evolvuschool/Parent/$fileName',
          platformChannelSpecifics,
          payload: path,
        );

        _showSnack(
          'File downloaded successfully: Download/Evolvuschool/Parent/',
          color: Colors.green,
        );
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      await _notifications.show(
        0,
        'Download Failed',
        'Failed to download file',
        platformChannelSpecifics,
      );
      rethrow;
    }
  }

  Future<void> _downloadFileIOS(String url, String fileName) async {
    // Get the documents directory on iOS
    final directory = await getApplicationDocumentsDirectory();

    // Construct the full path for the downloaded file
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Show downloading notification
    await _notifications.show(
      0,
      'Downloading File',
      'Downloading $fileName...',
      platformChannelSpecifics,
    );

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        await _notifications.show(
          0,
          'Download Complete',
          'File saved to $filePath',
          platformChannelSpecifics,
          payload: filePath,
        );

        _showSnack(
          'Find it in the Files/On My iPhone/EvolvU Smart School - Parent.',
          color: Colors.green,
        );
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e) {
      await _notifications.show(
        0,
        'Download Failed',
        'Failed to download file',
        platformChannelSpecifics,
      );
      rethrow;
    }
  }

  Future<void> _showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(0, title, body, platformDetails);
  }

  void _navigateToEditScreen(Achievement achievement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementEditScreen(
          achievementId: widget.achievementId,
          achievementData: achievement,
          student: widget.student,
        ),
      ),
    ).then((result) {
      if (result == true) {
        ref.refresh(achievementDetailsProvider(widget.achievementId));
        ref.refresh(achievementFilesProvider(widget.achievementId));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Achievement updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showDeleteConfirmation(Achievement achievement) {
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
          'Are you sure you want to delete "${achievement.title}"? This action cannot be undone.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
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
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAchievement() async {
    setState(() => _isDownloading = true);

    try {
      final service = ref.read(achievementServiceProvider);
      await service.deleteAchievement(widget.achievementId);

      if (mounted) {
        _showSnack('Achievement deleted successfully!', color: Colors.green);
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnack('Error deleting achievement: $e', color: Colors.red);
    } finally {
      if (mounted) setState(() => _isDownloading = false);
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

  void _previewFile(String fileUrl, String fileType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text('File Preview'),
        content: Text('Preview functionality coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  Widget _buildHeroChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12.sp,
            color: color,
            fontWeight: FontWeight.w500
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20.w, color: const Color(0xFF6A11CB)),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: Colors.grey.shade500),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}