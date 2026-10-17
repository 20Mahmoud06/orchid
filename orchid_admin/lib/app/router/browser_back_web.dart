import 'package:web/web.dart' as web;

bool browserBack() {
  web.window.history.back();
  return true;
}
