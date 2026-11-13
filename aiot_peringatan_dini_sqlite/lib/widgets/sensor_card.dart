import 'package:flutter/material.dart';

import '../models/pembacaan_sensor.dart';
import '../models/status_siaga.dart';
import 'status_siaga_chip.dart';

IconData ikonJenis(JenisSensor jenis) {
  switch (jenis) {
    case JenisSensor.ketinggianAir:
      return Icons.water_drop_outlined;
    case JenisSensor.pergeseranTanah:
      return Icons.terrain_outlined;
    case JenisSensor.curahHujan:
      return Icons.grain_outlined;
  }
}

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.nomor,
    required this.jenis,
    required this.nilai,
    required this.lokasi,
    required this.status,
  });

  final int nomor;
  final JenisSensor jenis;
  final double nilai;
  final String lokasi;
  final StatusSiaga status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final teks = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  nomor.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: scheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    ikonJenis(jenis),
                    size: 18,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    jenis.label,
                    style: teks.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusSiagaChip(status: status, padat: true),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  nilai.toStringAsFixed(1),
                  style: teks.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  jenis.satuan,
                  style: teks.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    lokasi,
                    style: teks.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
