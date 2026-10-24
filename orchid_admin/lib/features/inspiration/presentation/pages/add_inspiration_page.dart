import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/custom_text.dart';
import '../../../products/data/repositories/products_repository.dart';
import '../../../products/domain/models/product_model.dart';
import '../../data/repositories/inspiration_repository.dart';
import '../models/inspiration_form_data.dart';
import '../widgets/add_inspiration_top_bar.dart';
import '../widgets/inspiration_form.dart';

class AddInspirationPage extends StatefulWidget {
  const AddInspirationPage({super.key, this.productsRepository});

  final ProductsRepository? productsRepository;

  @override
  State<AddInspirationPage> createState() => _AddInspirationPageState();
}

class _AddInspirationPageState extends State<AddInspirationPage> {
  final InspirationRepository _repository = InspirationRepository();
  late final ProductsRepository _productsRepository =
      widget.productsRepository ?? ProductsRepository();

  List<Product>? _flowers;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadFlowers();
  }

  Future<void> _loadFlowers() async {
    try {
      final products = await _productsRepository.getAllProducts();
      if (!mounted) return;
      final flowers =
          products
              .where(
                (product) =>
                    product.type == ProductType.flower && product.isActive,
              )
              .toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
      setState(() {
        _flowers = flowers;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
    }
  }

  void _retryLoadFlowers() {
    setState(() {
      _flowers = null;
      _loadError = null;
    });
    _loadFlowers();
  }

  Future<bool> _handleSubmit(InspirationFormData data) async {
    try {
      final imagePath = await _repository.uploadImage(
        bytes: data.imageBytes,
        filename: data.imageName,
      );

      String? profileImage;
      if (data.avatarBytes != null) {
        final avatarPath = await _repository.uploadImage(
          bytes: data.avatarBytes!,
          filename: data.avatarName ?? 'creator.jpg',
          folder: 'inspiration/avatars',
        );
        profileImage = _repository.publicImageUrl(avatarPath);
      }

      await _repository.createManual(
        displayName: data.displayName,
        imagePath: imagePath,
        ingredients: data.ingredients,
        profileImage: profileImage,
      );

      if (!mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspiration added successfully'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      AppNav.pop(context);
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add inspiration: $error'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddInspirationTopBar(
                isMobile: isMobile,
                onInspirationPressed: () =>
                    AppNav.go(context, AppRoutes.inspiration),
                onBackPressed: () => AppNav.pop(context),
              ),
              const SizedBox(height: 20),
              CustomText(
                text: 'Add Inspiration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              CustomText(
                text: 'Create a featured bouquet for the web and mobile apps.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: 24),
              AppCard(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: _buildCardContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    if (_loadError != null) {
      return Column(
        children: [
          const Icon(Icons.error_outline, size: 36, color: AppColors.error),
          const SizedBox(height: 12),
          CustomText(
            text: 'Failed to load flowers: $_loadError',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _retryLoadFlowers, child: const Text('Retry')),
        ],
      );
    }

    final flowers = _flowers;
    if (flowers == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (flowers.isEmpty) {
      return Column(
        children: [
          const Icon(
            Icons.local_florist_outlined,
            size: 36,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const CustomText(
            text:
                'No active flowers found. Add flower products from the '
                'Products page first.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: _retryLoadFlowers, child: const Text('Retry')),
        ],
      );
    }

    return InspirationForm(products: flowers, onSubmitted: _handleSubmit);
  }
}
