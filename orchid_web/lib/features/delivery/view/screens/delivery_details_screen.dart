import 'package:flutter/material.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../features/auth/cubit/auth_cubit.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../widgets/delivery_details_mobile_view.dart';
import '../widgets/web/delivery_details_web_view.dart';

/// Delivery details screen matching the Orchid Figma design.
class DeliveryDetailsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onContinue;

  const DeliveryDetailsScreen({super.key, this.onBackPressed, this.onContinue});

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = AuthCubit.instance.userProfile;
    if (profile != null) {
      _fullNameController.text = profile.username ?? '';
      _phoneController.text = profile.phone ?? '';
      _whatsappController.text = profile.whatsapp ?? '';
      _locationController.text = profile.address ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    CheckoutCubit.instance.setDeliveryDetails(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      whatsapp: _whatsappController.text,
      location: _locationController.text,
      notes: _notesController.text,
    );
    Navigator.pushNamed(context, AppRoutes.orderSummary);
  }

  @override
  Widget build(BuildContext context) {
    final onContinue = widget.onContinue ?? _handleContinue;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return DeliveryDetailsWebView(
            formKey: _formKey,
            fullNameController: _fullNameController,
            phoneController: _phoneController,
            whatsappController: _whatsappController,
            locationController: _locationController,
            notesController: _notesController,
            onBackPressed: widget.onBackPressed,
            onContinue: onContinue,
          );
        }
        return DeliveryDetailsMobileView(
          formKey: _formKey,
          fullNameController: _fullNameController,
          phoneController: _phoneController,
          whatsappController: _whatsappController,
          locationController: _locationController,
          notesController: _notesController,
          onBackPressed: widget.onBackPressed,
          onContinue: onContinue,
        );
      },
    );
  }
}
