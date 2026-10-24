import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../time/date_range.dart';
import '../time/egypt_time.dart';
import 'custom_text.dart';

class DateRangeSelector extends StatelessWidget {
  const DateRangeSelector({
    super.key,
    required this.dateRange,
    required this.onChanged,
    required this.isLoading,
  });

  final DateRange dateRange;
  final ValueChanged<DateRange> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateRangePreset>(
      tooltip: 'Select date range',
      position: PopupMenuPosition.under,
      elevation: 3,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      onSelected: (preset) async {
        await _handleSelection(context, preset);
      },
      itemBuilder: (context) {
        return [
          for (final preset in DateRangePreset.values)
            PopupMenuItem<DateRangePreset>(
              value: preset,
              height: 42,
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: preset == dateRange.preset
                        ? const Icon(
                            Icons.check_rounded,
                            size: 17,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  CustomText(
                    text: preset.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: preset == dateRange.preset
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.softLime,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: dateRange.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  CustomText(
                    text: dateRange.rangeSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSelection(
    BuildContext context,
    DateRangePreset preset,
  ) async {
    if (preset == DateRangePreset.custom) {
      await _pickCustomRange(context);
      return;
    }

    onChanged(DateRange.resolve(preset, now: nowInEgypt()));
  }

  Future<void> _pickCustomRange(BuildContext context) async {
    final now = nowInEgypt();
    final today = DateTime(now.year, now.month, now.day);
    final rangeStart = dateRange.start;
    final rangeEnd = dateRange.endInclusive;

    final initialRange = rangeStart != null && rangeEnd != null
        ? DateTimeRange(start: rangeStart, end: rangeEnd)
        : DateTimeRange(
            start: today.subtract(const Duration(days: 6)),
            end: today,
          );

    final earliest = DateTime(2020);
    final firstDate = rangeStart != null && rangeStart.isBefore(earliest)
        ? rangeStart
        : earliest;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: today,
      initialDateRange: initialRange,
      helpText: 'Select period',
      saveText: 'Apply',
      fieldStartHintText: 'Start date',
      fieldEndHintText: 'End date',
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (!context.mounted || picked == null) return;

    final start = DateTime(
      picked.start.year,
      picked.start.month,
      picked.start.day,
    );
    final end = DateTime(picked.end.year, picked.end.month, picked.end.day);

    if (start.isAfter(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('The start date must not be after the end date.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    onChanged(DateRange.custom(start: start, end: end));
  }
}
