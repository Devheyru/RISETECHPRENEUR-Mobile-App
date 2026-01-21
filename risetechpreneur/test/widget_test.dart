// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:risetechpreneur/main.dart';
import 'package:risetechpreneur/presentation/screens/main_navigation.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      // This app relies on Riverpod (ProviderScope) and DevicePreview wiring
      // configured in `main()`. In tests, we mount `MyApp` with those wrappers.
      await tester.pumpWidget(
        ProviderScope(
          child: DevicePreview(
            enabled: false,
            builder: (context) => const MyApp(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the app boots into the main navigation shell.
      expect(find.byType(MainNavigation), findsOneWidget);
    });
  });
}
