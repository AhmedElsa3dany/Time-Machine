import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SceneBackdrop extends StatelessWidget {
  const SceneBackdrop({
    super.key,
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
