import 'package:flutter/material.dart';

import '../models/status_siaga.dart';

class StatusSiagaChip extends StatelessWidget {
  const StatusSiagaChip({super.key, this.status, this.padat = false});

  final StatusSiaga? status;
  final bool padat;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final gelap = Theme.of(context).brightness == Brightness.dark;

    final Color latar;
    final Color teks;
    final String label;

    if (status == null) {
      latar = scheme.outlineVariant;
      teks = scheme.onSurfaceVariant;
      label = 'Belum ada data';
    } else {
      label = status!.label;
      if (gelap) {
        latar = status!.warna.withAlpha(48);
        teks = Color.lerp(status!.warna, Colors.white, 0.55)!;
      } else {
        latar = status!.latar;
        teks = status!.warna;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padat ? 10 : 12,
        vertical: padat ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: latar,
        borderRadius: BorderRadius.circular(999),
        border: status == null ? Border.all(color: scheme.outlineVariant) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: teks,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: teks,
              fontSize: padat ? 11.5 : 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
