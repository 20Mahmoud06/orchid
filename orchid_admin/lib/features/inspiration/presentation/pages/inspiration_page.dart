import 'package:flutter/material.dart';

import '../../../../app/router/app_nav.dart';
import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/repositories/inspiration_repository.dart';
import '../../domain/models/inspiration_model.dart';
import '../widgets/inspiration_candidates_card.dart';
import '../widgets/inspiration_error_state.dart';
import '../widgets/inspiration_featured_card.dart';
import '../widgets/inspiration_page_header.dart';

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

  void _addNew() {
    AppNav.push(context, AppRoutes.addInspiration);
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
              InspirationPageHeader(
                isMobile: isMobile,
                onAdd: _addNew,
                onRefresh: _load,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_loadError != null)
                InspirationErrorState(message: _loadError!, onRetry: _load)
              else ...[
                InspirationFeaturedCard(
                  items: _featured,
                  busyId: _busyId,
                  onRemove: _remove,
                ),
                const SizedBox(height: 20),
                InspirationCandidatesCard(
                  candidates: _candidates,
                  featuredSourceIds: featuredSourceIds,
                  busyId: _busyId,
                  onAdd: _add,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
