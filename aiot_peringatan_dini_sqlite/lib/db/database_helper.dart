import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String namaTabel = 'pembacaan_sensor';
  static const String namaBerkas = 'peringatan_dini.db';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), namaBerkas);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pembacaan_sensor (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              jenis_sensor TEXT NOT NULL,
              nilai REAL NOT NULL,
              lokasi_pos TEXT NOT NULL,
              waktu TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> tambahPembacaan(PembacaanSensor pembacaan) async {
    final db = await database;
    return db.insert(namaTabel, pembacaan.toMap());
  }

  Future<List<PembacaanSensor>> ambilSemuaPembacaan() async {
    final db = await database;
    final hasil = await db.query(namaTabel, orderBy: 'id DESC');
    return hasil.map(PembacaanSensor.fromMap).toList();
  }

  Future<int> ubahPembacaan(PembacaanSensor pembacaan) async {
    final db = await database;
    return db.update(
      namaTabel,
      pembacaan.toMap(),
      where: 'id = ?',
      whereArgs: [pembacaan.id],
    );
  }

  Future<int> hapusPembacaan(int id) async {
    final db = await database;
    return db.delete(namaTabel, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PembacaanSensor>> ambilPembacaanTerbaruPerJenis() async {
    final db = await database;
    final hasil = await db.rawQuery('''
      SELECT * FROM $namaTabel
      WHERE id IN (
        SELECT MAX(id) FROM $namaTabel GROUP BY jenis_sensor
      )
      ORDER BY jenis_sensor
    ''');
    return hasil.map(PembacaanSensor.fromMap).toList();
  }
}
