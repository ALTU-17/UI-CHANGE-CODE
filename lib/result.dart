import 'dart:convert';
import 'dart:io';
import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ResultChart.dart';
import 'WebViewScreens/OnlineFeesPayment.dart';
import 'main.dart';

// Result model class to map the API response
class ExamResult {
  final String examId;
  final String examName;
  final String className;
  final String termId;
  final List<SubjectDetail> details;

  ExamResult({
    required this.examId,
    required this.examName,
    required this.className,
    required this.termId,
    required this.details,
  });

  // Factory method to parse JSON
  factory ExamResult.fromJson(Map<String, dynamic> json) {
    List<dynamic> detailList = json['Details'] ?? [];
    List<SubjectDetail> parsedDetails = detailList
        .map((detail) => SubjectDetail.fromJson(jsonDecode(detail)))
        .toList();

    return ExamResult(
      examId: json['Exam_id'],
      examName: json['Exam_name'],
      className: json['class_name'],
      termId: json['term_id'],
      details: parsedDetails,
    );
  }
}

// SubjectDetail model for inner 'Details' field
class SubjectDetail {
  final String subject;
  final String markHeadings;
  final String marksObtained;
  final String highestMarks;

  SubjectDetail({
    required this.subject,
    required this.markHeadings,
    required this.marksObtained,
    required this.highestMarks,
  });

  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    return SubjectDetail(
      subject: json['Subject'],
      markHeadings: json['Mark_headings'],
      marksObtained: json['Marks_obtained'],
      highestMarks: json['Highest_marks'],
    );
  }
}

class ResultPage extends StatefulWidget {
  final String studentId;
  final String academicYr;
  final String shortName;
  final String classId;
  final String secId;
  final String Fname;
  final String className;
  final String cname;

  ResultPage({
    required this.className,
    required this.Fname,
    required this.studentId,
    required this.academicYr,
    required this.shortName,
    required this.classId,
    required this.secId,
    required this.cname,
  });

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  // Sample dynamic data that would be fetched from API
  List<ExamResult> examData = [];

  // Visibility flags for the cards
  int cbseCardVisible = 0; // 1 means visible, 0 means hidden
  int viewReportCardVisible = 0; // 1 means visible, 0 means hidden
  int resultChartVisible = 0; // 1 means visible, 0 means hidden
  int hpcVisible = 0; // 1 = show, 0 = hide
  int FeePendVisible = 0; // 1 = show, 0 = hide

  String ShowResult = 'N';
  String CBSE_URL = '';
  String hpc_reportcard_url = '';
  bool isLoading = true;
  String showCBSE = 'N';
  String error_msg = "";
  bool error_msg_flag = false;

  @override
  void initState() {
    super.initState();
    // CBSE_ReportCard();
    checkPendingFee();
    checkHpcReportCard();
    print('CBSE Report Card is visible ${widget.cname}');
  }

  Future<void> checkPendingFee() async {
    final url1 = Uri.parse(url + 'check_pending_fee');

    try {
      final response = await http.post(
        url1,
        body: {
          'student_id': widget.studentId,
          'short_name': widget.shortName,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('check_pending_fee response: ${response.body}');

        int pendingFee = data['pending_fee'] ?? 0;
        String msg = data['error_msg'] ?? '';

        setState(() {
          FeePendVisible = pendingFee; // 1 = pending fee, 0 = clear
          error_msg = msg;
          error_msg_flag = (pendingFee == 1);
        });

        if (pendingFee == 1) {
          // Only show error message, no exam data or report cards
          print('⚠️ Pending Fee Detected: $msg');
          setState(() {
            examData = [];
            resultChartVisible = 0;
            viewReportCardVisible = 0;
            cbseCardVisible = 0;
            hpcVisible = 0;
            isLoading = false;
          });
        } else {
          // No pending fee, continue normal flow
          print('✅ No Pending Fee');
          check_report_card(); // Continue normal data loading
        }
      } else {
        print('❌ Failed to fetch pending fee data: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking pending fee: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> check_report_card() async {
    final url1 = Uri.parse(url + 'check_report_card');
    print('check_report_card URL: $url check_report_card');

    try {
      final response = await http.post(
        url1,
        body: {
          'short_name': widget.shortName,
          'student_id': widget.studentId,
          'acd_yr': widget.academicYr
          // 'student_id': '2444',
          // 'short_name': widget.shortName,
          // 'academic_yr': '2023-2024',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        error_msg = data['error_msg'] ?? ''; // Default to '' if not found
        FeePendVisible = data['flag'];
        print('check_report_card response: ${response.body}');
        // print('check_report_card response: ${response.statusCode}');
        // print('check_report_card response111: ${error_msg}');

        setState(() {
          // Update viewReportCardVisible based on the API flag
          viewReportCardVisible = (FeePendVisible == 1) ? 1 : 0;

          // If flag is 1, fetch dashboard data and exam results
          if (FeePendVisible == 1) {
            Show_icon();
            fetchExamResults();
          } else if (error_msg.isEmpty) {
            error_msg_flag = false;
            fetchExamResults();
          } else if (error_msg ==
              "Please pay the pending fees to view marks and report card.") {
            fetchExamResults();
            error_msg_flag = true;
            resultChartVisible = 0;
          }
        });

        print('View Report Card Visibility: $viewReportCardVisible');
      } else {
        setState(() {
          viewReportCardVisible = 0;
        });
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking report card: $e');
      setState(() {
        viewReportCardVisible = 0;
      });
    }
  }

  Future<void> Show_icon() async {
    final url1 = Uri.parse(url + 'show_icons_parentdashboard_apk');

    try {
      final response = await http.post(
        url1,
        body: {'short_name': widget.shortName},
      );

      if (response.statusCode == 200) {
        print('Show Icon response body: ${response.body}');

        // Safely decode JSON response
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data == null || data.isEmpty) {
          print('Response is empty.');
        } else {
          try {
            // Handle the error_msg
            String msg = data['error_msg'] ?? '';
            print('error_msg ==> $msg');

            // hpc_reportcard_url = data['hpc_reportcard_url'];
            // print('hpc_reportcard_url  ${data['hpc_reportcard_url']}');

            // Checking for the graph (should be an integer check)
            if (data['graph'] == 1) {
              print('Graph is visible');
              setState(() {
                resultChartVisible = 1;
              });
            } else {
              print('Graph is hidden');
              setState(() {
                resultChartVisible = 0;
              });
            }

            // Checking for the CBSE Report Card visibility
            if (data['cbse_reportcard'] == 1) {
              print('CBSE Report Card ${widget.cname}');

              // Convert to int if cname might be string
              int classNum = int.tryParse(widget.cname.toString()) ?? 0;

              if (classNum >= 9 && classNum <= 11) {
                setState(() {
                  cbseCardVisible = 1;
                  showCBSE = "Y";
                });
                print('✅ CBSE Report Card is visible for class $classNum');
              } else {
                setState(() {
                  cbseCardVisible = 0;
                  showCBSE = 'N';
                });
                print('⚠️ CBSE Report Card hidden (class below 9 or above 11)');
              }
            } else {
              setState(() {
                cbseCardVisible = 0;
                showCBSE = 'N';
              });
              print('❌ CBSE Report Card is disabled in API');
            }

            // Check if there are other fields like 'message1_url' and 'message2_url'
            String message1Url =
                data['message1_url'] ?? ''; // Default to empty if null
            String message2Url = data['message2_url'] ?? '';

            print('message1 URL: $message1Url');
            print('message2 URL: $message2Url');
          } catch (e) {
            print('Error parsing data: $e');
          }
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  // Function to simulate fetching data from an API
  Future<void> fetchExamResults() async {
    // Example of how you might fetch data from an API using http package
    // Replace this URL with your actual API endpoint
    final String apiUrl = '${url}student_marks';

    try {
      // Example API call (replace with actual API call)
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          // 'class_id': '25',
          // 'section_id': '91',
          // 'student_id': '2444',
          // 'short_name': widget.shortName,
          // 'academic_yr': '2023-2024',
          'class_id': widget.classId,
          'section_id': widget.secId,
          'student_id': widget.studentId,
          'short_name': widget.shortName,
          'academic_yr': widget.academicYr,
        },
      );

      if (response.statusCode == 200) {
        print('student_marks fetching results: ${response.body}');
        print('fetching results code : ${response.statusCode}');

        // Assuming your response is a JSON list of maps
        List<dynamic> jsonData = jsonDecode(response.body);

        // Map the JSON response to a list of ExamResult objects
        List<ExamResult> results =
            jsonData.map((data) => ExamResult.fromJson(data)).toList();

//Set Validation herrrrrre

        if (results.isNotEmpty) {
          String examName = results[0].examName;

          // Get the Exam_name
          print('Exam_name: $examName');

          if (examName == "Final exam" ||
              examName == "Term 1" ||
              examName == "Term 2") {
            if (cbseCardVisible == 'Y' && widget.className == 9 ||
                widget.className == 11) {
              CBSE_ReportCard();

              if (CBSE_ReportCard() == 1) {
              } else {}
            }
          }
        }

        setState(() {
          examData = results; // Update your state variable to use this list
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      ShowResult = 'N';
      print('Error fetching results: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String getDisplayMark(String obtained, String highest) {
    final gradePattern = RegExp(r'^[A-Za-z]+$'); // Only letters = grade
    final numericPattern = RegExp(r'^[0-9]+$'); // Only numbers = marks

    if (obtained.isEmpty) {
      return '';
    }

    if (gradePattern.hasMatch(obtained)) {
      return obtained; // show only grade
    }

    if (numericPattern.hasMatch(obtained)) {
      return '$obtained/$highest'; // show marks out of total
    }

    return obtained;
  }

  Future<void> CBSE_ReportCard() async {
    final url1 = Uri.parse(url + 'check_cbseformat_report_card');

    try {
      final response = await http.post(url1, body: {
        'short_name': widget.shortName,
        'student_id': widget.studentId,
        // 'student_id': '2444', // Assuming hardcoded student ID for now
      });

      print('cbse_reportcard response: ${response.body}');

      if (response.statusCode == 200) {
        print('cbse_reportcard response: ${response.body}');

        final Map<String, dynamic> data1 = jsonDecode(response.body);

        // Make sure 'flag' is accessed as an int
        int flag = data1['flag'];

        // Check if the flag is 1
        if (flag == 0) {
          print('CBSE flag000 : $flag');

          cbseCardVisible = 0; // 1 means visible, 0 means hidden
        } else {
          cbseCardVisible = 1; // 1 means visible, 0 means hidden
        }

        print('CBSE flag: $flag');
      } else {
        cbseCardVisible = 0; // 1 means visible, 0 means hidden

        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
      cbseCardVisible = 0; // Hide the card in case of an error
    }
  }

  Future<void> checkHpcReportCard() async {
    final Uri apiUrl = Uri.parse(url + 'check_hpc_report_card');

    try {
      final response = await http.post(
        apiUrl,
        body: {
          'student_id': widget.studentId,
          'short_name': widget.shortName,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('HPC API Response: ${response.body}');

        int flag = data['flag'] ?? 0;
        String reportUrl = data['hpc_reportcard_url'] ?? '';

        setState(() {
          hpc_reportcard_url = reportUrl;
          hpcVisible = (flag == 1) ? 1 : 0; // ✅ independent visibility flag
        });

        if (flag == 1) {
          print('✅ HPC Report Card Available');
          print('📄 Download URL: $reportUrl');
        } else {
          print('❌ HPC Report Card Not Available');
        }
      } else {
        print(
            'Failed to fetch HPC report card. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching HPC report card: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAnyCardVisible = cbseCardVisible == 1 ||
        viewReportCardVisible == 1 ||
        resultChartVisible == 1;

    // Outer container with the gradient background
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink, Colors.blue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.pink,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Result',
            style: TextStyle(color: Colors.white),
          ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      if (error_msg_flag == true)
                        Center(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentWebview(
                                      regId: reg_id,
                                      paymentUrlShare: paymentUrlShare,
                                      receiptUrl: receiptUrl,
                                      shortName: shortName,
                                      academicYr: academic_yr,
                                      receipt_button: receipt_button),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 0),
                              child: Card(
                                color: Colors.yellow.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.currency_rupee_sharp),
                                      SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          error_msg,
                                          softWrap: true,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(Icons.touch_app_outlined),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // ✅ 1️⃣ Always show HPC Card independently
                      if (FeePendVisible==0 &&
                          hpcVisible == 1 &&
                          hpc_reportcard_url.isNotEmpty &&
                          ["Nursery", "LKG", "UKG", "1", "2"]
                              .contains(widget.cname))
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icon(Icons.picture_as_pdf,
                              //     size: 50.sp, color: Colors.blueAccent),
                              // const SizedBox(height: 8),
                              // Text(
                              //   "Holistic Report Card",
                              //   style: TextStyle(
                              //     fontSize: 14.sp,
                              //     fontWeight: FontWeight.bold,
                              //     color: Colors.black87,
                              //   ),
                              // ),
                              // const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: const Icon(Icons.download),
                                label: const Text("Download HPC Report Card"),
                                onPressed: () async {
                                  print(
                                      'Downloading HPC report from $hpc_reportcard_url');
                                  String fullUrl =
                                      "$hpc_reportcard_url?student_id=${widget.studentId}";
                                  DateTime now = DateTime.now();
                                  String date =
                                      DateFormat('yyyy-MM-dd').format(now);
                                  if (Platform.isAndroid) {
                                    _permissionRequest();
                                    await downloadFile(fullUrl, context,
                                        'HPC_Report_${widget.Fname}_$date.pdf');
                                  } else if (Platform.isIOS) {
                                    await _downloadFileIOS(fullUrl, context,
                                        'HPC_Report_${widget.Fname}_$date.pdf');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('Failed to download file'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                      if (cbseCardVisible == 1 || viewReportCardVisible == 1 || resultChartVisible == 1)
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 3,
                          crossAxisSpacing: 7.w,
                          mainAxisSpacing: 7.h,
                          children: [
                            if (hpcVisible == 1 &&
                                hpc_reportcard_url.isNotEmpty &&
                                ["Nursery", "LKG", "UKG", "1", "2"]
                                    .contains(widget.cname))
                              _buildCard('Download HPC Report Card',
                                  Icons.add_chart, Colors.lightBlueAccent, () {
                                print(
                                    'hpc_reportcard_url: $hpc_reportcard_url');
                                String fullUrl = hpc_reportcard_url +
                                    "?student_id=${widget.studentId}";
                                print(
                                    ' hpc_reportcard_url downloadUrl $fullUrl');
                                DateTime now = DateTime.now();
                                String date =
                                    DateFormat('yyyy-MM-dd').format(now);
                                // downloadFile(fullUrl, context,'HPC_RC_${widget.Fname + '-' + date}.pdf');

                                if (Platform.isAndroid) {
                                  _permissionRequest();
                                  downloadFile(fullUrl, context,
                                      'HPC_Report_${widget.Fname}_$date.pdf');
                                } else if (Platform.isIOS) {
                                  _downloadFileIOS(fullUrl, context,
                                      'HPC_Report_${widget.Fname}_$date.pdf');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to download file'),
                                    ),
                                  );
                                }
                              }),
                            if (cbseCardVisible == 1)
                              _buildCard('CBSE Report Card', Icons.school,
                                  Colors.deepPurple, () {
                                print('URL: $durl');
                                String url = "";
                                switch (widget.cname) {
                                  case "9":
                                    url = durl +
                                        "index.php/assessment/pdf_download_class9_cbseformat"
                                            "?student_id=${widget.studentId}&class_id=${widget.classId}&login_type=P&acd_yr=${widget.academicYr}&short_name=${widget.shortName}";
                                    break;
                                  case "11":
                                    url = durl +
                                        "index.php/HSC/pdf_download_class11_cbseformat"
                                            "?student_id=${widget.studentId}&class_id=${widget.classId}&login_type=P&acd_yr=${widget.academicYr}&short_name=${widget.shortName}";
                                    break;
                                }

                                DateTime now = DateTime.now();
                                String date =
                                    DateFormat('yyyy-MM-dd').format(now);
                                // downloadFile(url, context, 'CBSE_RC_${widget.Fname + '-' + date}.pdf');

                                if (Platform.isAndroid) {
                                  _permissionRequest();
                                  downloadFile(url, context,
                                      'CBSE_RC_${widget.Fname + '-' + date}.pdf');
                                } else if (Platform.isIOS) {
                                  _downloadFileIOS(url, context,
                                      'CBSE_RC_${widget.Fname + '-' + date}.pdf');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to download file'),
                                    ),
                                  );
                                }
                              }),
                            if (viewReportCardVisible == 1)
                              _buildCard('View Report Card',
                                  Icons.insert_drive_file, Colors.teal, () {
                                String resultUrl = durl +
                                    "index.php/assessment/pdf_download" +
                                    "?student_id=${widget.studentId}&class_id=${widget.classId}&login_type=P&" +
                                    "acd_yr=${widget.academicYr}&short_name=${widget.shortName}";
                                DateTime now = DateTime.now();
                                String date =
                                    DateFormat('yyyy-MM-dd').format(now);
                                // downloadFile(resultUrl, context, 'RC_${widget.Fname + '-' + date}.pdf');

                                if (Platform.isAndroid) {
                                  _permissionRequest();
                                  downloadFile(resultUrl, context,
                                      'RC_${widget.Fname + '-' + date}.pdf');
                                } else if (Platform.isIOS) {
                                  _downloadFileIOS(resultUrl, context,
                                      'RC_${widget.Fname + '-' + date}.pdf');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to download file'),
                                    ),
                                  );
                                }
                              }),
                            if (resultChartVisible == 1)
                              _buildCard('View Result Chart', Icons.bar_chart,
                                  Colors.orange, () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultChart(
                                      studentId: widget.studentId,
                                      shortName: widget.shortName,
                                      academicYr: widget.academicYr,
                                      classId: widget.classId,
                                      secId: widget.secId,
                                      className: widget.className,
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),

                      const SizedBox(height: 7),

                      Expanded(
                        flex: 6,
                        child: examData.isEmpty
                            ? (error_msg_flag == true
                                ? SizedBox
                                    .shrink()
                                : Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          height: 150,
                                          width: 150,
                                          child: Image.asset(
                                            'assets/animations/nodata.gif',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'No Exam Result Available',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ))
                            : ListView.builder(
                                padding: const EdgeInsets.all(6),
                                itemCount: examData.length,
                                itemBuilder: (context, index) {
                                  final exam = examData[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: _buildExpandableCard(exam),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Function to show notification with the file path in the payload
  void showNotification(String title, String body, String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Download Notifications',
      channelDescription: 'Notification channel for file downloads',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformChannelSpecifics,
      payload: filePath, // Pass the file path as payload
    );
  }

  static Future<bool> _permissionRequest() async {
    PermissionStatus result = await Permission.storage.request();
    return result.isGranted;
  }

  Future<void> _downloadFileIOS(
      String url, BuildContext context, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();

    // Construct the full path for the downloaded file
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'download_channel',
      'Download Channel',
      channelDescription: 'Notifications for file downloads',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      onlyAlertOnce: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        await flutterLocalNotificationsPlugin.show(
          0,
          'Download Complete',
          'File saved to $filePath',
          platformChannelSpecifics,
          payload: filePath, // Pass the file path as payload
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'File Download Successfully. \n Find it in the Files/On My iPhone/EvolvU Smart School - Parent.'),
          ),
        );
      } else {}
    } catch (e) {
      await flutterLocalNotificationsPlugin.show(
        0,
        'Download Failed',
        'Failed to download file',
        platformChannelSpecifics,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
        ),
      );
    }
  }

  Future<void> downloadFile(
      String url, BuildContext context, String name) async {
    // Define the directory path where the file will be saved
    var directory =
        Directory("/storage/emulated/0/Download/Evolvuschool/Parent/Result");

    // Ensure the directory exists, create if necessary
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Combine directory path and file name to form the complete file path
    var filePath = "${directory.path}/$name";
    var file = File(filePath);

    // Show a loading indicator during the download
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Perform the file download
      var res = await http.get(Uri.parse(url));
      await file.writeAsBytes(
          res.bodyBytes); // Save the downloaded content to the file

      // Dismiss the loading indicator
      Navigator.of(context).pop();

      // Show a snackbar to indicate successful download
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'File downloaded successfully: Download/Evolvuschool/Parent/Result'),
        ),
      );

      // Show notification for successful download, with the file path as payload
      showNotification(
          'Download Complete', 'File saved to $filePath', filePath);
    } catch (e) {
      // Dismiss the loading indicator if there's an error
      Navigator.of(context).pop();

      // Show a snackbar on failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
        ),
      );

      // Show notification for failed download
      showNotification(
          'Download Failed', 'Error occurred while downloading the file.', '');
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Card Builder Function for the top grid
  Widget _buildCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return FractionallySizedBox(
      widthFactor: 1, // Full width of the grid item
      heightFactor: 0.90, // Reduce the height of the card
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Card background color
            borderRadius: BorderRadius.circular(16), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow color
                blurRadius: 10,
                offset: Offset(0, 4), // Shadow position
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Icon(icon, size: 45.sp, color: color),
              const SizedBox(height: 6),
              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 119, 105, 105),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build an expandable card dynamically
  Widget _buildExpandableCard(ExamResult exam) {
    return Card(
      child: ExpansionTile(
        title: Text(exam.examName),
        children: exam.details.map((detail) {
          return _buildResultRow(
            detail.subject,
            detail.markHeadings,
            getDisplayMark(detail.marksObtained, detail.highestMarks),
          );
        }).toList(),
      ),
    );
  }

  // Function to build each result row dynamically
  Widget _buildResultRow(String subject, String test, String score) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Subject Column with fixed width
          SizedBox(
            width: 90.w, // Fixed width for subject text
            child: Text(
              subject,
              style: TextStyle(color: Color.fromARGB(255, 34, 28, 28)),
              textAlign: TextAlign.left, // Align text to the left
              // overflow: TextOverflow.ellipsis, // Handle long text
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                test,
                style: TextStyle(fontWeight: FontWeight.w600),
                maxLines: 2,
                // Limit to 2 lines
                overflow: TextOverflow.ellipsis,
                // Show '...' if the text exceeds
                softWrap: true,
                // Allow wrapping
                textAlign: TextAlign.center, // Align heading to the center
              ),
            ),
          ),

          SizedBox(
            width: 50.w, // Fixed width for score text
            child: Text(
              score,
              style: TextStyle(color: Colors.blue),
              textAlign: TextAlign.right, // Align text to the right
            ),
          ),
        ],
      ),
    );
  }
}
