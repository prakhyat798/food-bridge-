import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunicationService {
  /// Trigger native phone dialer with provided number
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: sanitizedNumber);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      } else {
        debugPrint('[CommunicationService] Cannot launch phone dialer for: $sanitizedNumber');
        return false;
      }
    } catch (e) {
      debugPrint('[CommunicationService] Error launching phone call: $e');
      return false;
    }
  }

  /// Trigger native SMS app with recipient number and optional pre-filled message
  static Future<bool> sendSms(String phoneNumber, {String? body}) async {
    final sanitizedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(
      scheme: 'sms',
      path: sanitizedNumber,
      queryParameters: body != null ? {'body': body} : null,
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return true;
      } else {
        debugPrint('[CommunicationService] Cannot launch SMS app for: $sanitizedNumber');
        return false;
      }
    } catch (e) {
      debugPrint('[CommunicationService] Error sending SMS: $e');
      return false;
    }
  }
}
