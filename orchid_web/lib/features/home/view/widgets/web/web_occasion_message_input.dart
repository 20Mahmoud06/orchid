import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import 'package:ORCHID/core/constants/app_colors.dart';
import 'package:ORCHID/core/constants/app_fonts.dart';

/// Message field and send action shown after an occasion is selected.
class WebOccasionMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const WebOccasionMessageInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.storeOutlineBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 6),
              const Icon(
                Ionicons.create_outline,
                size: 20,
                color: AppColors.storeIconMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: AppFonts.inriaSerif,
                    fontSize: 14,
                    color: AppColors.black,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      fontFamily: AppFonts.inriaSerif,
                      fontSize: 14,
                      color: AppColors.storeHintText,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onSend,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textFieldDarkerPink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Send',
                      style: TextStyle(
                        fontFamily: AppFonts.inriaSerif,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
