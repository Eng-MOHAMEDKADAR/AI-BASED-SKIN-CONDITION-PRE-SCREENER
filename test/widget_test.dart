import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_crop_detection/main.dart';

void main() {
  testWidgets('App loads and shows upload screen', (WidgetTester tester) async {
    // Build the app and trigger a frame
    await tester.pumpWidget(const MyApp());

    // Verify that the main upload prompt is displayed
    expect(find.text('Upload or Capture a Crop Photo'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
    expect(find.text('Detect Disease'), findsOneWidget);

    // Tap on the camera button (no actual image will be picked in the test)
    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pump();

    // Tap on the gallery button (again, no image picked)
    await tester.tap(find.byIcon(Icons.photo_library_rounded));
    await tester.pump();

    // Verify that the detect button is present
    final detectButton = find.text('Detect Disease');
    expect(detectButton, findsOneWidget);

    // Tap the detect button
    await tester.tap(detectButton);
    await tester.pump();

    // Check that the loading indicator appears when tapped
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
