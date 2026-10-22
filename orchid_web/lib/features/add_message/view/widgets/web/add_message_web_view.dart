import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_fonts.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text.dart';
import '../../../data/message_choice.dart';
import 'web_add_message_header.dart';
import 'web_add_message_title.dart';
import 'web_message_empty_placeholder.dart';
import 'web_message_input_field.dart';
import 'web_message_option_cards.dart';
import 'web_validation_error_message.dart';

/// Desktop-first add a message page (>= 768px). Same colors, copy and
/// behaviour as the mobile screen — back header, prompt, Yes/No cards, the
/// message box (or the empty placeholder) and the continue button.
class AddMessageWebView extends StatelessWidget {
  final MessageChoice selectedChoice;
  final ValueChanged<MessageChoice> onChoiceSelected;
  final TextEditingController messageController;
  final int characterCount;
  final VoidCallback onMessageChanged;
  final String? validationError;
  final VoidCallback onContinue;
  final VoidCallback? onBackPressed;

  const AddMessageWebView({
    super.key,
    required this.selectedChoice,
    required this.onChoiceSelected,
    required this.messageController,
    required this.characterCount,
    required this.onMessageChanged,
    required this.validationError,
    required this.onContinue,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
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
                  WebAddMessageHeader(onBackPressed: onBackPressed),
                  const SizedBox(height: 24),
                  const WebAddMessageTitle(),
                  const SizedBox(height: 24),
                  WebMessageOptionCards(
                    selectedChoice: selectedChoice,
                    onChoiceSelected: onChoiceSelected,
                  ),
                  const SizedBox(height: 24),
                  if (selectedChoice == MessageChoice.yes)
                    _buildMessageInputSection()
                  else
                    const WebMessageEmptyPlaceholder(),
                  if (validationError != null) ...[
                    const SizedBox(height: 16),
                    WebValidationErrorMessage(message: validationError!),
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
                    onPressed: onContinue,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputSection() {
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
          controller: messageController,
          characterCount: characterCount,
          onChanged: (_) => onMessageChanged(),
        ),
      ],
    );
  }
}
