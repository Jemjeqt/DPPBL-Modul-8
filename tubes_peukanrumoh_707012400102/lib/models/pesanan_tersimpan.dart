import 'dart:convert';

import '../halaman/data/data_contoh.dart';

class ItemPesananTersimpan {
  const ItemPesananTersimpan({required this.idProduk, required this.jumlah});

  final int idProduk;
  final int jumlah;

  Map<String, dynamic> toMap() => {
    'id_produk': idProduk,
    'jumlah': jumlah,
  };

  factory ItemPesananTersimpan.fromMap(Map<String, dynamic> map) {
    return ItemPesananTersimpan(
      idProduk: map['id_produk'] as int,
      jumlah: map['jumlah'] as int,
    );
  }
}

class PesananTersimpan {
  const PesananTersimpan({
    this.id,
    required this.nomor,
    required this.tanggal,
    required this.status,
    required this.alamat,
    required this.metodeBayar,
    required this.total,
    required this.item,
  });

  final int? id;
  final int nomor;
  final String tanggal;
  final String status;
  final String alamat;
  final String metodeBayar;
  final int total;
  final List<ItemPesananTersimpan> item;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomor': nomor,
      'tanggal': tanggal,
      'status': status,
      'alamat': alamat,
      'metode_bayar': metodeBayar,
      'total': total,
      'item': jsonEncode([for (final baris in item) baris.toMap()]),
    };
  }

  factory PesananTersimpan.fromMap(Map<String, dynamic> map) {
    final itemMentah = jsonDecode(map['item'] as String) as List<dynamic>;
    return PesananTersimpan(
      id: map['id'] as int?,
      nomor: map['nomor'] as int,
      tanggal: map['tanggal'] as String,
      status: map['status'] as String,
      alamat: map['alamat'] as String,
      metodeBayar: map['metode_bayar'] as String,
      total: map['total'] as int,
      item: [
        for (final baris in itemMentah)
          ItemPesananTersimpan.fromMap(
            Map<String, dynamic>.from(baris as Map),
          ),
      ],
    );
  }

  factory PesananTersimpan.dariContoh(PesananContoh contoh) {
    final tanggal = _tanggalDariLabel(contoh.tanggalLabel) ??
        DateTime(2026, 9, 24);
    return PesananTersimpan(
      nomor: contoh.id,
      tanggal: tanggal.toIso8601String(),
      status: contoh.status,
      alamat: contoh.alamat,
      metodeBayar: contoh.metodeBayar,
      total: contoh.total,
      item: [
        for (final baris in contoh.item)
          ItemPesananTersimpan(
            idProduk: baris.produk.id,
            jumlah: baris.jumlah,
          ),
      ],
    );
  }

  PesananContoh keContoh() {
    final itemContoh = <ItemKeranjang>[];
    for (final baris in item) {
      final produk = cariProdukContoh(baris.idProduk);
      if (produk != null) {
        itemContoh.add(ItemKeranjang(produk: produk, jumlah: baris.jumlah));
      }
    }

    return PesananContoh(
      id: nomor,
      tanggalLabel: _labelTanggal(tanggal),
      status: status,
      item: itemContoh,
      alamat: alamat,
      metodeBayar: metodeBayar,
    );
  }
}

const _namaBulan = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

DateTime? _tanggalDariLabel(String label) {
  final bagian = label.split(' ');
  if (bagian.length != 3) return null;
  final hari = int.tryParse(bagian[0]);
  final bulan = _namaBulan.indexOf(bagian[1]);
  final tahun = int.tryParse(bagian[2]);
  if (hari == null || bulan < 0 || tahun == null) return null;
  return DateTime(tahun, bulan + 1, hari);
}

String _labelTanggal(String iso) {
  final waktu = DateTime.tryParse(iso)?.toLocal();
  if (waktu == null) return iso;
  return '${waktu.day} ${_namaBulan[waktu.month - 1]} ${waktu.year}';
}
