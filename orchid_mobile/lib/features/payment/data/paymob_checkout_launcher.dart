import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Paymob's Unified Checkout page.
///
/// Mobile uses an in-app browser (Custom Tabs / SFSafariViewController) and
/// falls back to the external browser. Web opens a new tab so the Flutter app
/// stays alive and can poll the backend when the customer returns.
Future<bool> launchPaymobCheckout(String checkoutUrl) async {
  final uri = Uri.tryParse(checkoutUrl);
  if (uri == null || uri.scheme != 'https') return false;

  try {
    if (kIsWeb) {
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    }

    final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    if (opened) return true;
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
