import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../theme/app_typography.dart';
import '../widgets/top_container.dart';
import '../widgets/synchronized_content.dart';
import '../widgets/synchronized_content/content_state.dart';

/// Main home screen with:
/// - Sticky app bar
/// - Vertically scrollable content
/// - Globally synchronized scrolling between list & grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _globalScrollController = ScrollController();
  final GlobalKey _topContainerKey = GlobalKey();

  final _topContainerHeight = ValueNotifier<double>(0);
  final _contentState = ValueNotifier<ContentState?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTopContainer();
    });
  }

  void _measureTopContainer() {
    final renderBox =
        _topContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _topContainerHeight.value = renderBox.size.height;
  }

  void _handleContentStateCreated(ContentState state) {
    if (_contentState.value != null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _contentState.value = state;
    });
  }

  @override
  void dispose() {
    _globalScrollController.dispose();
    _topContainerHeight.dispose();
    _contentState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(),
            Expanded(child: _buildScrollableContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return ValueListenableBuilder<ContentState?>(
      valueListenable: _contentState,
      builder: (_, contentState, __) {
        if (contentState == null) {
          return _buildScrollView(
            const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          );
        }

        return ValueListenableBuilder<ScrollPhysics>(
          valueListenable: contentState.globalPhysics,
          builder: (_, physics, ___) {
            return _buildScrollView(physics);
          },
        );
      },
    );
  }

  Widget _buildScrollView(ScrollPhysics physics) {
    return ValueListenableBuilder<double>(
      valueListenable: _topContainerHeight,
      builder: (_, height, __) {
        return SingleChildScrollView(
          controller: _globalScrollController,
          physics: physics,
          child: Column(
            children: [
              TopContainer(key: _topContainerKey),
              SynchronizedContent(
                globalScrollController: _globalScrollController,
                container1Height: height > 0 ? height : 220,
                onStateCreated: _handleContentStateCreated,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fixed app bar at the top
class _AppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            onPressed: SystemNavigator.pop,
          ),
          Text(
            AppStrings.appBarTitle,
            style: AppTypography.textTheme.displayMedium,
          ),
        ],
      ),
    );
  }
}