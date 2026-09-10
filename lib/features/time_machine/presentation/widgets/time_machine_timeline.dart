import 'package:flutter/material.dart';

import '../../domain/models/era.dart';

class TimeMachineTimeline extends StatelessWidget {
  const TimeMachineTimeline({
    super.key,
    required this.position,
    required this.eras,
    required this.showLabels,
    required this.onSelect,
  });

  final double position;
  final List<Era> eras;
  final bool showLabels;
  final ValueChanged<double> onSelect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final activeEra = position.round().clamp(0, eras.length - 1);
        return SizedBox(
          height: 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 20,
                child: Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.28),
                ),
              ),
              Positioned(
                left: 0,
                top: 19,
                width: trackWidth * (position / 6),
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [eras[0].accent, eras[activeEra].accent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: eras[activeEra].accent.withValues(alpha: 0.68),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
              for (var i = 0; i < eras.length; i++)
                Positioned(
                  left: (trackWidth * i / 6) - 9,
                  top: 11,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(i.toDouble()),
                    child: _TimelineNode(
                      era: eras[i],
                      active: (position - i).abs() < 0.5,
                    ),
                  ),
                ),
              Positioned(
                left: (trackWidth * position / 6) - 8,
                top: 9,
                child: IgnorePointer(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: eras[activeEra].accent,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.92),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: eras[activeEra].accent.withValues(alpha: 0.88),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showLabels)
                Positioned(
                  left: 0,
                  right: 0,
                  top: 43,
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        eras[activeEra].years,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                          color: eras[activeEra].accent.withValues(alpha: 0.9),
                          fontSize: 9,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.era, required this.active});

  final Era era;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? era.accent.withValues(alpha: 0.9)
            : const Color(0xff081421),
        border: Border.all(
          color: active ? era.accent : Colors.white.withValues(alpha: 0.44),
          width: active ? 2 : 1,
        ),
        boxShadow: [
          if (active)
            BoxShadow(
              color: era.accent.withValues(alpha: 0.85),
              blurRadius: 17,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Icon(
        era.icon,
        size: active ? 9 : 7,
        color: const Color(0xff07101b),
      ),
    );
  }
}
