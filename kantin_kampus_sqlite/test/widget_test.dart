import 'package:flutter_test/flutter_test.dart';

import 'package:kantin_kampus_sqlite/main.dart';

void main() {
  testWidgets('Halaman produk tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const KantinKampusApp());

    expect(find.text('Nasi Goreng'), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);
  });
}
