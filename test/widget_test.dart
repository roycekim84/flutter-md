import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_md/main.dart';

void main() {
  testWidgets('MUD app renders first room and accepts a command', (
    tester,
  ) async {
    await tester.pumpWidget(const MudApp());

    expect(find.textContaining('루미르 광장'), findsWidgets);
    expect(find.text('빠른 행동'), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-소문')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('quick-소문')));
    await tester.pumpAndSettle();

    expect(find.textContaining('오르페 폐광'), findsWidgets);

    await tester.enterText(find.byType(TextField), '소문');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.textContaining('오르페 폐광'), findsWidgets);
  });
}
