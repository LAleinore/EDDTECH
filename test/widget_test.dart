import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edumind_ai/app/app.dart';
import 'package:edumind_ai/features/auth/data/auth_repository.dart';

void main() {
  testWidgets('EduMind AI App smoke and initial render test', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const EduMindApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app brand is rendered
    expect(find.text('EduMind AI'), findsWidgets);
    expect(find.text('Войти'), findsWidgets);
    expect(find.text('Demo Режим для Жюри'), findsOneWidget);
  });
}
