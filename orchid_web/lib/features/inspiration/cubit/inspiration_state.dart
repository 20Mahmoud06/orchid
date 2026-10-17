import 'package:equatable/equatable.dart';

import '../models/inspiration_item.dart';

/// State of the featured inspiration feed.
sealed class InspirationState extends Equatable {
  const InspirationState();

  @override
  List<Object?> get props => const <Object?>[];
}

final class InspirationInitial extends InspirationState {
  const InspirationInitial();
}

final class InspirationLoading extends InspirationState {
  const InspirationLoading();
}

final class InspirationFailure extends InspirationState {
  const InspirationFailure(this.error);

  final Object error;

  @override
  List<Object?> get props => <Object?>[error];
}

final class InspirationLoaded extends InspirationState {
  const InspirationLoaded(this.items);

  final List<InspirationItem> items;

  @override
  List<Object?> get props => <Object?>[items];
}
