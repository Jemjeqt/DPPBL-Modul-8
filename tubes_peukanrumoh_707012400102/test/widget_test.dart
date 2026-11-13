import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:tubes_peukanrumoh_707012400102/main.dart';
import 'package:tubes_peukanrumoh_707012400102/db/database_helper.dart';
import 'package:tubes_peukanrumoh_707012400102/navigation/kerangka_navigasi.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tubes_peukanrumoh_707012400102/cubit/theme_cubit.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final folder = await Directory.systemTemp.createTemp('peukan_rumoh_uji_');
    await databaseFactory.setDatabasesPath(folder.path);
    await DatabaseHelper.instance.database;
  });

  Future<void> tungguDatabase(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = const Size(400, 900),
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PeukanRumohApp());
    await tungguDatabase(tester);
  }

  testWidgets('route salah tulis jatuh ke halaman tidak ditemukan', (
    tester,
  ) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(KerangkaUtama));
    Navigator.of(context).pushNamed('/prodak');
    await tungguDatabase(tester);

    expect(find.text('Halaman tidak ditemukan'), findsOneWidget);
    expect(find.textContaining('/prodak'), findsOneWidget);
  });

  testWidgets('Navigation Bar tampil di layar sempit', (tester) async {
    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('Navigation Rail menggantikan Navigation Bar di layar lebar', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(1200, 800));

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('drawer berisi Tentang Aplikasi dan bisa dibuka', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tungguDatabase(tester);

    expect(find.text('Tentang Aplikasi'), findsOneWidget);

    await tester.tap(find.text('Tentang Aplikasi'));
    await tungguDatabase(tester);

    expect(find.text('Materi navigasi yang diterapkan'), findsOneWidget);
  });

  testWidgets('item drawer selain Tentang memindahkan tab', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tungguDatabase(tester);

    await tester.tap(find.text('Profil').last);
    await tungguDatabase(tester);

    expect(find.text('Alamat pengiriman'), findsOneWidget);
    expect(find.text('budi@peukanrumoh.id'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tungguDatabase(tester);

    await tester.tap(find.text('Beranda').last);
    await tungguDatabase(tester);

    expect(find.text('Cari sayur, buah, atau bumbu...'), findsOneWidget);
  });

  testWidgets('alur beli langsung: push dengan data lalu pop dengan data', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Bayam Segar').first);
    await tungguDatabase(tester);

    await tester.tap(find.textContaining('Beli Langsung'));
    await tungguDatabase(tester);
    expect(find.text('Ringkasan pesanan'), findsOneWidget);
    expect(find.text('Metode pembayaran'), findsOneWidget);

    await tester.tap(find.textContaining('Bayar Rp').first);
    await tungguDatabase(tester);

    await tester.tap(find.text('Ya, Bayar'));
    await tungguDatabase(tester);

    expect(find.text('Bayam Segar'), findsOneWidget);
  });

  testWidgets('tambah ke keranjang lalu bayar dari keranjang', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Bayam Segar').first);
    await tungguDatabase(tester);

    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Tambah ke Keranjang'),
    );
    await tungguDatabase(tester);
    expect(find.textContaining('masuk keranjang'), findsOneWidget);

    await tester.pageBack();
    await tungguDatabase(tester);
    await tester.pump(const Duration(seconds: 5));
    await tungguDatabase(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Keranjang'),
      ),
    );
    await tungguDatabase(tester);

    expect(find.text('Total Bayar'), findsOneWidget);
    expect(find.textContaining('Bayar Rp'), findsNothing);

    await tester.tap(find.text('Bayar'));
    await tungguDatabase(tester);
    expect(find.text('Ringkasan pesanan'), findsOneWidget);
    expect(find.textContaining('Bayar Rp'), findsOneWidget);
  });

  testWidgets('tab pesanan berpindah kategori', (tester) async {
    await pumpApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pesanan'),
      ),
    );
    await tungguDatabase(tester);

    expect(find.textContaining('Pesanan #'), findsWidgets);

    final tabDiproses = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Diproses'),
    );
    await tester.ensureVisible(tabDiproses);
    await tungguDatabase(tester);
    await tester.tap(tabDiproses);
    await tungguDatabase(tester);
    expect(find.text('Pesanan #2401'), findsOneWidget);

    final tabSelesai = find.descendant(
      of: find.byType(TabBar),
      matching: find.text('Selesai'),
    );
    await tester.ensureVisible(tabSelesai);
    await tungguDatabase(tester);
    await tester.tap(tabSelesai);
    await tungguDatabase(tester);
    expect(find.text('Pesanan #2310'), findsOneWidget);
  });

  testWidgets('detail pesanan dibuka dari daftar', (tester) async {
    await pumpApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pesanan'),
      ),
    );
    await tungguDatabase(tester);

    await tester.tap(find.text('Pesanan #2401'));
    await tungguDatabase(tester);

    expect(find.textContaining('PR-2401'), findsOneWidget);
    expect(find.text('Produk dipesan'), findsOneWidget);
  });

  testWidgets('tombol mode gelap mengubah tema aplikasi', (tester) async {
    await pumpApp(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Profil'),
      ),
    );
    await tungguDatabase(tester);

    expect(find.text('Mode gelap'), findsOneWidget);

    final contextProfil = tester.element(find.text('Mode gelap'));
    expect(contextProfil.read<ThemeCubit>().state == ThemeMode.dark, isFalse);

    await tester.tap(find.text('Mode gelap'));
    await tungguDatabase(tester);

    final contextDark = tester.element(find.text('Mode gelap'));
    expect(contextDark.read<ThemeCubit>().state == ThemeMode.dark, isTrue);
    expect(find.text('Nyaman dipakai malam hari'), findsOneWidget);

    await tester.tap(find.text('Mode gelap'));
    await tungguDatabase(tester);

    final contextLight = tester.element(find.text('Mode gelap'));
    expect(contextLight.read<ThemeCubit>().state == ThemeMode.dark, isFalse);
    expect(find.text('Tampilan cerah siang hari'), findsOneWidget);
  });
}
