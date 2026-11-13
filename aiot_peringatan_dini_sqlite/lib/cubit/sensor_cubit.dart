import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/pembacaan_sensor.dart';

class SensorState {
  final Map<JenisSensor, double> nilai;
  final bool simulasiAktif;
  final int tick;

  const SensorState({
    required this.nilai,
    required this.simulasiAktif,
    this.tick = 0,
  });

  SensorState copyWith({
    Map<JenisSensor, double>? nilai,
    bool? simulasiAktif,
    int? tick,
  }) {
    return SensorState(
      nilai: nilai ?? this.nilai,
      simulasiAktif: simulasiAktif ?? this.simulasiAktif,
      tick: tick ?? this.tick,
    );
  }

  double nilaiDari(JenisSensor jenis) => nilai[jenis] ?? 0;
}

class SensorCubit extends Cubit<SensorState> {
  SensorCubit()
      : super(const SensorState(
          nilai: {
            JenisSensor.ketinggianAir: 132.0,
            JenisSensor.pergeseranTanah: 3.4,
            JenisSensor.curahHujan: 7.5,
          },
          simulasiAktif: false,
        ));

  static const Duration intervalSimulasi = Duration(seconds: 10);

  final Random _acak = Random();
  Timer? _timer;

  void acak() {
    final baru = <JenisSensor, double>{};
    for (final jenis in JenisSensor.values) {
      baru[jenis] = _nilaiAcak(jenis, state.nilaiDari(jenis));
    }
    emit(state.copyWith(nilai: baru, tick: state.tick + 1));
  }

  void aturNilai(JenisSensor jenis, double nilai) {
    emit(state.copyWith(nilai: {...state.nilai, jenis: nilai}));
  }

  void mulaiSimulasi() {
    if (state.simulasiAktif) return;
    emit(state.copyWith(simulasiAktif: true));
    _timer = Timer.periodic(intervalSimulasi, (_) => acak());
  }

  void hentikanSimulasi() {
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(simulasiAktif: false));
  }

  double _nilaiAcak(JenisSensor jenis, double sekarang) {
    final geser = (_acak.nextDouble() - 0.4) * 2;
    switch (jenis) {
      case JenisSensor.ketinggianAir:
        return (sekarang + geser * 25).clamp(80, 320);
      case JenisSensor.pergeseranTanah:
        return (sekarang + geser * 1.6).clamp(0, 18);
      case JenisSensor.curahHujan:
        return (sekarang + geser * 5).clamp(0, 40);
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _timer = null;
    return super.close();
  }
}
