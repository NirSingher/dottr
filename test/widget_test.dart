import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dottr/app.dart';
import 'package:dottr/providers/sync_provider.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Prevent Process.run in test environment
          syncInitProvider.overrideWith((ref) async {}),
        ],
        child: const DottrApp(),
      ),
    );
    // The app should at least show the title
    expect(find.text('dottr'), findsOneWidget);
  });
}
