import 'package:flutter/material.dart';

import '../../../../features/catalog/cubit/catalog_cubit.dart';
import '../widgets/home_mobile_view.dart';
import '../widgets/web/web_home_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    CatalogCubit.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return const WebHomeView();
        }
        return const HomeMobileView();
      },
    );
  }
}
