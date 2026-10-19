import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/home_shell.dart';
import '../../features/profile/screens/me_screen.dart';
import '../../features/projects/screens/projects_screen.dart';
import '../../features/tasks/models/task.dart';
import '../../features/tasks/screens/task_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final loggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/otp' ||
          state.matchedLocation == '/';

      if (auth.isAuthenticated && loggingIn) return '/home';
      if (!auth.isAuthenticated && !loggingIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return OtpScreen(
            phone: extra['phone'] ?? '',
            name: extra['name'] ?? '',
            password: extra['password'] ?? '',
          );
        },
      ),

      // ---- Shell with global bottom nav ----
      ShellRoute(
        builder: (context, state, child) {
          return HomeShell(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: '/projects',
            builder: (_, __) => const ProjectsScreen(),
          ),
          GoRoute(
            path: '/calendar',
            builder: (_, __) => const CalendarScreen(),
          ),
          GoRoute(path: '/me', builder: (_, __) => const MeScreen()),
        ],
      ),

      // ---- Task detail (full screen, no bottom nav) ----
      GoRoute(
        path: '/task',
        builder: (_, state) {
          final task = state.extra as Task;
          return TaskDetailScreen(task: task);
        },
      ),
    ],
  );
});
