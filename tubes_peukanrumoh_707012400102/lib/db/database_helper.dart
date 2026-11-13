import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../halaman/data/data_contoh.dart';
import '../models/pesanan_tersimpan.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String namaTabel = 'pesanan';
  static const String namaBerkas = 'peukan_rumoh.db';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final lokasi = join(await getDatabasesPath(), namaBerkas);
    return openDatabase(
      lokasi,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pesanan (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nomor INTEGER NOT NULL,
              tanggal TEXT NOT NULL,
              status TEXT NOT NULL,
              alamat TEXT NOT NULL,
              metode_bayar TEXT NOT NULL,
              total INTEGER NOT NULL,
              item TEXT NOT NULL
          )
        ''');

        final batch = db.batch();
        for (final contoh in daftarPesananContoh) {
          batch.insert(namaTabel, PesananTersimpan.dariContoh(contoh).toMap());
        }
        await batch.commit(noResult: true);
      },
    );
  }

  Future<int> tambahPesanan(PesananTersimpan pesanan) async {
    final db = await database;
    return db.insert(namaTabel, pesanan.toMap());
  }

  Future<List<PesananTersimpan>> ambilSemuaPesanan() async {
    final db = await database;
    final hasil = await db.query(namaTabel, orderBy: 'id DESC');
    return hasil.map(PesananTersimpan.fromMap).toList();
  }

  Future<int> nomorPesananBerikutnya() async {
    final db = await database;
    final hasil = await db.rawQuery(
      'SELECT MAX(nomor) AS nomor FROM $namaTabel',
    );
    final terakhir = hasil.first['nomor'] as int?;
    return (terakhir ?? 2400) + 1;
  }
}
