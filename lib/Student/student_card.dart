import 'dart:convert';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

import '../Attendance/circleAttendance.dart';
import '../ExamTimeTable/examTimeTable.dart';
import '../common/rotatedDivider_Card.dart';
import 'StudentDashboard.dart';

class StudentCard extends StatefulWidget {
  final Function(int index) onTap;
  StudentCard({super.key, required this.onTap});
  @override
  _StudentCardState createState() => _StudentCardState();
}

class _StudentCardState extends State<StudentCard> {
  List<Map<String, dynamic>> students = [];
  String shortName = "";
  String url = "";
  String academicYr = "";
  String regId = "";
  List<Map<String, dynamic>> examData = [];

  Future<void> _fetchTodaysExams() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsParsed = json.decode(logUrls);
        academicYr = logUrlsParsed['academic_yr'];
        regId = logUrlsParsed['reg_id'];
      } catch (e) {
        print('Error parsing log URLs: $e');
      }
    } else {
      print('Log URLs not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        shortName = parsedData['short_name'];
        url = parsedData['url'];
      } catch (e) {
        print('Error parsing school info: $e');
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$url/get_todays_exam'),
        body: {
          'reg_id': regId,
          'academic_yr': academicYr,
          'short_name': shortName,
        },
      );

      print('get_todays_exam: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> apiResponse = json.decode(response.body);
        setState(() {
          // Use this data to dynamically display the exam data
          examData = List<Map<String, dynamic>>.from(apiResponse);
        });
      } else {
        print(
            'Failed to load exam data with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exam data: $e');
    }
  }

  Future<void> _getSchoolInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? schoolInfoJson = prefs.getString('school_info');
    String? logUrls = prefs.getString('logUrls');

    if (logUrls != null) {
      try {
        Map<String, dynamic> logUrlsParsed = json.decode(logUrls);
        academicYr = logUrlsParsed['academic_yr'];
        regId = logUrlsParsed['reg_id'];
      } catch (e) {
        print('Error parsing log URLs: $e');
      }
    } else {
      print('Log URLs not found in SharedPreferences.');
    }

    if (schoolInfoJson != null) {
      try {
        Map<String, dynamic> parsedData = json.decode(schoolInfoJson);
        shortName = parsedData['short_name'];
        url = parsedData['url'];
      } catch (e) {
        print('Error parsing school info: $e');
      }
    } else {
      print('School info not found in SharedPreferences.');
    }

    if (url.isNotEmpty) {
      try {
        http.Response response = await http.post(
          Uri.parse(url + "get_childs"),
          body: {
            'reg_id': regId,
            'academic_yr': academicYr,
            'short_name': shortName,
          },
        );
        print('Response get_childs: ${response.body}');

        if (response.statusCode == 200) {
          List<dynamic> apiResponse = json.decode(response.body);
          setState(() {
            students = List<Map<String, dynamic>>.from(apiResponse);
          });
        } else {
          print(
              'Failed to load students with status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during http request: $e');
      }
    } else {
      print('URL is empty, cannot make HTTP request.');
    }
  }

  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
    _fetchTodaysExams();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Pop until reaching the HistoryTab route
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        // extendBodyBehindAppBar: true,
        // appBar: AppBar(
        //   // title: Text('My Child'),
        //   backgroundColor: Colors.transparent,
        //   elevation: 0,
        // ),

        body: Stack(

          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/img.png', // Replace with your background image
                fit: BoxFit.cover,
              ),
            ),
            students.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView(
              children: [
                // Display the student cards using ListView.builder
                ListView.builder(
                  shrinkWrap:
                  true, // Important to wrap the builder within the ListView
                  physics:
                  NeverScrollableScrollPhysics(), // Prevent nested scrolling
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    return StudentCardItem(
                      firstName: students[index]['first_name'] ?? '',
                      rollNo: students[index]['roll_no'] ?? '',
                      className: (students[index]['class_name'] ?? '') +
                          (students[index]['section_name'] ?? ''),
                      cname: (students[index]['class_name'] ?? ''),
                      secname: (students[index]['section_name'] ?? ''),
                      classTeacher: students[index]['class_teacher'] ?? '',
                      gender: students[index]['gender'] ?? '',
                      studentId: students[index]['student_id'] ?? '',
                      classId: students[index]['class_id'] ?? '',
                      secId: students[index]['section_id'] ?? '',
                      shortName: shortName,
                      url: url,
                      academicYr: academicYr,
                      onTap: widget.onTap,
                    );
                  },
                ),
                // Display the exam card once for all students
                _buildExamCard(),
              ],
            ),
          ],
        ),
      ),
    );
  }
// Method to build the exam card that shows exams for all students with separate cards for each exam

  Widget _buildExamCard() {
    if (examData.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // if(examData ==  '')
          // Title for the Exam section
          Text(
            'Exams',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),

          // Display exams grouped by student name, with each exam in a separate card
          Column(
            children: examData.map((exam) {
              String examSubject = exam['s_name'] ?? ''; // Fetch subject name
              bool isStudyLeave =
                  examSubject.isEmpty || exam['study_leave'] == 'Y';

              // Parse the date from the response
              DateTime examDate = DateTime.parse(exam['date']);
              DateTime today = DateTime.now();
              DateTime tomorrow = today.add(Duration(days: 1));

              // Determine if the date is Today, Tomorrow, or another day
              String displayDate;
              if (_isSameDay(examDate, today)) {
                displayDate = 'Today';
              } else if (_isSameDay(examDate, tomorrow)) {
                displayDate = 'Tomorrow';
              } else {
                displayDate = exam['date']; // Use the original date format if not Today or Tomorrow
              }

              // Wrap the card with InkWell to detect taps
              return InkWell(
                onTap: () {
                  // Navigate to the exam details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamTimeTablePage(
                        shortName: shortName,academic_yr :exam['academic_yr'],classId:exam['class_id'],secId:exam['section_id']
                        ,className:exam['class_name'] // Pass the exam data to the new page
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: _isSameDay(examDate, tomorrow) ? Colors.grey[300] : Colors.white, // Gray for Tomorrow, white otherwise
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 26.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Student's first name
                        Expanded(
                          flex: 1,
                          child: Text(
                            exam['first_name'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Exam date
                        Expanded(
                          flex: 1,
                          child: Text(
                            displayDate,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Show 'Study Leave' if subject name is empty, else show subject name
                        Expanded(
                          flex: 1,
                          child: Text(
                            isStudyLeave ? 'Study Leave' : examSubject,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: isStudyLeave ? Colors.redAccent : Colors.black,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

// Helper method to check if two DateTime objects represent the same calendar day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

}



class StudentCardItem extends StatefulWidget {
  final String firstName;
  final String rollNo;
  final String className;
  final String cname;
  final String secname;
  final String classTeacher;
  final String gender;
  final String studentId;
  final String shortName;
  final String url;
  final String academicYr;
  final String classId;
  final String secId;
  final Function(int index) onTap;

  StudentCardItem({
    required this.firstName,
    required this.rollNo,
    required this.className,
    required this.cname,
    required this.secname,
    required this.classTeacher,
    required this.gender,
    required this.studentId,
    required this.shortName,
    required this.url,
    required this.academicYr,
    required this.classId,
    required this.secId,
    required this.onTap,
  });

  @override
  _StudentCardItemState createState() => _StudentCardItemState();
}

class _StudentCardItemState extends State<StudentCardItem> {
  String attendance = "Loading";
  late Future<List<StudentCardItem>> future;
  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> refresh() async {
    setState(() {
      _fetchAttendance(); // Refresh the homework notes
    });
  }


  Future<void> _fetchAttendance() async {
    http.Response response = await http.post(
      Uri.parse(widget.url + "get_student_attendance_percentage"),
      body: {
        'student_id': widget.studentId,
        'acd_yr': widget.academicYr,
        'short_name': widget.shortName,
      },
    );

    print('Response percentage: ${response.body}');

    if (response.statusCode == 200) {
      String apiValue = response.body;
      setState(() {
        attendance = apiValue;
      });
    } else {
      setState(() {
        attendance = "N/A";
      });
      print('Failed to load attendance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        var x = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentActivityPage(
              reg_id: reg_id,
              shortName: widget.shortName,
              studentId: widget.studentId,
              academicYr: widget.academicYr,
              url: widget.url,
              firstName: widget.firstName,
              rollNo: widget.rollNo,
              className: widget.className,
              cname: widget.cname,
              secname: widget.secname,
              classTeacher: widget.classTeacher,
              gender: widget.gender,
              classId: widget.classId,
              secId: widget.secId,
              attendance_perc: attendance,
            ),
          ),
        );
        if (x == null) return;
        widget.onTap(x as int);
        if (x == true) {
          refresh();
        }
      },
      child: Column(
        children: [
          _buildStudentInfoCard(),
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0.h),

        child: Card(
          elevation: 4, // Shadow depth for a floating effect
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: EdgeInsets.all(6.0), // Add padding inside the card
            child: Row(
              children: [
                // Student Image Section
                SizedBox.square(
                  dimension: 60.w,
                  child: Image.asset(
                    widget.gender == 'M'
                        ? 'assets/boy.png'
                        : 'assets/girl.png',
                  ),
                ),
                SizedBox(width: 4.w), // Add space between image and details

                // Student Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.firstName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.assignment_turned_in, color: Colors.green, size: 14.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Roll No: ${widget.rollNo}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.class_, color: Colors.blue, size: 14.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Class: ${widget.className}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.red, size: 14.sp),
                          SizedBox(width: 5.w),
                          Text(
                            'Teacher: ${trimTeacherName(widget.classTeacher)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Attendance Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(0,0,10,5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        child: attendance.isNotEmpty && double.tryParse(attendance) != null
                            ? CircularAttendanceIndicator2(
                        percentage:   double.parse(attendance),
                      ): CircularAttendanceIndicator2(
            percentage: 0, // Default to 0 if data is not available
          ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$attendance%',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Attendance',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to determine color based on percentage
  Color _getColor() {
    final double percentage = attendance as double;
    if (percentage <  0.35) {
      return Colors.red; // Red for below 35%
    } else if (percentage < 0.65) {
      return Colors.orange; // Orange for below 65%
    } else {
      return Colors.green; // Green for 65% and above
    }
  }

  String trimTeacherName(String name) {
    List<String> parts = name.split(' ');
    if (parts.length > 2) {
      return '${parts[0]} ${parts[1]}'; // Return the first two parts
    }
    return name; // If there's no second space, return the original name
  }


}