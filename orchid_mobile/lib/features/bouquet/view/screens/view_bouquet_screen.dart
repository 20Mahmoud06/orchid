import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_fonts.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../inspiration/models/inspiration_item.dart';
import '../../cubit/bouquet_cubit.dart';
import '../../utils/view_bouquet_cart_actions.dart';
import '../widgets/view_bouquet_preview.dart';

class ViewBouquetScreen extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final InspirationItem? bouquet;

  const ViewBouquetScreen({super.key, this.onBackPressed, this.bouquet});

  @override
  Widget build(BuildContext context) {
    final bouquetController = BouquetCubit.instance;
    final selectedFlowers = bouquetController.selectedFlowers;
    final isFromInspiration = bouquet != null;
    final isSingleFlowerKind =
        selectedFlowers.length == 1 &&
        bouquetController.selectedReadyBouquets.isEmpty;
    final isSingleFlower =
        isSingleFlowerKind && bouquetController.totalCount == 1;

    final title = isFromInspiration
        ? 'your bouquet'
        : (isSingleFlower ? 'View Your Flower' : 'your bouquet');

    final imagePath = isFromInspiration
        ? bouquet!.displayImagePath
        : (isSingleFlowerKind
              ? selectedFlowers.first.imagePath
              : AppAssets.bouquetTest);

    final description = isFromInspiration
        ? bouquet!.ingredients
        : selectedFlowers
              .map(
                (flower) =>
                    '${bouquetController.getQuantity(flower.id)} ${flower.name.toLowerCase()}',
              )
              .toList();

    final showTwoButtons = !isFromInspiration;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            children: [
              CustomAppBar.orchid(title: title, onBackPressed: onBackPressed),
              SizedBox(height: 24.h),
              Expanded(
                child: ViewBouquetPreview(
                  imagePath: imagePath,
                  description: description,
                ),
              ),
              if (showTwoButtons) ...[
                SizedBox(height: 12.h),
                CustomButton(
                  label: 'Edit Bouquet',
                  fontFamily: AppFonts.goudyOldStyle,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  height: 60.h,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.incrementButton,
                    width: 1.w,
                  ),
                  boxShadow: const [],
                  onPressed: () => Navigator.maybePop(context),
                ),
                SizedBox(height: 12.h),
              ],
              CustomButton(
                label: 'Looks Good',
                fontFamily: AppFonts.goudyOldStyle,
                fontSize: 24.sp,
                fontWeight: FontWeight.w400,
                textColor: AppColors.primary,
                backgroundColor: AppColors.incrementButton,
                height: 60.h,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: const [],
                onPressed: () {
                  if (isFromInspiration) {
                    saveInspirationToCart(context, bouquet);
                    return;
                  }
                  saveArrangementToCart(context);
                },
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
