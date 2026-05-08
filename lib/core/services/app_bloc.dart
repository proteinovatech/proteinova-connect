import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proteinova_connect/core/cache/hive_service/purchase_hive_service.dart';
import 'package:proteinova_connect/core/network/dio_client.dart';
import 'package:proteinova_connect/features/auth/bloc/auth_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/supplier/supplier_event.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/supplier_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/data/repository/purchase_repository.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_bloc.dart';
import 'package:proteinova_connect/features/purchase/purchase_dashboard/bloc/purchase/purchase_event.dart';

class AppBlocProvider extends StatelessWidget {
  final Widget child;

  const AppBlocProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dio = DioClient().dio;

    final purchaseCache = PurchaseCacheService();

    return MultiBlocProvider(
      providers: [
       
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(),
        ),

     
        BlocProvider<SupplierBloc>(
          create: (_) => SupplierBloc(
            SupplierRepository(dio),
          )..add(FetchSuppliers()),
        ),

        
        BlocProvider<PurchaseBloc>(
          create: (_) => PurchaseBloc(
            SupplierRepository(dio),
            PurchaseRepository(dio, purchaseCache,),purchaseCache, 
          )..add(GetPurchasesEvent()),
        ),
      ],
      child: child,
    );
  }
}