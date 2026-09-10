import 'package:flutter/material.dart';

import '../../features/time_machine/presentation/screens/time_machine_showcase.dart';
import '../theme/app_theme.dart';

class TimeMachineApp extends StatelessWidget {
  const TimeMachineApp({super.key, this.enableVideo = true});

  final bool enableVideo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Time Machine',
      theme: AppTheme.dark,
      home: TimeMachineShowcase(enableVideo: enableVideo),
    );
  }
}
