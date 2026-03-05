import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/core/theme/app_theme.dart';
import 'package:lock_in/core/theme/theme_provider.dart';
import 'package:lock_in/app_router.dart';

class LockInApp extends ConsumerWidget {
  const LockInApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAmoled = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'LockIn',
      debugShowCheckedModeBanner: false,
      theme: isAmoled ? AppTheme.amoledTheme : AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
