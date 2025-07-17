import 'package:evolvu/EvolvUSplashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import 'AcademicYearProvider.dart';
import 'Utils&Config/all_routs.dart';
import 'Utils&Config/api.dart';

class ApiService {
  // static const String apiUrl = 'https://api.aceventura.in/demo/evolvuURL/get_url';

  Future<String> fetchUrl() async {
    try {
      final response = await http.get(Uri.parse(GET_URL));

      if (response.statusCode == 200) {
        String responseBody = response.body;

        String baseUrl = responseBody.replaceAll('"', '');

        baseUrl = baseUrl.replaceAll(r'\/', '/');

        return baseUrl;
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error: $error');
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialized successfully");
  } on FirebaseException catch (e) {
    debugPrint("Firebase initialization failed: ${e.message}");
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
  );


  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle notification tap
      if (response.payload != null) {
        final filePath = response.payload!;
        final result = await OpenFile.open(filePath);

        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text('Failed to open file: ${result.message}'),
            ),
          );
        }
      }
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AcademicYearProvider()),
      ],
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(368, 892),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            onGenerateRoute: RouterConfigs.onGenerateRoutes,
            home: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink, Colors.blue],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SplashScreen(),
            ),
          );
        },
      ),
    );
  }
}

