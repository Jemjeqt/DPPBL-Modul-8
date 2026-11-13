enum JenisSensor {
  ketinggianAir(
    kode: 'ketinggian_air',
    label: 'Ketinggian Air',
    satuan: 'cm',
    lokasiDefault: 'Pos Bendungan Hulu',
  ),
  pergeseranTanah(
    kode: 'pergeseran_tanah',
    label: 'Pergeseran Tanah',
    satuan: 'mm',
    lokasiDefault: 'Pos Lereng Cibeureum',
  ),
  curahHujan(
    kode: 'curah_hujan',
    label: 'Curah Hujan',
    satuan: 'mm/jam',
    lokasiDefault: 'Pos Hujan Kota',
  );

  const JenisSensor({
    required this.kode,
    required this.label,
    required this.satuan,
    required this.lokasiDefault,
  });

  final String kode;
  final String label;
  final String satuan;
  final String lokasiDefault;

  static JenisSensor dariKode(String kode) {
    for (final jenis in values) {
      if (jenis.kode == kode) return jenis;
    }
    return ketinggianAir;
  }
}

class PembacaanSensor {
  final int? id;
  final JenisSensor jenis;
  final double nilai;
  final String lokasiPos;
  final String waktu;

  PembacaanSensor({
    this.id,
    required this.jenis,
    required this.nilai,
    required this.lokasiPos,
    required this.waktu,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jenis_sensor': jenis.kode,
      'nilai': nilai,
      'lokasi_pos': lokasiPos,
      'waktu': waktu,
    };
  }

  factory PembacaanSensor.fromMap(Map<String, dynamic> map) {
    return PembacaanSensor(
      id: map['id'] as int?,
      jenis: JenisSensor.dariKode(map['jenis_sensor'] as String),
      nilai: (map['nilai'] as num).toDouble(),
      lokasiPos: map['lokasi_pos'] as String,
      waktu: map['waktu'] as String,
    );
  }

  PembacaanSensor salinDengan({double? nilai}) {
    return PembacaanSensor(
      id: id,
      jenis: jenis,
      nilai: nilai ?? this.nilai,
      lokasiPos: lokasiPos,
      waktu: waktu,
    );
  }

  String get nilaiTampil => '${nilai.toStringAsFixed(1)} ${jenis.satuan}';

  String get waktuTampil => formatWaktuTampil(waktu);
}

const _namaBulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String duaDigit(int angka) => angka.toString().padLeft(2, '0');

String formatWaktuTampil(String iso) {
  final waktu = DateTime.tryParse(iso)?.toLocal();
  if (waktu == null) return iso;
  return '${duaDigit(waktu.day)} ${_namaBulan[waktu.month - 1]} ${waktu.year}'
      ' • ${duaDigit(waktu.hour)}:${duaDigit(waktu.minute)}';
}

const _namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

String formatTanggalPanjang(DateTime waktu) {
  return '${_namaHari[waktu.weekday - 1]}, ${waktu.day} '
      '${_namaBulan[waktu.month - 1]} ${waktu.year}';
}
