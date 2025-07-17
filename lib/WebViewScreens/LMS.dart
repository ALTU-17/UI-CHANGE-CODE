// LMSWebViewScreen.dart

import 'dart:convert';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:http/http.dart' as http;

class LMSWebViewScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String past_que_papers_url;

  const LMSWebViewScreen({
    super.key,
    required this.studentId,
    required this.past_que_papers_url,
  });

  @override
  ConsumerState<LMSWebViewScreen> createState() => _LMSWebViewScreenState();
}

class _LMSWebViewScreenState extends ConsumerState<LMSWebViewScreen> {
  WebViewController? controller;
  bool loading = true;
  String? errorMessage;
  double progress = 0;
  String? ssoToken;
  String? sessionId;
  bool _isFirstLoad = true;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    _initWebView();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await getLaravelToken();
      print('past_que_papers_url body: ${widget.past_que_papers_url}');
      print('token body: ${token}');
      print('student body: ${widget.studentId}');

      if (token == null) return;

      final uri = Uri.parse(widget.past_que_papers_url);

      final newUri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          'token': token,
          'student_id': widget.studentId,
        },
      );

      debugPrint("🚀 Loading: $newUri");

      controller?.loadRequest(newUri);
    });
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params);

    if (controller!.platform is AndroidWebViewController) {
      final androidController = controller!.platform as AndroidWebViewController;

      AndroidWebViewController.enableDebugging(true);
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // // 🔥 IMPORTANT: Allow mixed content and file access
      // androidController.setMixedContentMode(MixedContentMode.compatibilityMode);
      // androidController.setAllowFileAccess(true);
      // androidController.setAllowContentAccess(true);
      //
      // // 🔥 CRITICAL: Enable DOM storage and database
      // androidController.setDomStorageEnabled(true);
      // androidController.setDatabaseEnabled(true);
      //
      // // 🔥 Enable support for multiple windows if needed
      // androidController.setSupportMultipleWindows(true);
      //
      // // 🔥 Set user agent to Chrome for better compatibility
      // androidController.setUserAgentString(
      //     'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36'
      // );


      // File chooser callback
      androidController.setOnShowFileSelector(
            (params) async {
          debugPrint("📂 File chooser triggered");
          final result = await FilePicker.platform.pickFiles(
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            final path = result.files.single.path;
            if (path != null) {
              return [Uri.file(path).toString()];
            }
          }
          return [];
        },
      );
    }

    controller!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final url = request.url.toLowerCase();
            debugPrint("➡ Navigation attempt: $url");

            // 🔥 Intercept ALL media files
            if (url.contains("/media/") ||
                url.endsWith(".pdf") ||
                url.endsWith(".doc") ||
                url.endsWith(".docx") ||
                url.endsWith(".xls") ||
                url.endsWith(".xlsx") ||
                url.endsWith(".png") ||
                url.endsWith(".jpg")) {

              debugPrint("📎 File detected → Opening externally");

              await launchUrl(
                Uri.parse(request.url),
                mode: LaunchMode.externalApplication,
              );

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onProgress: (p) {
            setState(() => progress = p / 100);
          },
          onPageStarted: (url) {
            debugPrint("🌐 Loading: $url");
            setState(() {
              loading = true;
              errorMessage = null;
            });
          },
          onPageFinished: (url) {
            debugPrint("✅ Loaded: $url");
            setState(() => loading = false);
            _isFirstLoad = false;

            // 🔥 Inject JavaScript to handle PDF and file downloads
            _injectDownloadHandler();
          },
          onWebResourceError: (error) {
            debugPrint("❌ WebView error: ${error.description}");

            // 🔥 Special handling for ORB errors
            if (error.description.contains("ERR_BLOCKED_BY_ORB")) {
              debugPrint("⚠️ ORB blocking detected, trying alternative loading method...");
              _handleORBError();
            }
            // Handle other errors
            else if (error.errorCode == -2 || error.description.contains("ERR_FAILED")) {
              debugPrint("⚠️ Connection failed, will retry automatically...");
              if (_isFirstLoad) {
                _retryTimer?.cancel();
                _retryTimer = Timer(const Duration(milliseconds: 1500), () {
                  if (mounted && loading) {
                    debugPrint("🔄 Auto-retrying after ERR_FAILED...");
                    _loadLMS();
                  }
                });
              } else {
                _showError("Connection failed. Please try again.");
              }
            } else {
              _showError(error.description);
            }
          },
        ),
      );
  }

  /// 🔥 Inject JavaScript to handle PDF downloads and file openings
  Future<void> _injectDownloadHandler() async {
    if (controller == null) return;

    const script = '''
    (function() {
      // Function to force download a file
      function forceDownload(url, filename) {
        // Create a hidden anchor element
        const link = document.createElement('a');
        link.href = url;
        link.download = filename || url.split('/').pop() || 'download.pdf';
        link.target = '_blank';
        link.style.display = 'none';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        // Fallback: open in new window if download doesn't work
        setTimeout(() => {
          window.open(url, '_blank');
        }, 500);
      }
      
      // Handle all PDF links
      document.addEventListener('click', function(e) {
        const link = e.target.closest('a');
        if (!link || !link.href) return;
        
        const url = link.href.toLowerCase();
        
        // Check if it's a PDF or document
        if (url.includes('.pdf') || 
            url.includes('download') || 
            url.includes('document') ||
            url.includes('question_papers')) {
          
          e.preventDefault();
          e.stopPropagation();
          
          console.log('📄 PDF link clicked:', url);
          
          // Extract filename from URL
          const filename = url.split('/').pop() || 'document.pdf';
          
          // Try to force download
          forceDownload(link.href, filename);
          
          return false;
        }
      }, true);
      
      // Also handle view buttons that might not be direct links
      const viewButtons = document.querySelectorAll('button:contains("View"), a:contains("View")');
      viewButtons.forEach(button => {
        button.addEventListener('click', function(e) {
          e.preventDefault();
          const pdfUrl = this.href || this.getAttribute('data-url') || this.getAttribute('data-pdf');
          if (pdfUrl) {
            forceDownload(pdfUrl, 'document.pdf');
          }
        });
      });
      
      console.log('✅ PDF download handler installed');
    })();
  ''';

    await controller!.runJavaScript(script);
  }

  /// 🔥 Handle ORB errors by reloading with different settings
  Future<void> _handleORBError() async {
    try {
      if (controller == null) return;

      // Get current URL
      final currentUrl = await controller!.currentUrl();
      if (currentUrl == null) return;

      debugPrint("🔄 Attempting to reload with ORB bypass: $currentUrl");

      // Try to load the resource directly using JavaScript
      const bypassScript = '''
      (function() {
        // Try to fetch the resource with no-cors mode
        const links = document.querySelectorAll('a[href*=".pdf"], a[href*="download"]');
        links.forEach(link => {
          link.addEventListener('click', function(e) {
            e.preventDefault();
            const url = this.href;
            
            // Use fetch with no-cors to bypass ORB
            fetch(url, { 
              mode: 'no-cors',
              credentials: 'include'
            }).then(() => {
              // If fetch succeeds, open in new window
              window.open(url, '_blank');
            }).catch(err => {
              console.log('Fetch failed, trying direct navigation');
              window.location.href = url;
            });
          });
        });
      })();
    ''';

      await controller!.runJavaScript(bypassScript);

    } catch (e) {
      debugPrint("❌ Error handling ORB: $e");
    }
  }

  Future<String?> getLaravelToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('laravel_token');
  }

  Future<void> _loadLMS() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
        progress = 0;
      });

      debugPrint("\n========== LMS LOGIN ==========");

      final token = await getLaravelToken();
      if (token == null || token.isEmpty) {
        throw Exception("Please login first");
      }

      final ssoUrl = "https://ednova.evolvu.in/sso/api/school/lms-sso";

      debugPrint("🌐 API URL: $ssoUrl");

      final response = await http.post(
        Uri.parse(ssoUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "User-Agent": "Flutter App",
        },
        body: jsonEncode({
          "student_id": widget.studentId,
        }),
      );

      debugPrint("📡 Status: ${response.statusCode}");
      debugPrint("📦 Body: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception("SSO failed with status: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);

      if (data["success"] != true) {
        throw Exception("Authentication failed");
      }

      final lmsUrl = data["lms_url"] as String;
      debugPrint("🔗 LMS URL from API: $lmsUrl");

      // Parse the URL to extract parameters
      final uri = Uri.parse(lmsUrl);
      ssoToken = uri.queryParameters['sso_token'];
      sessionId = uri.queryParameters['session_id'];

      // IMPORTANT: First clear ALL cookies
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
      debugPrint("🧹 Cookies cleared");

      // Small delay after clearing cookies
      await Future.delayed(const Duration(milliseconds: 300));

      // Set cookies with proper attributes
      if (sessionId != null && sessionId!.isNotEmpty) {
        await cookieManager.setCookie(
          WebViewCookie(
            name: "sessionid",
            value: sessionId!,
            domain: ".ednova.evolvu.in",
            path: "/",
          ),
        );
        debugPrint("✅ Session cookie set: $sessionId");
      }

      if (ssoToken != null && ssoToken!.isNotEmpty) {
        await cookieManager.setCookie(
          WebViewCookie(
            name: "sso_token",
            value: ssoToken!,
            domain: ".ednova.evolvu.in",
            path: "/",
          ),
        );
        debugPrint("✅ SSO token cookie set");
      }

      // Also set a cookie for the user if needed
      if (data["user"] != null) {
        await cookieManager.setCookie(
          WebViewCookie(
            name: "lms_user",
            value: data["user"],
            domain: ".ednova.evolvu.in",
            path: "/",
          ),
        );
        debugPrint("✅ User cookie set");
      }

      // CRITICAL: Wait longer for cookies to be properly stored
      await Future.delayed(const Duration(milliseconds: 1000));

      // Build the final URL
      final Map<String, String> queryParams = {
        if (ssoToken != null) 'sso_token': ssoToken!,
        'student_id': widget.studentId,
      };

      final finalUri = Uri(
        scheme: 'https',
        host: 'ednova.evolvu.in',
        path: '/dashboard/',
        queryParameters: queryParams,
      );

      debugPrint("🚀 Opening WebView: $finalUri");

      // First, try to load a test URL to verify cookies
      // This helps establish the connection
      try {
        // await controller!.loadRequest(Uri.parse('https://ednova.evolvu.in/health-check'));
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        debugPrint("⚠️ Health check failed but continuing: $e");
      }

      // Now load the actual dashboard
      await controller!.loadRequest(finalUri);

    } catch (e) {
      debugPrint("❌ ERROR: $e");
      _showError(e.toString());
    }
  }

  void _showError(String msg) {
    if (mounted) {
      setState(() {
        errorMessage = msg;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "LMS Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 208, 28, 127),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (errorMessage == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  loading = true;
                  errorMessage = null;
                  progress = 0;
                  _isFirstLoad = true;
                });
                _loadLMS();
              },
            ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (controller != null && errorMessage == null)
            WebViewWidget(controller: controller!),


          if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 70,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to Load LMS',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!.contains("ERR_FAILED")
                          ? "Connection failed. This might be a temporary issue."
                          : errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          errorMessage = null;
                          loading = true;
                          _isFirstLoad = true;
                        });
                        _loadLMS();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 208, 28, 127),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),


          if (loading && errorMessage == null)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 208, 28, 127),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      progress > 0
                          ? "Loading ${(progress * 100).toInt()}%"
                          : "Connecting to LMS...",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isFirstLoad
                          ? "Initializing secure connection..."
                          : "Please wait while we authenticate",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}