import 'package:evolvu/Parent/parentDashBoard_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ParentFeedbackPage extends StatefulWidget {
  final String studentId;
  final String regId;
  final String academicYr;

  const ParentFeedbackPage({
    Key? key,
    required this.studentId,
    required this.regId,
    required this.academicYr,
  }) : super(key: key);

  @override
  _ParentFeedbackPageState createState() => _ParentFeedbackPageState();
}

class _ParentFeedbackPageState extends State<ParentFeedbackPage> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  final String baseUrl = teacherapk_url + "assessment/parent_feedback_apk/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 60.h,
        title: Text(
          'Parent Observation for holistic\n                 Report Card',
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 100.h),
                Expanded(
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: """
                          <!DOCTYPE html>
                          <html>
                          <head>
                              <meta name="viewport" content="width=device-width, initial-scale=1.0">
                              <style>
                                body {
                                  margin: 0;
                                  padding: 0;
                                  font-family: Arial, sans-serif;
                                  background: linear-gradient(to bottom, pink, blue);
                                  min-height: 100vh;
                                }
                                .loading-container {
                                  display: flex;
                                  justify-content: center;
                                  align-items: center;
                                  height: 100vh;
                                  color: white;
                                  font-size: 18px;
                                }
                                .form-container {
                                  background: white;
                                  margin: 20px;
                                  padding: 20px;
                                  border-radius: 10px;
                                  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                                }
                              </style>
                          </head>
                          <body onload="document.forms[0].submit()">
                              <div class="loading-container">
                                <div>Loading Parent's Observation Form...</div>
                              </div>
                              <form id="myForm" method="POST" action="$baseUrl" enctype="multipart/form-data">
                                  <input type="hidden" name="student_id" value="${widget.studentId}" />
                                  <input type="hidden" name="reg_id" value="${widget.regId}" />
                                  <input type="hidden" name="academic_yr" value="${widget.academicYr}" />
                                  <input type="hidden" name="short_name" value="${shortName}" />
                              </form>
                          </body>
                          </html>
                      """,
                      baseUrl: WebUri(baseUrl),
                    ),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        javaScriptEnabled: true,
                        useOnDownloadStart: true,
                        mediaPlaybackRequiresUserGesture: false,
                        transparentBackground: true,
                      ),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                        allowFileAccess: true, // Required for file picker!
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      ),
                    ),
                    onWebViewCreated: (InAppWebViewController controller) {
                      _webViewController = controller;
                    },

                    onLoadStart: (controller, url) {
                      setState(() => _isLoading = true);
                    },
                    onLoadStop: (controller, url) {
                      setState(() => _isLoading = false);

                      if (url != null && url.toString().contains("upload_success=true")) {
                        // Notify user upload succeeded
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Upload Successful!")),
                        );
                        // Optionally navigate away or refresh UI
                      }
                    },

                    onLoadError: (controller, url, code, message) {
                      setState(() => _isLoading = false);
                    },
                    androidOnPermissionRequest: (controller, origin, resources) async {
                      return PermissionRequestResponse(
                        resources: resources,
                        action: PermissionRequestResponseAction.GRANT,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
