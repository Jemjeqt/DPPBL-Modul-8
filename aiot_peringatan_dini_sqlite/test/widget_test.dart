import 'package:flutter_test/flutter_test.dart';

import 'package:aiot_peringatan_dini_sqlite/models/pembacaan_sensor.dart';
import 'package:aiot_peringatan_dini_sqlite/models/status_siaga.dart';

PembacaanSensor _pembacaan(JenisSensor jenis, double nilai) {
  return PembacaanSensor(
    jenis: jenis,
    nilai: nilai,
    lokasiPos: jenis.lokasiDefault,
    waktu: DateTime(2026, 11, 12, 8, 30).toIso8601String(),
  );
}

void main() {
  test('toMap memakai nama kolom snake_case', () {
    final map = _pembacaan(JenisSensor.ketinggianAir, 132.5).toMap();
    expect(map['jenis_sensor'], 'ketinggian_air');
    expect(map['lokasi_pos'], 'Pos Bendungan Hulu');
    expect(map['nilai'], 132.5);
  });

  test('fromMap mengembalikan properti yang sama', () {
    final asal = _pembacaan(JenisSensor.curahHujan, 12.0);
    final salinan = PembacaanSensor.fromMap(asal.toMap());
    expect(salinan.jenis, JenisSensor.curahHujan);
    expect(salinan.nilai, 12.0);
    expect(salinan.waktu, asal.waktu);
  });

  test('statusUntuk memakai ambang per jenis', () {
    expect(statusUntuk(JenisSensor.ketinggianAir, 149.9), StatusSiaga.aman);
    expect(statusUntuk(JenisSensor.ketinggianAir, 150), StatusSiaga.waspada);
    expect(statusUntuk(JenisSensor.ketinggianAir, 250), StatusSiaga.siaga);
    expect(statusUntuk(JenisSensor.pergeseranTanah, 5), StatusSiaga.waspada);
    expect(statusUntuk(JenisSensor.curahHujan, 20), StatusSiaga.siaga);
  });

  test('statusKeseluruhan mengambil status terburuk', () {
    final status = statusKeseluruhan([
      _pembacaan(JenisSensor.ketinggianAir, 120),
      _pembacaan(JenisSensor.pergeseranTanah, 6),
      _pembacaan(JenisSensor.curahHujan, 25),
    ]);
    expect(status, StatusSiaga.siaga);
  });

  test('statusKeseluruhan null bila data kosong', () {
    expect(statusKeseluruhan(const []), isNull);
  });
}
