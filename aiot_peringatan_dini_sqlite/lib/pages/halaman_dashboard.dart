import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/sensor_cubit.dart';
import '../db/database_helper.dart';
import '../models/pembacaan_sensor.dart';
import '../models/status_siaga.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/sensor_card.dart';
import '../widgets/theme_toggle_button.dart';
import 'halaman_riwayat_sensor.dart';

class HalamanDashboard extends StatefulWidget {
  const HalamanDashboard({super.key});

  @override
  State<HalamanDashboard> createState() => _HalamanDashboardState();
}

class _HalamanDashboardState extends State<HalamanDashboard> {
  late Future<List<PembacaanSensor>> _terbaru;

  @override
  void initState() {
    super.initState();
    _terbaru = DatabaseHelper.instance.ambilPembacaanTerbaruPerJenis();
  }

  void _muatUlangStatus() {
    setState(() {
      _terbaru = DatabaseHelper.instance.ambilPembacaanTerbaruPerJenis();
    });
  }

  void _snack(String pesan) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _simpanSemua(SensorState state) async {
    final waktu = DateTime.now().toIso8601String();
    for (final jenis in JenisSensor.values) {
      await DatabaseHelper.instance.tambahPembacaan(
        PembacaanSensor(
          jenis: jenis,
          nilai: state.nilaiDari(jenis),
          lokasiPos: jenis.lokasiDefault,
          waktu: waktu,
        ),
      );
    }
    if (!mounted) return;
    _muatUlangStatus();
    _snack('Pembacaan ${JenisSensor.values.length} sensor tersimpan.');
  }

  Future<void> _simpanTick(SensorState state) async {
    final waktu = DateTime.now().toIso8601String();
    for (final jenis in JenisSensor.values) {
      await DatabaseHelper.instance.tambahPembacaan(
        PembacaanSensor(
          jenis: jenis,
          nilai: state.nilaiDari(jenis),
          lokasiPos: jenis.lokasiDefault,
          waktu: waktu,
        ),
      );
    }
    if (!mounted) return;
    _muatUlangStatus();
  }

  Future<void> _inputManual() async {
    final pembacaan = await showDialog<PembacaanSensor>(
      context: context,
      builder: (_) => const _DialogInputManual(),
    );
    if (pembacaan == null) return;
    await DatabaseHelper.instance.tambahPembacaan(pembacaan);
    if (!mounted) return;
    _muatUlangStatus();
    _snack('${pembacaan.jenis.label} ${pembacaan.nilaiTampil} tersimpan.');
  }

  Future<void> _bukaRiwayat() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const HalamanRiwayatSensor(),
      ),
    );
    if (!mounted) return;
    _muatUlangStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peringatan Dini'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 6),
        ],
      ),
      body: BlocListener<SensorCubit, SensorState>(
        listenWhen: (prev, next) =>
            next.simulasiAktif && next.tick != prev.tick,
        listener: (_, state) => _simpanTick(state),
        child: BlocBuilder<SensorCubit, SensorState>(
          builder: (context, state) {
            final scheme = Theme.of(context).colorScheme;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                Text(
                  'BPBD KOTA BANDUNG',
                  style: TextStyle(
                    color: scheme.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Pantau lereng,\n'),
                      TextSpan(
                        text: 'jaga warga.',
                        style: TextStyle(
                          color: scheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontFamily: 'serif',
                    fontSize: 32,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      formatTanggalPanjang(DateTime.now()),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _KartuStatusTersimpan(
                  terbaru: _terbaru,
                  onKetuk: _bukaRiwayat,
                ),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Simpan Pembacaan',
                  icon: Icons.add_task_outlined,
                  onPressed: () => _simpanSemua(state),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _TileAksi(
                        ikon: Icons.edit_note_outlined,
                        label: 'Input Manual',
                        keterangan: 'Catat satu nilai',
                        onTap: _inputManual,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TileAksi(
                        ikon: Icons.history,
                        label: 'Riwayat Sensor',
                        keterangan: 'Ubah atau hapus',
                        onTap: _bukaRiwayat,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: scheme.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.sensors_outlined,
                            size: 20,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simulasi berkala',
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                state.simulasiAktif
                                    ? 'Tiap 10 detik, nilai baru langsung disimpan.'
                                    : 'Nilai diperbarui tiap 10 detik saat aktif.',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: state.simulasiAktif,
                          onChanged: (aktif) {
                            final cubit = context.read<SensorCubit>();
                            if (aktif) {
                              cubit.mulaiSimulasi();
                            } else {
                              cubit.hentikanSimulasi();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Pembacaan langsung',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < JenisSensor.values.length; i++) ...[
                  SensorCard(
                    nomor: i + 1,
                    jenis: JenisSensor.values[i],
                    nilai: state.nilaiDari(JenisSensor.values[i]),
                    lokasi: JenisSensor.values[i].lokasiDefault,
                    status: statusUntuk(
                      JenisSensor.values[i],
                      state.nilaiDari(JenisSensor.values[i]),
                    ),
                  ),
                  if (i != JenisSensor.values.length - 1)
                    const SizedBox(height: 12),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

String _waktuTerbaru(List<PembacaanSensor> data) {
  var terbaru = data.first;
  for (final pembacaan in data) {
    final waktu = DateTime.tryParse(pembacaan.waktu);
    final waktuTerbaru = DateTime.tryParse(terbaru.waktu);
    if (waktu != null && (waktuTerbaru == null || waktu.isAfter(waktuTerbaru))) {
      terbaru = pembacaan;
    }
  }
  return terbaru.waktuTampil;
}

class _KartuStatusTersimpan extends StatelessWidget {
  const _KartuStatusTersimpan({required this.terbaru, required this.onKetuk});

  final Future<List<PembacaanSensor>> terbaru;
  final VoidCallback onKetuk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<List<PembacaanSensor>>(
        future: terbaru,
        builder: (context, snapshot) {
          final data = snapshot.data ?? const <PembacaanSensor>[];
          final status = statusKeseluruhan(data);
          final terakhir = data.isEmpty ? null : _waktuTerbaru(data);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'STATUS TERSIMPAN',
                      style: TextStyle(
                        color: Color(0xFFE8C275),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onKetuk,
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.arrow_outward,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.connectionState == ConnectionState.waiting
                    ? 'Memuat…'
                    : status?.label ?? 'Belum ada data',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'serif',
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                terakhir == null
                    ? 'Belum ada pembacaan tersimpan.'
                    : 'Data tersimpan • $terakhir',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TileAksi extends StatelessWidget {
  const _TileAksi({
    required this.ikon,
    required this.label,
    required this.keterangan,
    required this.onTap,
  });

  final IconData ikon;
  final String label;
  final String keterangan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Theme.of(context).cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(ikon, size: 20, color: scheme.primary),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                keterangan,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogInputManual extends StatefulWidget {
  const _DialogInputManual();

  @override
  State<_DialogInputManual> createState() => _DialogInputManualState();
}

class _DialogInputManualState extends State<_DialogInputManual> {
  final _formKey = GlobalKey<FormState>();
  final _nilai = TextEditingController();
  final _lokasi = TextEditingController();
  JenisSensor _jenis = JenisSensor.ketinggianAir;

  @override
  void initState() {
    super.initState();
    _lokasi.text = _jenis.lokasiDefault;
  }

  @override
  void dispose() {
    _nilai.dispose();
    _lokasi.dispose();
    super.dispose();
  }

  void _kirim() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      PembacaanSensor(
        jenis: _jenis,
        nilai: double.parse(_nilai.text.trim().replaceAll(',', '.')),
        lokasiPos: _lokasi.text.trim(),
        waktu: DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Input Manual'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<JenisSensor>(
                initialValue: _jenis,
                decoration: const InputDecoration(labelText: 'Jenis sensor'),
                items: [
                  for (final jenis in JenisSensor.values)
                    DropdownMenuItem(
                      value: jenis,
                      child: Text('${jenis.label} (${jenis.satuan})'),
                    ),
                ],
                onChanged: (jenis) {
                  if (jenis == null) return;
                  setState(() {
                    _jenis = jenis;
                    _lokasi.text = jenis.lokasiDefault;
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nilai,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Nilai',
                  suffixText: _jenis.satuan,
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _lokasi,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Lokasi pos'),
                validator: (teks) {
                  if ((teks ?? '').trim().isEmpty) {
                    return 'Lokasi pos wajib diisi.';
                  }
                  return null;
                },
              ),
            ],
          ),
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
