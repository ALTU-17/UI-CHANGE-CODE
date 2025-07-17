import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ReAdmissionConfirmationPage extends StatefulWidget {
  final String laravel_project_url;
  final String studentName;
  final String currentClass;
  final String nextClass;
  final String academicYr;
  final String shortName;
  final String studentId;
  final String currentClassId;
  final int nextClassId;

  const ReAdmissionConfirmationPage({
    super.key,
    required this.laravel_project_url,
    required this.studentName,
    required this.currentClass,
    required this.nextClass,
    required this.academicYr,
    required this.shortName,
    required this.studentId,
    required this.currentClassId,
    required this.nextClassId,
  });

  @override
  State<ReAdmissionConfirmationPage> createState() =>
      _ReAdmissionConfirmationPageState();
}

class _ReAdmissionConfirmationPageState
    extends State<ReAdmissionConfirmationPage> with SingleTickerProviderStateMixin {
  // 0 = none selected, 1 = yes, 2 = no
  int _selectedOption = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Future<String?> getLaravelToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  Future<void> _saveReAdmission(String confirm) async {
    setState(() {
      _isLoading = true;
    });

    try {

      final token = await getLaravelToken();
      print('token body: ${token}');

      if (token == null || token.isEmpty) {
        _showErrorDialog('Authentication failed. Please login again.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final url = Uri.parse(widget.laravel_project_url+'save_readmission');

      final requestBody = {
        'student_id': widget.studentId.toString(),
        'current_class_id': widget.currentClassId.toString(),
        'next_class_id': widget.nextClassId.toString(),
        'confirm': confirm,
        'academic_yr': widget.academicYr,
      };

      print('API Request Body: $requestBody');

      final response = await http.post(
        url,
        body: requestBody,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout. Please try again.');
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // Success
          final choice = confirm == 'Y' ? 'Yes' : 'No';
          _showSuccessDialog(choice);
        } else {
          // API returned error
          _showErrorDialog(
              responseData['message'] ?? 'Failed to save record. Please try again.'
          );
        }
      } else {
        // HTTP error
        _showErrorDialog('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      _showErrorDialog('Network error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSubmit() {
    if (_selectedOption == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12.w),
              Expanded(
                child: Text('Please select an option before submitting.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // If user selected "No" (value = 2), show confirmation dialog
    if (_selectedOption == 2) {
      _showNoConfirmationDialog();
    } else {
      // For "Yes" option, proceed directly
      final confirm = 'Y';
      _saveReAdmission(confirm);
    }
  }

  void _showNoConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.red.shade700,
            ),
            SizedBox(height: 12.h),
            Text(
              'Confirm Your Decision',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Are you sure you do not want to continue?\n\nYour ward will not be promoted to the next class.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: Text(
              'No, Go Back',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blueAccent,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              final confirm = 'N';
              _saveReAdmission(confirm); // Proceed with API call
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              'Yes, Confirm',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String choice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Icon(
              choice == 'Yes' ? Icons.check_circle_outline : Icons.info_outline,
              size: 60,
              color: choice == 'Yes' ? Colors.green : Colors.orange,
            ),
            SizedBox(height: 12.h),
            Text(
              choice == 'Yes' ? 'Confirmation Received!' : 'We\'re Sorry to See You Go',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          choice == 'Yes'
              ? 'Thank you for confirming your ward\'s continuation. You will now be able to proceed with fee payment for the next academic year.'
              : 'We have noted your response. If this is a mistake, please contact the school administration.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Column(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.red,
            ),
            SizedBox(height: 12.h),
            Text(
              'Submission Failed',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Try Again',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCancel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Cancel Confirmation',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel? Your response will not be saved.',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'No',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 80.h,
        title: Text(
          "${widget.shortName} EvolvU Smart Parent App(${widget.academicYr})",
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 0.h),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 2.h),

                      // Main Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header Gradient
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.pink.shade500, Colors.blue.shade500],
                                  begin: Alignment.topRight,
                                  end: Alignment.topLeft,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.assignment_ind_outlined,
                                    color: Colors.white,
                                    size: 24.w,
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Re-Admission Confirmation',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 20.h,
                              ),
                              child: Column(
                                children: [
                                  // Student Info Cards
                                  _buildInfoCard(
                                    icon: Icons.person_outline,
                                    label: 'Student Name',
                                    value: widget.studentName,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 12.h),

                                  _buildInfoCard(
                                    icon: Icons.class_outlined,
                                    label: 'Current Class',
                                    value: widget.currentClass,
                                    color: Colors.green,
                                  ),
                                  SizedBox(height: 12.h),

                                  _buildInfoCard(
                                    icon: Icons.trending_up_outlined,
                                    label: 'Next Class',
                                    value: widget.nextClass,
                                    color: Colors.orange,
                                  ),

                                  SizedBox(height: 10.h),

                                  // Divider
                                  Container(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),

                                  SizedBox(height: 10.h),

                                  // Question text
                                  Container(
                                    padding: EdgeInsets.all(12.h),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.help_outline,
                                          color: Colors.blue.shade700,
                                          size: 16.w,
                                        ),
                                        SizedBox(width: 10.w),
                                        Expanded(
                                          child: Text(
                                            'Will your ward continue to the next class?',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 10.h),

                                  // Option: Yes
                                  _RadioOptionTile(
                                    label: 'Yes, my ward will continue',
                                    value: 1,
                                    groupValue: _selectedOption,
                                    onChanged: (val) =>
                                        setState(() => _selectedOption = val!),
                                    icon: Icons.check_circle_outline,
                                  ),

                                  SizedBox(height: 12.h),

                                  // Option: No
                                  _RadioOptionTile(
                                    label: 'No, my ward will not continue',
                                    value: 2,
                                    groupValue: _selectedOption,
                                    onChanged: (val) =>
                                        setState(() => _selectedOption = val!),
                                    icon: Icons.cancel_outlined,
                                  ),

                                  SizedBox(height: 10.h),

                                  // Info text (green)
                                  Container(
                                    padding: EdgeInsets.all(16.h),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.green.shade50,
                                          Colors.green.shade100,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          size: 20.w,
                                          color: Colors.green.shade700,
                                        ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Text(
                                            'Once you confirm, you will be provided with the option to pay the fees for the next academic year which will confirm your ward\'s admission in the next class.',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.green.shade700,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: 24.h),

                                  // Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: _isLoading ? null : _onCancel,
                                          icon: Icon(
                                            Icons.close_outlined,
                                            size: 18.w,
                                          ),
                                          label: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.redAccent,
                                            side: BorderSide(
                                              color: Colors.redAccent,
                                              width: 1.5,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _isLoading ? null : _onSubmit,
                                          icon: _isLoading
                                              ? SizedBox(
                                            width: 18.w,
                                            height: 18.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                              : Icon(
                                            Icons.send_outlined,
                                            size: 18.w,
                                          ),
                                          label: Text(
                                            _isLoading ? 'Submitting...' : 'Submit',
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 12.h,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.r),
                                            ),
                                            elevation: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Saving your response...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
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

// ── Reusable Widgets ──────────────────────────────────────────────────────────

class _RadioOptionTile extends StatelessWidget {
  final String label;
  final int value;
  final int groupValue;
  final ValueChanged<int?> onChanged;
  final IconData icon;

  const _RadioOptionTile({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.06)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18.w,
                color: isSelected ? Colors.blueAccent : Colors.grey.shade500,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.blueAccent : Colors.black87,
                ),
              ),
            ),
            Radio<int>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.blueAccent,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}