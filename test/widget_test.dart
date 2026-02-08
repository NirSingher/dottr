import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dottr/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DottrApp(),
      ),
    );
    // The app should at least show the title
    expect(find.text('dottr'), findsOneWidget);
  });
}
