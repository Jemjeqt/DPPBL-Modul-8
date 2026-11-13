import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/sensor_cubit.dart';
import 'cubit/theme_cubit.dart';
import 'pages/halaman_dashboard.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AplikasiPeringatanDini());
}

class AplikasiPeringatanDini extends StatelessWidget {
  const AplikasiPeringatanDini({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SensorCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Peringatan Dini BPBD',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const HalamanDashboard(),
          );
        },
      ),
    );
  }
}
