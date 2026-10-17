import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../features/checkout/cubit/checkout_cubit.dart';
import '../../../../core/router/app_routes.dart';
import '../../../cart/cubit/cart_cubit.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text.dart';
import '../../data/message_choice.dart';
import '../widgets/add_message_header.dart';
import '../widgets/add_message_title.dart';
import '../widgets/message_empty_placeholder.dart';
import '../widgets/message_input_field.dart';
import '../widgets/message_option_cards.dart';
import '../widgets/validation_error_message.dart';
import '../widgets/web/web_add_message_widgets.dart';

/// Add a message screen matching the Orchid Figma design.
class AddMessageScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onContinue;

  /// When set, the screen edits the note of that single cart line instead of
  /// the order-level message, and simply returns when done.
  final String? cartItemId;

  const AddMessageScreen({
    super.key,
    this.onBackPressed,
    this.onContinue,
    this.cartItemId,
  });

  @override
  State<AddMessageScreen> createState() => _AddMessageScreenState();
}

class _AddMessageScreenState extends State<AddMessageScreen> {
  MessageChoice _selectedChoice = MessageChoice.yes;
  final TextEditingController _messageController = TextEditingController();
  int _characterCount = 0;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final savedMessage = _initialMessage();
    if (savedMessage.isNotEmpty) {
      _messageController.text = savedMessage;
      _selectedChoice = MessageChoice.yes;
      _characterCount = savedMessage.length;
    }
    _messageController.addListener(_updateCharacterCount);
  }

  /// Per-line note when editing a cart item, otherwise the order message.
  String _initialMessage() {
    if (widget.cartItemId != null) {
      for (final item in CartCubit.instance.items) {
        if (item.id == widget.cartItemId) {
          return (item.message ?? '').trim();
        }
      }
      return '';
    }
    return CheckoutCubit.instance.messageText.trim();
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateCharacterCount);
    _messageController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() => _characterCount = _messageController.text.length);
  }

  void _handleChoiceSelection(MessageChoice choice) {
    setState(() {
      _selectedChoice = choice;
      _validationError = null;
    });
  }

  void _handleContinue() {
    // Validate if "Yes" is selected and message is empty or only spaces
    if (_selectedChoice == MessageChoice.yes) {
      final trimmedText = _messageController.text.trim();
      if (trimmedText.isEmpty) {
        setState(() {
          _validationError = 'Please enter a message to continue';
        });
        return;
      }
    }

    // Clear any validation error
    setState(() {
      _validationError = null;
    });

    // Proceed with the action
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else if (widget.cartItemId != null) {
      CartCubit.instance.setItemMessage(
        widget.cartItemId!,
        _selectedChoice == MessageChoice.yes ? _messageController.text : '',
      );
      Navigator.maybePop(context);
    } else {
      CheckoutCubit.instance.setMessage(
        hasMessage: _selectedChoice == MessageChoice.yes,
        text: _messageController.text,
      );
      Navigator.pushNamed(context, AppRoutes.deliveryDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop-first web presentation (>= 768px). Narrow viewports keep the
        // untouched Orchid mobile layout.
        if (constraints.maxWidth >= 768) {
          return _buildWeb(context);
        }
        return _buildMobile(context);
      },
    );
  }

  /// Desktop-first add a message page (>= 768px). Same colors, copy and
  /// behaviour as the mobile screen — back header, prompt, Yes/No cards, the
  /// message box (or the empty placeholder) and the continue button.
  Widget _buildWeb(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebAddMessageHeader(onBackPressed: widget.onBackPressed),
                  const SizedBox(height: 24),
                  const WebAddMessageTitle(),
                  const SizedBox(height: 24),
                  WebMessageOptionCards(
                    selectedChoice: _selectedChoice,
                    onChoiceSelected: _handleChoiceSelection,
                  ),
                  const SizedBox(height: 24),
                  if (_selectedChoice == MessageChoice.yes)
                    _buildWebMessageInputSection()
                  else
                    const WebMessageEmptyPlaceholder(),
                  if (_validationError != null) ...[
                    const SizedBox(height: 16),
                    WebValidationErrorMessage(message: _validationError!),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    label: 'continue',
                    fontFamily: AppFonts.goudyOldStyle,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.primary,
                    backgroundColor: AppColors.incrementButton,
                    height: 52,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [],
                    onPressed: _handleContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the message input section when "Yes" is selected (web).
  Widget _buildWebMessageInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          text: 'Your Message',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16,
          textColor: AppColors.darkGreen,
        ),
        const SizedBox(height: 10),
        WebMessageInputField(
          controller: _messageController,
          characterCount: _characterCount,
          onChanged: (_) {
            _updateCharacterCount();
            if (_validationError != null) {
              setState(() {
                _validationError = null;
              });
            }
          },
        ),
      ],
    );
  }

  /// Mobile layout (unchanged).
  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        AddMessageHeader(
                          onBackPressed: widget.onBackPressed,
                        ),
                        SizedBox(height: 20.h),

                        // Title
                        const AddMessageTitle(),
                        SizedBox(height: 20.h),

                        // Option cards
                        MessageOptionCards(
                          selectedChoice: _selectedChoice,
                          onChoiceSelected: _handleChoiceSelection,
                        ),
                        SizedBox(height: 20.h),

                        // Dynamic content area (expands to fill available space)
                        Expanded(
                          child: _selectedChoice == MessageChoice.yes
                              ? _buildMessageInputSection()
                              : const MessageEmptyPlaceholder(),
                        ),

                        // Validation error message
                        if (_validationError != null) ...[
                          SizedBox(height: 12.h),
                          ValidationErrorMessage(
                            message: _validationError!,
                          ),
                        ],

                        // Continue button
                        SizedBox(height: 10.h),
                        CustomButton(
                          label: 'continue',
                          fontFamily: AppFonts.goudyOldStyle,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w400,
                          textColor: AppColors.primary,
                          backgroundColor: AppColors.incrementButton,
                          height: 52.h,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: const [],
                          onPressed: _handleContinue,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds the message input section when "Yes" is selected
  Widget _buildMessageInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'Your Message',
          fontFamily: AppFonts.goudyOldStyle,
          fontSize: 16.sp,
          textColor: AppColors.darkGreen,
        ),
        SizedBox(height: 10.h),
        MessageInputField(
          controller: _messageController,
          characterCount: _characterCount,
          onChanged: (_) {
            _updateCharacterCount();
            // Clear validation error when user starts typing
            if (_validationError != null) {
              setState(() {
                _validationError = null;
              });
            }
          },
        ),
      ],
    );
  }
}