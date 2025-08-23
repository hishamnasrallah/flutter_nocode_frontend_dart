// lib/app.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/auth/register_screen.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/applications/applications_list_screen.dart';
import 'presentation/applications/application_detail_screen.dart';
import 'presentation/applications/create_application_screen.dart';
import 'presentation/builder/screen_builder.dart';
import 'presentation/themes/themes_list_screen.dart';
import 'presentation/themes/theme_editor_screen.dart';
import 'presentation/build/build_history_screen.dart';

class FlutterNoCodeApp extends StatelessWidget {
  const FlutterNoCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp.router(
          title: 'Flutter No-Code Builder',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(),
          routerConfig: _router(authProvider),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      primaryColor: AppColors.primary,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  GoRouter _router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/dashboard' : '/login',
      redirect: (context, state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
                           state.matchedLocation == '/register';

        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }
        if (isAuthenticated && isAuthRoute) {
          return '/dashboard';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/applications',
          builder: (context, state) => const ApplicationsListScreen(),
        ),
        GoRoute(
          path: '/applications/create',
          builder: (context, state) => const CreateApplicationScreen(),
        ),
        GoRoute(
          path: '/applications/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ApplicationDetailScreen(applicationId: id);
          },
        ),
        GoRoute(
          path: '/applications/:id/builder',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ScreenBuilder(applicationId: id);
          },
        ),
        GoRoute(
          path: '/themes',
          builder: (context, state) => const ThemesListScreen(),
        ),
        GoRoute(
          path: '/themes/:id/edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ThemeEditorScreen(themeId: id);
          },
        ),
        GoRoute(
          path: '/builds/:applicationId',
          builder: (context, state) {
            final applicationId = state.pathParameters['applicationId']!;
            return BuildHistoryScreen(applicationId: applicationId);
          },
        ),
      ],
    );
  }
}
