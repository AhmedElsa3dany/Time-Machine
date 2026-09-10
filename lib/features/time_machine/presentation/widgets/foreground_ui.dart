import 'package:flutter/material.dart';

import '../../domain/models/era.dart';
import 'time_machine_timeline.dart';

class ForegroundUi extends StatelessWidget {
  const ForegroundUi({
    super.key,
    required this.position,
    required this.introOpacity,
    required this.finaleOpacity,
    required this.activeIndex,
    required this.eras,
    required this.showLabels,
    required this.onSelect,
  });

  final double position;
  final double introOpacity;
  final double finaleOpacity;
  final int activeIndex;
  final List<Era> eras;
  final bool showLabels;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    final era = eras[activeIndex];
    final isHook = position < 0.72;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final copyHeight = (height * 0.11).clamp(76.0, 96.0);

        return Stack(
          children: [
            if (!isHook)
              Positioned(
                top: 0,
                left: 18,
                right: 18,
                child: _StatusBar(activeEra: era),
              ),
            if (!isHook)
              Positioned(
                top: height * 0.65,
                left: 24,
                right: 24,
                height: copyHeight,
                child: IgnorePointer(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(opacity: introOpacity, child: const _IntroCopy()),
                      Opacity(
                        opacity: (1 - introOpacity) * (1 - finaleOpacity),
                        child: _EraCopy(era: era),
                      ),
                      Opacity(
                        opacity: finaleOpacity,
                        child: const _FinaleCopy(),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: height * 0.81,
              left: width * 0.15,
              right: width * 0.15,
              child: TimeMachineTimeline(
                position: position,
                eras: eras,
                showLabels: showLabels,
                onSelect: onSelect,
              ),
            ),
            if (!isHook)
              Positioned(
                top: height * 0.76,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swipe,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'SWIPE TO TRAVEL',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                          fontSize: 9,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.activeEra});

  final Era activeEra;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '9:41',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          Icons.menu_rounded,
          size: 23,
          color: activeEra.accent.withValues(alpha: 0.92),
        ),
      ],
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TIME',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.86),
            fontSize: 15,
            letterSpacing: 8,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'MACHINE',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.96),
            fontSize: 31,
            letterSpacing: 7,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'SWIPE THROUGH HISTORY',
          style: TextStyle(
            color: const Color(0xffd6e7ff).withValues(alpha: 0.9),
            fontSize: 10,
            letterSpacing: 3.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EraCopy extends StatelessWidget {
  const _EraCopy({required this.era});

  final Era era;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            era.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.97),
              fontFamily: 'serif',
              fontSize: 32,
              letterSpacing: 4.2,
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(
                  color: era.accent.withValues(alpha: 0.64),
                  blurRadius: 22,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 9),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            era.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 9.5,
              letterSpacing: 2.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinaleCopy extends StatelessWidget {
  const _FinaleCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'PAST â€¢ PRESENT â€¢ FUTURE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.94),
              fontFamily: 'serif',
              fontSize: 22,
              letterSpacing: 3.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ALWAYS CONNECTED',
          style: TextStyle(
            color: const Color(0xffd3e2ff).withValues(alpha: 0.72),
            fontSize: 9,
            letterSpacing: 3.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
