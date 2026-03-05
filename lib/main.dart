import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lock_in/app.dart';
import 'package:lock_in/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A0F2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local storage
  await StorageService.init();

  runApp(const ProviderScope(child: LockInApp()));
}
