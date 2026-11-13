import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/pesanan_tersimpan.dart';
import '../navigation/app_routes.dart';
import 'data/data_contoh.dart';
import 'widget_desain.dart';

class HalamanPesanan extends StatefulWidget {
  const HalamanPesanan({super.key});

  @override
  State<HalamanPesanan> createState() => _HalamanPesananState();
}

class _HalamanPesananState extends State<HalamanPesanan> {
  late Future<List<PesananTersimpan>> _pesanan;

  @override
  void initState() {
    super.initState();
    _pesanan = DatabaseHelper.instance.ambilSemuaPesanan();
  }

  @override
  Widget build(BuildContext context) {
    final statusList = [
      'Semua',
      ...PesananContoh.daftarStatus.where((s) => s != 'Dibatalkan'),
    ];

    return DefaultTabController(
      length: statusList.length,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).hintColor,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: [for (final status in statusList) Tab(text: status)],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PesananTersimpan>>(
              future: _pesanan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? const <PesananTersimpan>[];
                return TabBarView(
                  children: [
                    for (final status in statusList)
                      _DaftarPesanan(daftar: data, status: status),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DaftarPesanan extends StatelessWidget {
  const _DaftarPesanan({required this.daftar, required this.status});

  final List<PesananTersimpan> daftar;
  final String status;

  List<PesananTersimpan> get _hasil {
    if (status == 'Semua') return daftar;
    return daftar.where((p) => p.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasil = _hasil;

    if (hasil.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            const Text('Belum ada pesanan di sini'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: hasil.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, indeks) {
        final pesanan = hasil[indeks];
        return KartuPesanan(pesanan: pesanan.keContoh());
      },
    );
  }
}

class KartuPesanan extends StatelessWidget {
  const KartuPesanan({super.key, required this.pesanan});

  final PesananContoh pesanan;

  @override
  Widget build(BuildContext context) {
    final pratinjau = pesanan.item.take(3).toList();
    final sisa = pesanan.item.length - pratinjau.length;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context)
            .pushNamed(AppRoutes.detailPesanan, arguments: pesanan);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pesanan #${pesanan.id}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                ChipStatus(status: pesanan.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${pesanan.tanggalLabel} • ${pesanan.metodeBayar}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final item in pratinjau) ...[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Warna.latarKategori(item.produk.kategori)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        item.produk.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (sisa > 0)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '+$sisa',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${pesanan.item.length} produk',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      rupiah(pesanan.total),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
