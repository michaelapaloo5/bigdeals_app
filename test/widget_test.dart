import 'package:flutter_test/flutter_test.dart';
import 'package:bigdeals_app/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const BigDealsApp());
    expect(find.text('B'), findsOneWidget);
  });
}
