import 'package:flutter/material.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/app_router.dart';

class LockInApp extends StatelessWidget {
  const LockInApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LockIn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
