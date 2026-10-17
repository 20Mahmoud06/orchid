import 'package:flutter/material.dart';

import '../../../../shared/widgets/app_snack_bar.dart';

/// Shows the floating profile snackbar using the shared Orchid styling.
void showProfileSnack(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  showAppSnackBar(context, message, isError: isError);
}
