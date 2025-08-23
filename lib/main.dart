// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/application_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/builder_provider.dart';
import 'data/services/api_service.dart';
import 'data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  // Initialize services
  final storageService = StorageService();
  final apiService = ApiService(storageService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => BuilderProvider(apiService),
        ),
      ],
      child: const FlutterNoCodeApp(),
    ),
  );
}