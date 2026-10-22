import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/cubit/auth_cubit.dart';
import '../../../auth/cubit/auth_state.dart';
import 'home_side_menu_drawer.dart';

class HomeSideMenu extends StatelessWidget {
  const HomeSideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthFlowState>(
      bloc: AuthCubit.instance,
      builder: (context, state) => _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = AuthCubit.instance;
    final profile = auth.userProfile;
    final displayName =
        (profile?.username?.isNotEmpty ?? false) ? profile!.username! : 'User';
    final imageUrl = auth.getProfileImageUrl(profile?.profileImage);

    return HomeSideMenuDrawer(
      displayName: displayName,
      imageUrl: imageUrl,
    );
  }
}
