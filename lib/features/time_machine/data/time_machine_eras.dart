import 'package:flutter/material.dart';

import '../domain/models/era.dart';

class TimeMachineEras {
  const TimeMachineEras._();

  static const double lastPosition = 6;

  static const List<Era> values = [
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
      years: '3000 BC â€” 0',
      accent: Color(0xffffc978),
      icon: Icons.account_balance,
      video: 'assets/time_machine/videos/02_ancient.mp4',
    ),
    Era(
      name: 'MEDIEVAL',
      subtitle: 'FAITH FOR A HIGHER TOMORROW',
      years: '500 â€” 1500',
      accent: Color(0xffd48781),
      icon: Icons.shield_outlined,
      video: 'assets/time_machine/videos/03_medieval.mp4',
    ),
    Era(
      name: 'INDUSTRIAL',
      subtitle: 'IDEAS MOVE THE WORLD',
      years: '1760 â€” 1900',
      accent: Color(0xffe0b78d),
      icon: Icons.settings_outlined,
      video: 'assets/time_machine/videos/04_industrial.mp4',
    ),
    Era(
      name: 'CYBERPUNK',
      subtitle: 'A BRIGHTER CHAOS',
      years: '1980 â€” 2100',
      accent: Color(0xff53eaff),
      icon: Icons.bolt_outlined,
      video: 'assets/time_machine/videos/05_cyberpunk.mp4',
    ),
    Era(
      name: 'FUTURE',
      subtitle: 'A MORE HUMAN TOMORROW',
      years: '2100 â€” âˆ‍',
      accent: Color(0xffbfe7ff),
      icon: Icons.blur_on,
      video: 'assets/time_machine/videos/06_future.mp4',
    ),
    Era(
      name: 'FINALE',
      subtitle: 'ALWAYS CONNECTED',
      years: 'PAST â€” PRESENT â€” FUTURE',
      accent: Color(0xffd6ceff),
      icon: Icons.all_inclusive,
      video: 'assets/time_machine/videos/07_finale.mp4',
    ),
  ];
}
