import 'package:flutter_test/flutter_test.dart';
import 'package:almawqef/main.dart';

void main() {
  testWidgets('App launches with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ElmokefApp());
    expect(find.text('الميقف'), findsOneWidget);
  });
}
