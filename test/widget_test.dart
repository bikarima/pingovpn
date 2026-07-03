import 'package:flutter_test/flutter_test.dart';
import 'package:pingo/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PingoApp());
    expect(find.byType(PingoApp), findsOneWidget);
  });
}
