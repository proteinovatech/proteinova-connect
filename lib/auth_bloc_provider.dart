import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/branch/daily_closing/bloc/daily_closing_bloc.dart';
import 'package:proteinova_connect/features/branch/daily_closing/data/repository/dailyclosing_repository.dart';

class AppBlocProvider extends StatelessWidget {
  final Widget child;

  const AppBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),
        BlocProvider<DailyClosingBloc>(
          create: (_) => DailyClosingBloc(repository: DailyClosingRepository()),
        ),
      ],
      child: child,
    );
  }
}