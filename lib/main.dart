import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const TimeMachineApp());
}

class TimeMachineApp extends StatelessWidget {
  const TimeMachineApp({super.key, this.enableVideo = true});

  final bool enableVideo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Machine',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff030811),
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: TimeMachineShowcase(enableVideo: enableVideo),
    );
  }
}

class Era {
  const Era({
    required this.name,
    required this.subtitle,
    required this.years,
    required this.accent,
    required this.icon,
    required this.video,
  });

  final String name;
  final String subtitle;
  final String years;
  final Color accent;
  final IconData icon;
  final String video;
}

class TimeMachineShowcase extends StatefulWidget {
  const TimeMachineShowcase({super.key, this.enableVideo = true});

  final bool enableVideo;

  @override
  State<TimeMachineShowcase> createState() => _TimeMachineShowcaseState();
}

class _TimeMachineShowcaseState extends State<TimeMachineShowcase>
    with TickerProviderStateMixin {
  static const double _lastPosition = 6;

  static const List<Era> _eras = [
    Era(
      name: '',
      subtitle: '',
      years: '',
      accent: Color(0xffd8eaff),
      icon: Icons.auto_awesome,
      video: 'assets/time_machine/videos/01_hook.mp4',
    ),
    Era(
      name: 'ANCIENT',
      subtitle: 'ROOTS OF CIVILIZATION',
      years: '3000 BC — 0',
      accent: Color(0xffffc978),
      icon: Icons.account_balance,
      video: 'assets/time_machine/videos/02_ancient.mp4',
    ),
    Era(
      name: 'MEDIEVAL',
      subtitle: 'FAITH FOR A HIGHER TOMORROW',
      years: '500 — 1500',
      accent: Color(0xffd48781),
      icon: Icons.shield_outlined,
      video: 'assets/time_machine/videos/03_medieval.mp4',
    ),
    Era(
      name: 'INDUSTRIAL',
      subtitle: 'IDEAS MOVE THE WORLD',
      years: '1760 — 1900',
      accent: Color(0xffe0b78d),
      icon: Icons.settings_outlined,
      video: 'assets/time_machine/videos/04_industrial.mp4',
    ),
    Era(
      name: 'CYBERPUNK',
      subtitle: 'A BRIGHTER CHAOS',
      years: '1980 — 2100',
      accent: Color(0xff53eaff),
      icon: Icons.bolt_outlined,
      video: 'assets/time_machine/videos/05_cyberpunk.mp4',
    ),
    Era(
      name: 'FUTURE',
      subtitle: 'A MORE HUMAN TOMORROW',
      years: '2100 — ∞',
      accent: Color(0xffbfe7ff),
      icon: Icons.blur_on,
      video: 'assets/time_machine/videos/06_future.mp4',
    ),
    Era(
      name: 'FINALE',
      subtitle: 'ALWAYS CONNECTED',
      years: 'PAST — PRESENT — FUTURE',
      accent: Color(0xffd6ceff),
      icon: Icons.all_inclusive,
      video: 'assets/time_machine/videos/07_finale.mp4',
    ),
  ];

  late final AnimationController _ambientController;
  late final AnimationController _snapController;
  final List<VideoPlayerController?> _videoControllers =
      List<VideoPlayerController?>.filled(_eras.length, null);
  final Set<int> _loadingVideos = <int>{};
  double _position = 0;
  double _snapStart = 0;
  double _snapEnd = 0;
  int _activeVideoIndex = 0;

  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..addListener(_handleSnapTick);
    if (widget.enableVideo) {
      unawaited(_activateVideo(0));
    }
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _snapController.dispose();
    for (final controller in _videoControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _handleSnapTick() {
    final eased = Curves.easeOutCubic.transform(_snapController.value);
    _setPosition(_lerp(_snapStart, _snapEnd, eased));
  }

  void _moveBy(double delta) {
    _snapController.stop();
    _setPosition(_position + delta);
  }

  void _setPosition(double value) {
    final nextPosition = value.clamp(0.0, _lastPosition);
    final nextVideoIndex = nextPosition.round().clamp(0, _eras.length - 1);
    if (nextVideoIndex != _activeVideoIndex) {
      if (widget.enableVideo) {
        unawaited(_activateVideo(nextVideoIndex));
      } else {
        _activeVideoIndex = nextVideoIndex;
      }
    }
    if (mounted) {
      setState(() {
        _position = nextPosition;
      });
    }
  }

  Future<void> _prepareVideo(int index) async {
    if (index < 0 ||
        index >= _eras.length ||
        _videoControllers[index] != null ||
        _loadingVideos.contains(index)) {
      return;
    }

    _loadingVideos.add(index);
    final controller = VideoPlayerController.asset(_eras[index].video);
    _videoControllers[index] = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);

      if (!mounted || !_shouldKeepVideo(index)) {
        if (identical(_videoControllers[index], controller)) {
          _videoControllers[index] = null;
        }
        await controller.dispose();
        return;
      }

      setState(() {});
      if (_activeVideoIndex == index) {
        await controller.play();
      }
    } catch (error, stackTrace) {
      if (identical(_videoControllers[index], controller)) {
        _videoControllers[index] = null;
      }
      await controller.dispose();
      debugPrint('Failed to load video ${_eras[index].video}: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _loadingVideos.remove(index);
    }
  }

  bool _shouldKeepVideo(int index) => (index - _activeVideoIndex).abs() <= 1;

  Future<void> _disposeDistantVideos(int activeIndex) async {
    final disposals = <Future<void>>[];
    for (var i = 0; i < _videoControllers.length; i++) {
      if ((i - activeIndex).abs() <= 1 || _loadingVideos.contains(i)) {
        continue;
      }

      final controller = _videoControllers[i];
      if (controller == null) continue;
      _videoControllers[i] = null;
      disposals.add(controller.dispose());
    }
    await Future.wait(disposals);
  }

  Future<void> _activateVideo(int index) async {
    if (index < 0 || index >= _eras.length) return;
    _activeVideoIndex = index;
    await _disposeDistantVideos(index);

    if (!mounted || _activeVideoIndex != index) return;
    await _prepareVideo(index);
    unawaited(_prepareVideo(index - 1));
    unawaited(_prepareVideo(index + 1));

    for (var i = 0; i < _videoControllers.length; i++) {
      final controller = _videoControllers[i];
      if (controller == null || !controller.value.isInitialized) continue;
      if (i == index) {
        unawaited(controller.play());
      } else {
        unawaited(controller.pause());
      }
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    _moveBy(-delta / 235);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final momentum = velocity.abs() > 240 ? (velocity < 0 ? 0.55 : -0.55) : 0;
    _animateTo((_position + momentum).roundToDouble());
  }

  void _animateTo(double target) {
    _snapController.stop();
    _snapStart = _position;
    _snapEnd = target.clamp(0.0, _lastPosition);
    _snapController.forward(from: 0);
  }

  int get _activeIndex => _position.round().clamp(0, _eras.length - 1);

  double _videoOpacity(int videoIndex) {
    return (1 - (_position - videoIndex).abs()).clamp(0.0, 1.0);
  }

  double _introOpacity() => (1 - _position / 0.72).clamp(0.0, 1.0);

  double _finaleOpacity() => ((_position - 5.25) / 0.75).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                onDoubleTap: () => _animateTo((_position + 1).clamp(0, 6)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _SceneBackdrop(
                      videoControllers: _videoControllers,
                      videoOpacity: _videoOpacity,
                      finaleOpacity: _finaleOpacity(),
                    ),
                    CustomPaint(
                      painter: _AtmospherePainter(
                        position: _position,
                        ambient: _ambientController.value,
                        activeColor: _eras[_activeIndex].accent,
                      ),
                    ),
                    SafeArea(
                      child: _ForegroundUi(
                        position: _position,
                        introOpacity: _introOpacity(),
                        finaleOpacity: _finaleOpacity(),
                        activeIndex: _activeIndex,
                        eras: _eras,
                        showLabels: _position > 0.72,
                        onSelect: _animateTo,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SceneBackdrop extends StatelessWidget {
  const _SceneBackdrop({
    required this.videoControllers,
    required this.videoOpacity,
    required this.finaleOpacity,
  });

  final List<VideoPlayerController?> videoControllers;
  final double Function(int index) videoOpacity;
  final double finaleOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff020912), Color(0xff071321), Color(0xff01040a)],
              stops: [0, 0.48, 1],
            ),
          ),
        ),
        for (var i = 0; i < videoControllers.length; i++)
          if (videoOpacity(i) > 0.01 &&
              videoControllers[i] != null &&
              videoControllers[i]!.value.isInitialized)
            Positioned.fill(
              child: Opacity(
                opacity: videoOpacity(i),
                child: _VideoFill(controller: videoControllers[i]!),
              ),
            ),
        if (finaleOpacity > 0)
          Opacity(
            opacity: finaleOpacity * 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.1),
                  radius: 0.9,
                  colors: [
                    const Color(0xffc5d9ff).withValues(alpha: 0.44),
                    const Color(0xff07101e).withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xff02060d).withValues(alpha: 0.34),
                Colors.transparent,
                const Color(0xff01040a).withValues(alpha: 0.82),
              ],
              stops: const [0, 0.44, 1],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.12),
              radius: 0.82,
              colors: [
                Colors.transparent,
                const Color(0xff02060e).withValues(alpha: 0.62),
              ],
              stops: const [0.4, 1],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoFill extends StatelessWidget {
  const _VideoFill({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}

class _ForegroundUi extends StatelessWidget {
  const _ForegroundUi({
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
              child: _Timeline(
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
            'PAST • PRESENT • FUTURE',
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

class _Timeline extends StatelessWidget {
  const _Timeline({
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

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({
    required this.position,
    required this.ambient,
    required this.activeColor,
  });

  final double position;
  final double ambient;
  final Color activeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(73);
    final horizon = size.height * 0.74;
    final cyberpunk = (1 - (position - 4).abs()).clamp(0.0, 1.0);
    final industrial = (1 - (position - 3).abs()).clamp(0.0, 1.0);
    final finale = (position - 5.2).clamp(0.0, 1.0);

    for (var i = 0; i < 68; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final phase = random.nextDouble() * math.pi * 2;
      final speed = 0.25 + random.nextDouble() * 0.8;
      final driftX = math.sin(ambient * math.pi * 2 * speed + phase) * 12;
      final driftY = math.cos(ambient * math.pi * 2 * speed + phase) * 8;
      final radius = 0.45 + random.nextDouble() * 1.5;
      final alpha =
          (0.1 + random.nextDouble() * 0.45) * (0.72 + cyberpunk * 0.5);
      final color = Color.lerp(
        activeColor,
        Colors.white,
        random.nextDouble() * 0.55,
      )!.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(x + driftX, y + driftY),
        radius,
        Paint()..color = color,
      );
    }

    if (industrial > 0.05) {
      final smokePaint = Paint()
        ..color = const Color(0xffd2d1ca).withValues(alpha: 0.04 * industrial)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18;
      for (var i = 0; i < 4; i++) {
        final path = Path()..moveTo(size.width * (0.12 + i * 0.25), horizon);
        path.cubicTo(
          size.width * (0.05 + i * 0.26),
          horizon - size.height * 0.13,
          size.width * (0.22 + i * 0.23),
          horizon - size.height * 0.24,
          size.width * (0.15 + i * 0.25),
          horizon - size.height * 0.36,
        );
        canvas.drawPath(path, smokePaint);
      }
    }

    if (cyberpunk > 0.05) {
      final gridPaint = Paint()
        ..color = const Color(0xff4cdfff).withValues(alpha: 0.08 * cyberpunk)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7;
      for (var i = 0; i < 9; i++) {
        final y = horizon + i * size.height * 0.025;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
      for (var i = -5; i < 6; i++) {
        canvas.drawLine(
          Offset(size.width / 2 + i * 20, horizon),
          Offset(size.width / 2 + i * 94, size.height),
          gridPaint,
        );
      }
      final scanPaint = Paint()
        ..color = const Color(0xffd43aff).withValues(alpha: 0.07 * cyberpunk)
        ..strokeWidth = 1;
      final scanY = (ambient * size.height * 1.3) % size.height;
      canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), scanPaint);
    }

    if (finale > 0) {
      final linePaint = Paint()
        ..color = const Color(0xffb8d6ff).withValues(alpha: 0.12 * finale)
        ..strokeWidth = 0.6;
      for (var i = 0; i < 12; i++) {
        final y = size.height * (0.08 + i * 0.065);
        canvas.drawLine(
          Offset(size.width * 0.16, y),
          Offset(size.width * 0.84, y),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) => true;
}

double _lerp(double a, double b, double t) => a + (b - a) * t;
