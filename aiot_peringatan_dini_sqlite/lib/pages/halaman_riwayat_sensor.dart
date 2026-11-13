import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/status_siaga.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_siaga_chip.dart';
import '../widgets/theme_toggle_button.dart';

class HalamanRiwayatSensor extends StatefulWidget {
  const HalamanRiwayatSensor({super.key});

  @override
  State<HalamanRiwayatSensor> createState() => _HalamanRiwayatSensorState();
}

class _HalamanRiwayatSensorState extends State<HalamanRiwayatSensor> {
  late Future<List<PembacaanSensor>> _riwayat;
  late Future<List<PembacaanSensor>> _terbaru;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  void _muat() {
    _riwayat = DatabaseHelper.instance.ambilSemuaPembacaan();
    _terbaru = DatabaseHelper.instance.ambilPembacaanTerbaruPerJenis();
  }

  void _muatUlangData() {
    setState(_muat);
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _ubah(PembacaanSensor pembacaan) async {
    final nilaiBaru = await showDialog<double>(
      context: context,
      builder: (_) => _DialogUbahNilai(pembacaan: pembacaan),
    );

    if (nilaiBaru == null) return;
    await DatabaseHelper.instance.ubahPembacaan(
      pembacaan.salinDengan(nilai: nilaiBaru),
    );
    if (!mounted) return;
    _muatUlangData();
    _snack('Nilai ${pembacaan.jenis.label} diperbarui.');
  }

  Future<void> _hapus(PembacaanSensor pembacaan) async {
    await DatabaseHelper.instance.hapusPembacaan(pembacaan.id!);
    if (!mounted) return;
    _muatUlangData();
    _snack('${pembacaan.jenis.label} dihapus.');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Sensor'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FutureBuilder<List<PembacaanSensor>>(
              future: _terbaru,
              builder: (context, snapshot) {
                return StatusSiagaChip(
                  status: statusKeseluruhan(
                    snapshot.data ?? const <PembacaanSensor>[],
                  ),
                  padat: true,
                );
              },
            ),
          ),
          const SizedBox(width: 4),
          const ThemeToggleButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Text(
              'Ketuk baris untuk koreksi nilai. Geser ke kiri untuk menghapus.',
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PembacaanSensor>>(
              future: _riwayat,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? const <PembacaanSensor>[];
                if (data.isEmpty) {
                  return const _RiwayatKosong();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  itemCount: data.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pembacaan = data[index];
                    final id = pembacaan.id;

                    return Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: scheme.error,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_outline, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'Hapus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onDismissed: (_) => _hapus(pembacaan),
                      child: _BarisRiwayat(
                        pembacaan: pembacaan,
                        onTap: id == null ? null : () => _ubah(pembacaan),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BarisRiwayat extends StatelessWidget {
  const _BarisRiwayat({required this.pembacaan, required this.onTap});

  final PembacaanSensor pembacaan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = statusUntuk(pembacaan.jenis, pembacaan.nilai);

    return Material(
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  ikonJenis(pembacaan.jenis),
                  size: 19,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pembacaan.jenis.label,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            pembacaan.lokasiPos,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pembacaan.waktuTampil,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    pembacaan.nilai.toStringAsFixed(1),
                    style: TextStyle(
                      color: status.warna,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    pembacaan.jenis.satuan,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogUbahNilai extends StatefulWidget {
  const _DialogUbahNilai({required this.pembacaan});

  final PembacaanSensor pembacaan;

  @override
  State<_DialogUbahNilai> createState() => _DialogUbahNilaiState();
}

class _DialogUbahNilaiState extends State<_DialogUbahNilai> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nilai;

  @override
  void initState() {
    super.initState();
    _nilai = TextEditingController(
      text: widget.pembacaan.nilai.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _nilai.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      double.parse(_nilai.text.trim().replaceAll(',', '.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Koreksi ${widget.pembacaan.jenis.label}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nilai,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Nilai',
            suffixText: widget.pembacaan.jenis.satuan,
          ),
          validator: (teks) {
            final isi = (teks ?? '').trim().replaceAll(',', '.');
            if (isi.isEmpty) return 'Nilai wajib diisi.';
            final angka = double.tryParse(isi);
            if (angka == null) return 'Masukkan angka, contoh 148.5';
            if (angka < 0) return 'Nilai tidak boleh negatif.';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: _kirim,
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}

class _RiwayatKosong extends StatelessWidget {
  const _RiwayatKosong();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada riwayat pembacaan.',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Simpan dari dashboard atau lewat Input Manual.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
