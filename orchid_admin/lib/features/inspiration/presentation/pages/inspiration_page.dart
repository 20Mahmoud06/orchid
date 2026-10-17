import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../products/domain/models/product_model.dart';
import '../../data/repositories/inspiration_repository.dart';
import '../../domain/models/inspiration_model.dart';

class InspirationPage extends StatefulWidget {
  const InspirationPage({super.key});

  @override
  State<InspirationPage> createState() => _InspirationPageState();
}

class _InspirationPageState extends State<InspirationPage> {
  final InspirationRepository _repository = InspirationRepository();

  List<InspirationItem> _featured = <InspirationItem>[];
  List<InspirationCandidate> _candidates = <InspirationCandidate>[];
  bool _isLoading = true;
  String? _loadError;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final featured = await _repository.getFeatured();
      final candidates = await _repository.getCandidates();
      if (!mounted) return;
      setState(() {
        _featured = featured;
        _candidates = candidates;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _add(InspirationCandidate candidate) async {
    setState(() => _busyId = candidate.orderItemId);
    try {
      await _repository.addFromCandidate(candidate);
      if (!mounted) return;
      _snack('Added to Inspiration');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _snack('Failed to add: $error', isError: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _remove(InspirationItem item) async {
    setState(() => _busyId = item.id);
    try {
      await _repository.remove(item.id);
      if (!mounted) return;
      _snack('Removed from Inspiration');
      await _load();
    } catch (error) {
      if (!mounted) return;
      _snack('Failed to remove: $error', isError: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _snack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 720;
    final featuredSourceIds = _featured
        .map((item) => item.sourceOrderItemId)
        .whereType<String>()
        .toSet();

    return ColoredBox(
      color: AppColors.background,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile: isMobile),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                _buildErrorState()
              else ...[
                _buildFeaturedCard(),
                const SizedBox(height: 20),
                _buildCandidatesCard(featuredSourceIds),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isMobile}) {
    final title = Text(
      'Inspiration',
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
    );
    final subtitle = Text(
      'Feature real customer bouquets on the mobile Inspiration tab.',
      style: AppTextStyles.bodySecondary,
    );
    final button = AppButton(
      label: 'Refresh',
      icon: Icons.refresh_rounded,
      variant: AppButtonVariant.outline,
      onPressed: _load,
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 6),
          subtitle,
          const SizedBox(height: 16),
          button,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 6),
              subtitle,
            ],
          ),
        ),
        button,
      ],
    );
  }

  Widget _buildErrorState() {
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 36, color: AppColors.error),
            const SizedBox(height: 12),
            Text('Failed to load inspiration',
                style: AppTextStyles.sectionTitle),
            const SizedBox(height: 6),
            Text(_loadError ?? '',
                textAlign: TextAlign.center, style: AppTextStyles.caption),
            const SizedBox(height: 16),
            AppButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: _load,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'FEATURED ON THE APP',
            'Shown to shoppers (newest ${InspirationRepository.maxFeatured})',
          ),
          const Divider(height: 1, color: AppColors.border),
          if (_featured.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('Nothing featured yet.',
                    style: AppTextStyles.bodySecondary),
              ),
            )
          else
            for (int i = 0; i < _featured.length; i++) ...[
              _FeaturedTile(
                item: _featured[i],
                isBusy: _busyId == _featured[i].id,
                onRemove: () => _remove(_featured[i]),
              ),
              if (i < _featured.length - 1)
                const Divider(height: 1, color: AppColors.border),
            ],
        ],
      ),
    );
  }

  Widget _buildCandidatesCard(Set<String> featuredSourceIds) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            'RECENT CUSTOM BOUQUETS',
            'From real customer orders',
          ),
          const Divider(height: 1, color: AppColors.border),
          if (_candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('No custom bouquets ordered yet.',
                    style: AppTextStyles.bodySecondary),
              ),
            )
          else
            for (int i = 0; i < _candidates.length; i++) ...[
              _CandidateTile(
                candidate: _candidates[i],
                isFeatured:
                    featuredSourceIds.contains(_candidates[i].orderItemId),
                isBusy: _busyId == _candidates[i].orderItemId,
                onAdd: () => _add(_candidates[i]),
              ),
              if (i < _candidates.length - 1)
                const Divider(height: 1, color: AppColors.border),
            ],
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final url = path == null || path!.isEmpty ? '' : productImageUrl(path!);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.orchidSoft1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? const Icon(Icons.local_florist_outlined,
              size: 22, color: AppColors.orchidStrong)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                  Icons.local_florist_outlined,
                  size: 22,
                  color: AppColors.orchidStrong),
            ),
    );
  }
}

class _FeatureBody extends StatelessWidget {
  const _FeatureBody({
    required this.name,
    required this.ingredients,
    required this.total,
  });

  final String? name;
  final List<InspirationIngredient> ingredients;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (name == null || name!.isEmpty) ? 'ORCHID customer' : name!,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            ingredients.isEmpty
                ? 'Custom arrangement'
                : ingredients
                    .map((i) => '${i.quantity} ${i.name.toLowerCase()}')
                    .join(', '),
            style: AppTextStyles.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text('${total.toStringAsFixed(0)} EGP',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _FeaturedTile extends StatelessWidget {
  const _FeaturedTile({
    required this.item,
    required this.isBusy,
    required this.onRemove,
  });

  final InspirationItem item;
  final bool isBusy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Thumb(path: item.imageUrl),
          const SizedBox(width: 12),
          _FeatureBody(
            name: item.displayName,
            ingredients: item.ingredients,
            total: item.total,
          ),
          const SizedBox(width: 12),
          isBusy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : AppButton(
                  label: 'Remove',
                  variant: AppButtonVariant.text,
                  onPressed: onRemove,
                ),
        ],
      ),
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.isFeatured,
    required this.isBusy,
    required this.onAdd,
  });

  final InspirationCandidate candidate;
  final bool isFeatured;
  final bool isBusy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Thumb(path: candidate.imageUrl),
          const SizedBox(width: 12),
          _FeatureBody(
            name: candidate.customerName,
            ingredients: candidate.ingredients,
            total: candidate.total,
          ),
          const SizedBox(width: 12),
          if (isBusy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isFeatured)
            Text('Featured',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ))
          else
            AppButton(label: 'Add', onPressed: onAdd),
        ],
      ),
    );
  }
}
