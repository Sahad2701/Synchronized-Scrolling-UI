import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';
import '../widgets/top_container.dart';
import '../widgets/synchronized_content.dart';

/// Main home screen with sticky app bar and scrollable content
/// The app bar remains fixed while the content area scrolls vertically
/// Global scroll allows scrolling from either list or grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _globalScrollController = ScrollController();

  @override
  void dispose() {
    _globalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky app bar
            Container(
              height: AppDimensions.appBarHeight,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      size: AppDimensions.appBarIconSize,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  Text(
                    AppStrings.appBarTitle,
                    style: AppTypography.textTheme.displayMedium,
                  ),
                ],
              ),
            ),
            // Scrollable content area with global scroll
            Expanded(
              child: SingleChildScrollView(
                controller: _globalScrollController,
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    const TopContainer(),
                    SynchronizedContent(
                      globalScrollController: _globalScrollController,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}