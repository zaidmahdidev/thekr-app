import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thekr_app/core/extensions/theme_extension.dart';
import 'package:thekr_app/core/widgets/app_scaffold.dart';
import '../providers/misbaha_provider.dart';
import '../widgets/misbaha_painter.dart';
import '../widgets/crystal_counter.dart';
import '../widgets/zikr_selector.dart';
import '../widgets/reset_button.dart';

class MisbahaScreen extends ConsumerStatefulWidget {
  const MisbahaScreen({super.key});

  @override
  ConsumerState<MisbahaScreen> createState() => _MisbahaScreenState();
}

class _MisbahaScreenState extends ConsumerState<MisbahaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollController;
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Synchronize initial progress with saved total count
    final initialCount = ref.read(misbahaProvider).totalCount.toDouble();
    _scrollProgress = initialCount;

    _scrollController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 400),
          value: initialCount,
          upperBound: 1000000.0,
        )..addListener(() {
          setState(() {
            _scrollProgress = _scrollController.value;
          });
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleReset() {
    HapticFeedback.mediumImpact();
    ref.read(misbahaProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes to trigger animation
    ref.listen(misbahaProvider.select((s) => s.totalCount), (prev, next) {
      if (next != prev) {
        _scrollController.animateTo(
          next.toDouble(),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        );
      }
    });

    final state = ref.watch(misbahaProvider);

    return AppScaffold(
      title: 'المسبحة الالكترونية',
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          ref.read(misbahaProvider.notifier).increment();
        },
        child: Stack(
          children: [
            // 1. Hyper-Realistic Misbaha Engine
            CustomPaint(
              size: Size(1.sw, 1.sh),
              painter: InfiniteLoopBeadPainter(
                scrollProgress: _scrollProgress,
                primaryColor: context.colors.primary,
                secondaryColor: context.colors.secondary,
              ),
            ),

            // 2. Spiritual Control Dashboard
            Positioned(
              right: context.insets.lg,
              top: 0,
              bottom: 0,
              child: Center(
                child: _SpiritualDashboard(
                  count: state.count,
                  currentZikr: state.currentZikr,
                  onReset: _handleReset,
                  onZikrChanged: (zikr) =>
                      ref.read(misbahaProvider.notifier).setZikr(zikr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpiritualDashboard extends StatelessWidget {
  final int count;
  final MisbahaZikr currentZikr;
  final VoidCallback onReset;
  final Function(MisbahaZikr) onZikrChanged;

  const _SpiritualDashboard({
    required this.count,
    required this.currentZikr,
    required this.onReset,
    required this.onZikrChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OrnamentalZikrSelector(
          currentZikr: currentZikr,
          onChanged: onZikrChanged,
        ),
        SizedBox(height: context.insets.lg),
        CrystalCounter(count: count),
        SizedBox(height: context.insets.lg),
        MinimalistResetButton(onReset: onReset),
      ],
    );
  }
}
