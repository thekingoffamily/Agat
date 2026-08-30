import 'package:flutter_test/flutter_test.dart';
import 'package:agat/main.dart';

void main() {
  testWidgets('brand on first frame', (tester) async {
    await tester.pumpWidget(const AgatApp());
    await tester.pump();
    expect(find.text('Агат'), findsOneWidget);
  });
}
