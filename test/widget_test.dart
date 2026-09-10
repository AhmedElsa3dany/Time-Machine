import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:idea/main.dart';

void main() {
  testWidgets('time machine showcase renders its opening scene', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TimeMachineApp(enableVideo: false));
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('TIME MACHINE'), findsNothing);
    expect(find.text('SWIPE THROUGH HISTORY'), findsNothing);
    expect(find.byType(CustomPaint), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
