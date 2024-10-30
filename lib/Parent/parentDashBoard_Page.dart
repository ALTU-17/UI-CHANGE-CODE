import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:evolvu/calender_Page.dart';
import 'package:evolvu/common/drawerAppBar.dart';
import 'package:evolvu/Parent/parentProfile_Page.dart';
import 'package:evolvu/Student/student_card.dart';
import 'package:evolvu/username_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../WebViewScreens/OnlineFeesPayment.dart';
import '../aboutUs.dart';
import '../changePasswordPage.dart';

class ParentDashBoardPage extends StatefulWidget {
  final String academic_yr;
  final String shortName;
   ParentDashBoardPage({required this.academic_yr,required this.shortName});

  @override
  // ignore: library_private_types_in_public_api
  _ParentDashBoardPageState createState() => _ParentDashBoardPageState();
}

String shortName = "";
String academic_yr = "";
String reg_id = "";
String user_id = "";
String url = "";
String durl = "";

String paymentUrl="";
String paymentUrlShare="";
String receiptUrl = "";
String smartchat_url="";
String username = "";


Future<void> _getSchoolInfo() async {
  final prefs = await SharedPreferences.getInstance();
  String? schoolInfoJson = prefs.getString('school_info');
  String? logUrls = prefs.getString('logUrls');
  print('logUrls====\\\\\: $logUrls');
  if (logUrls != null) {
    try {
      Map<String, dynamic> logUrlsparsed = json.decode(logUrls);
      print('logUrls====\\\\\11111: $logUrls');

      user_id = logUrlsparsed['user_id'];
      academic_yr = logUrlsparsed['academic_yr'];
      reg_id = logUrlsparsed['reg_id'];

      print('academic_yr ID: $academic_yr');
      print('reg_id: $reg_id');
    } catch (e) {
      print('Error parsing school info: $e');
    }
  } else {
    print('School info not found in SharedPreferences.');
  }

  if (schoolInfoJson != null) {
    try {
      Map<String, dynamic> parsedData = json.decode(schoolInfoJson);

      shortName = parsedData['short_name'];
      url = parsedData['url'];
      durl = parsedData['project_url'];

      fetchDashboardData(url);

      print('Short Name: $shortName');
      print('URL: $url');
      print('URL: $durl');
    } catch (e) {
      print('Error parsing school info: $e');
    }
  } else {
    print('School info not found in SharedPreferences.');
  }
}

Future<void> fetchDashboardData(String url) async {
  final url1 = Uri.parse(url +'show_icons_parentdashboard_apk');
  // print('Receipt URL: $shortName');

  try {
    final response = await http.post(url1,
      body: {'short_name': shortName},
    );

    if (response.statusCode == 200) {
      print('response.body URL: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      // Extract the required fields
      receiptUrl = data['receipt_url'];
      paymentUrl = data['payment_url'];
      smartchat_url = data['smartchat_url'];
      String ALLOWED_URI_CHARS = "@#&=*+-_.,:!?()/~'%";

      String URi_username = customUriEncode(username, ALLOWED_URI_CHARS);
      username = username;

      String secretKey = 'aceventura@services';

      String encryptedUsername = encryptUsername(username, secretKey);

      paymentUrlShare = paymentUrl + "?reg_id=" + reg_id +
          "&academic_yr=" + academic_yr +  "&user_id=" + URi_username + "&encryptedUsername=" + encryptedUsername +"&short_name=" + shortName;

      print('Encrypted Username: $paymentUrlShare');
      print('Encrypted Username: $encryptedUsername');
      // Use these values as needed

      print('Receipt URL: $receiptUrl');
      print('Payment URL: $paymentUrl');
      print('smartchat_url : $smartchat_url');

      // You can store these values in variables or use them directly
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

String encryptUsername(String username, String secretKey) {
  // Combine the username and secretKey
  String combined = username + secretKey;

  // Convert the combined string to bytes
  List<int> bytes = utf8.encode(combined);

  // Perform SHA1 encryption
  Digest sha1Result = sha1.convert(bytes);

  // Return the encrypted value as a hexadecimal string
  return sha1Result.toString();
}

String customUriEncode(String input, String allowedChars) {
  final StringBuffer encoded = StringBuffer();

  for (int i = 0; i < input.length; i++) {
    final String char = input[i];
    if (allowedChars.contains(char)) {
      encoded.write(char);  // Allow the character as-is
    } else {
      // Percent-encode the character
      final List<int> bytes = utf8.encode(char);
      for (final int byte in bytes) {
        encoded.write('%${byte.toRadixString(16).toUpperCase()}');
      }
    }
  }

  return encoded.toString();
}

class _ParentDashBoardPageState extends State<ParentDashBoardPage> {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _getSchoolInfo();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentCard(
        onTap: (int index) {
          setState(() {
            pageIndex = index;
          });
        },
      ),
      const CalenderPage(),
      ParentProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          "${widget.shortName} EvolvU Smart Parent App(${widget.academic_yr})",
          style: TextStyle(fontSize: 14.sp, color: Colors.white),
        ),
        backgroundColor: Colors.pink,
        elevation: 0,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: Icon(Icons.menu, color: Colors.red),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomPopup();
              },
            );
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink, Colors.blue],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Page content
          pages[pageIndex],
        ],
      ),
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 75.h,
      decoration: const BoxDecoration(
          //color: Color.fromARGB(66, 165, 152, 152),
          ),
      child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  enableFeedback: true,
                  onPressed: () {
                    setState(() {
                      pageIndex = 0;
                    });
                  },
                  icon: Icon(
                    Icons.dashboard,
                    color: pageIndex == 0
                        ? Color.fromARGB(255, 236, 108, 99)
                        : Colors.white,
                    size: 30,
                  ),
                ),
                Text('Dashboard', style: TextStyle(color: Colors.white)),
              ],
            ),
            Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 1;
                    });
                  },
                  icon: Icon(
                    Icons.calendar_month,
                    color: pageIndex == 1
                        ? Color.fromARGB(255, 236, 108, 99)
                        : Colors.white,
                    size: 30,
                  ),
                ),
                Text('Evants', style: TextStyle(color: Colors.white)),
              ],
            ),
            Column(
              //mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    setState(() {
                      pageIndex = 2;
                    });
                  },
                  icon: Icon(
                    Icons.person,
                    color: pageIndex == 2
                        ? Color.fromARGB(255, 236, 108, 99)
                        : Colors.white,
                    size: 30,
                  ),
                ),
                Text('Profile', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CardItem {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  CardItem({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  });
}

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // User must tap a button
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Logout Confirmation',
          style: TextStyle(fontSize: 22.sp),
        ),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: ListBody(
              children: <Widget>[
                Text('Do you want to logout?',
                    style: TextStyle(fontSize: 16.sp,color: Colors.grey)),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
          ),
          TextButton(
            child: Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
              logout(context); // Call the logout function
            },
          ),
        ],
      );
    },
  );
}

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // Clear all stored data

  // Optionally show a toast message
  Fluttertoast.showToast(
    msg: 'Logged out successfully!',
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.CENTER,
  );

  // Navigate to the login screen
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => UserNamePage()),
        (Route<dynamic> route) => false,
  );
}


class CustomPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<CardItem> cardItems = [

      CardItem(
        imagePath:'assets/parents.png',
        title: 'My Profile',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ParentProfilePage()),
          );
        },
      ),

      CardItem(
        imagePath: 'assets/logout1.png',
        title: 'LogOut',
        onTap: () {
          showLogoutConfirmationDialog(context);
        },
      ),

      CardItem(
        imagePath: 'assets/cashpayment.png',
        title: 'Fees Payment',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentWebview(
                  regId: reg_id,paymentUrlShare:paymentUrlShare,receiptUrl:receiptUrl,shortName: shortName,academicYr: academic_yr),
            ),
          );
        },
      ),
      CardItem(
        imagePath: 'assets/password.png',
        title: 'Change Password',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChangePasswordPage(academicYear:academic_yr,shortName: shortName, userID: user_id, url: url,)),
          );
        },
      ),

      CardItem(
        imagePath: 'assets/ace.png',
        title: 'About Us',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AboutUsPage(academic_yr:academic_yr,shortName: shortName)),
          );
        },
      ),


      // Add the new Share App card here
      CardItem(
        imagePath: 'assets/share.png', // Add an appropriate icon for sharing
        title: 'Share App',
        onTap: () {
          Share.share(
            'Download Evolvu: Smart Schooling App https://play.google.com/store/apps/details?id=in.aceventura.evolvuschool', // Replace with your app link
            subject: 'Parent App!',
          );
        },
      ),
      // Add more CardItems here...
    ];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.only(top: 65, bottom: 0, left: 0, right: 0),
      child: Stack(
        clipBehavior: Clip.none,
        // This allows the Positioned widget to go outside the Stack's bounds
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 245, 241, 241),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: cardItems.map((cardItem) {
                  return InkWell(
                    onTap: cardItem.onTap,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(cardItem.imagePath, width: 40, height: 40),
                        SizedBox(height: 8),
                        Text(
                          cardItem.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Positioned(
            top: -50, // Adjust this value to place the button above the dialog
            right: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.close, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
