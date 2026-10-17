import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/widgets/message_option_card.dart';
import '../../data/message_choice.dart';

class MessageOptionCards extends StatelessWidget {
  final MessageChoice selectedChoice;
  final ValueChanged<MessageChoice> onChoiceSelected;

  const MessageOptionCards({
    super.key,
    required this.selectedChoice,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MessageOptionCard(
          iconPath: AppAssets.speechBubbleIcon,
          label: 'Yes, add a message.',
          isSelected: selectedChoice == MessageChoice.yes,
          isEnabledStyle: true,
          onTap: () => onChoiceSelected(MessageChoice.yes),
        ),
        SizedBox(height: 10.h),
        MessageOptionCard(
          iconPath: AppAssets.noSpeechBubbleIcon,
          label: 'No, thanks.',
          isSelected: selectedChoice == MessageChoice.no,
          isEnabledStyle: false,
          onTap: () => onChoiceSelected(MessageChoice.no),
        ),
      ],
    );
  }
}