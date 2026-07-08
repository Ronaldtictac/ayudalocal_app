import 'package:flutter_test/flutter_test.dart';

import 'package:servicios_generales_app/main.dart';

void main() {
  testWidgets('App inicia sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Servicios Generales - Gestión de Órdenes'), findsOneWidget);
  });
}
