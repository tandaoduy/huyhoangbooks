import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:huyhoangbooks/main.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});

    await Supabase.initialize(
      url: 'https://hezravfbckbbkrilzkyb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhlenJhdmZiY2tiYmtyaWx6a3liIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAzMTgzNDgsImV4cCI6MjA5NTg5NDM0OH0.mo5NGk6v94ZoquUq9vmFMV1CEAAMWOaW7-xAcjaL7ss',
    );
  });

  testWidgets('PageHome renders appbar loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BookstoreApp());

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
