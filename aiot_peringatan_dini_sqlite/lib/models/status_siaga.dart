import 'package:flutter/material.dart';

import 'pembacaan_sensor.dart';

enum StatusSiaga {
  aman('Aman', Color(0xFF1B7A57), Color(0xFFDDEFE6)),
  waspada('Waspada', Color(0xFF96660F), Color(0xFFF7E9C8)),
  siaga('Siaga', Color(0xFFB3261E), Color(0xFFF9DBD7));

  const StatusSiaga(this.label, this.warna, this.latar);

  final String label;
  final Color warna;
  final Color latar;
}

// Ambang batas ini asumsi praktikum, bukan angka resmi BPBD/BMKG.
const Map<JenisSensor, (double, double)> ambangStatus = {
  JenisSensor.ketinggianAir: (150, 250),
  JenisSensor.pergeseranTanah: (5, 10),
  JenisSensor.curahHujan: (10, 20),
};

StatusSiaga statusUntuk(JenisSensor jenis, double nilai) {
  final ambang = ambangStatus[jenis];
  if (ambang == null) return StatusSiaga.aman;
  if (nilai >= ambang.$2) return StatusSiaga.siaga;
  if (nilai >= ambang.$1) return StatusSiaga.waspada;
  return StatusSiaga.aman;
}

StatusSiaga? statusKeseluruhan(Iterable<PembacaanSensor> terbaruPerJenis) {
  StatusSiaga? terburuk;
  for (final pembacaan in terbaruPerJenis) {
    final status = statusUntuk(pembacaan.jenis, pembacaan.nilai);
    if (terburuk == null || status.index > terburuk.index) {
      terburuk = status;
    }
  }
  return terburuk;
}
