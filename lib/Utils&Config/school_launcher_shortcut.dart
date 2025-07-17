import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SchoolLauncherShortcut {
  static const MethodChannel _channel =
  MethodChannel('evolvu.dynamic_launcher');

  static Future<bool> setSchoolShortcut({
    required String logoUrl,
    required String schoolName,
  }) async {
    try {
      debugPrint('School shortcut logo URL: $logoUrl');

      final uri = Uri.tryParse(logoUrl);

      if (uri == null) {
        debugPrint('Invalid logo URL');
        return false;
      }

      final response = await http.get(uri);

      debugPrint(
        'School logo response: ${response.statusCode}',
      );

      if (response.statusCode != 200) {
        debugPrint(
          'Failed to download school logo',
        );
        return false;
      }

      if (response.bodyBytes.isEmpty) {
        debugPrint(
          'School logo is empty',
        );
        return false;
      }

      final result = await _channel.invokeMethod(
        'setSchoolShortcut',
        {
          'schoolName': schoolName,
          'logoBytes': response.bodyBytes,
        },
      );

      debugPrint(
        'School shortcut result: $result',
      );

      return result == true;
    } on PlatformException catch (e) {
      debugPrint(
        'PlatformException while setting shortcut: ${e.code} ${e.message}',
      );
      return false;
    } catch (e, st) {
      debugPrint(
        'Error setting school shortcut: $e',
      );
      debugPrintStack(stackTrace: st);
      return false;
    }
  }
}