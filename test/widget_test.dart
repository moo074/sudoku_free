// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:sudoku_free/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    // expect(find.text('0'), findsOneWidget);
    // expect(find.text('1'), findsNothing);

    // // Tap the '+' icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.add));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('0'), findsNothing);
    // expect(find.text('1'), findsOneWidget);

    // Build our app and trigger a frame.
    // await tester.pumpWidget(MyApp());

    // // Verify that Choose Difficulty Text is displayed
    expect(find.text('Choose Difficulty:'), findsOneWidget);
    // expect(find.text('Beginner'), findsOneWidget);
    // expect(find.text('Intermediate'), findsOneWidget);
    // expect(find.text('Expert'), findsOneWidget);
    // expect(find.byKey(Key('SetDifficulty_Beginner')), findsOneWidget);
    // expect(find.byKey(Key('SetDifficulty_Intermediate')), findsOneWidget);
    // expect(find.byKey(Key('SetDifficulty_Expert')), findsOneWidget);
    // //expect(find.text('1'), findsNothing);

    // // Tap the '+' icon and trigger a frame.
    // // await tester.tap(find.byKey(Key('SetDifficulty_Beginner')));    
    // // await tester.pump();    
    
    // // await tester.tap(find.byKey(Key('SetDifficulty_Intermediate')));    
    // // await tester.pump();
    
    // await tester.tap(find.byKey(Key('SetDifficulty_Expert')));    
    // await tester.pump();
  });
}
