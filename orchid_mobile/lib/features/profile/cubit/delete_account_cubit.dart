import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/cubit/auth_cubit.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._auth) : super(const DeleteAccountState());

  final AuthCubit _auth;

  Future<void> deleteAccount() async {
    if (state.isDeleting) return;

    emit(state.copyWith(isDeleting: true, errorMessage: null));

    final error = await _auth.deleteAccount();
    if (isClosed) return;

    if (error != null) {
      emit(state.copyWith(isDeleting: false, errorMessage: error));
      return;
    }

    emit(state.copyWith(isDeleting: false, deletionSucceeded: true));
  }
}
