import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/time_machine_eras.dart';
import '../../domain/models/era.dart';
import '../painters/atmosphere_painter.dart';
import '../widgets/foreground_ui.dart';
import '../widgets/scene_backdrop.dart';

class TimeMachineShowcase extends StatefulWidget {
  const TimeMachineShowcase({super.key, this.enableVideo = true});

  final bool enableVideo;

  @override
  State<TimeMachineShowcase> createState() => _TimeMachineShowcaseState();
}

class _TimeMachineShowcaseState extends State<TimeMachineShowcase>
    with TickerProviderStateMixin {
  static const double _lastPosition = TimeMachineEras.lastPosition;
  static const List<Era> _eras = TimeMachineEras.values;

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
      debugPrint('Failed to load video \${_eras[index].video}: $error');
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
                    SceneBackdrop(
                      videoControllers: _videoControllers,
                      videoOpacity: _videoOpacity,
                      finaleOpacity: _finaleOpacity(),
                    ),
                    CustomPaint(
                      painter: AtmospherePainter(
                        position: _position,
                        ambient: _ambientController.value,
                        activeColor: _eras[_activeIndex].accent,
                      ),
                    ),
                    SafeArea(
                      child: ForegroundUi(
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

double _lerp(double a, double b, double t) => a + (b - a) * t;
