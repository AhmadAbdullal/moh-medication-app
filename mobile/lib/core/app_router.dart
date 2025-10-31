import 'package:flutter/material.dart';

import '../features/auth/login/login_screen.dart';
import '../features/auth/register/register_screen.dart';
import '../features/home/home_screen.dart';
import '../features/medications/detail/medication_detail_screen.dart';
import '../features/medications/form/add_medication_screen.dart';
import '../features/medications/list/medication_list_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/reminders/detail/reminder_detail_screen.dart';
import '../features/reminders/list/reminders_screen.dart';
import '../features/reports/detail/report_detail_screen.dart';
import '../features/reports/list/reports_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/support/support_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String medicationListRoute = '/medications';
  static const String medicationDetailRoute = '/medications/detail';
  static const String addMedicationRoute = '/medications/add';
  static const String remindersRoute = '/reminders';
  static const String reminderDetailRoute = '/reminders/detail';
  static const String reportsRoute = '/reports';
  static const String reportDetailRoute = '/reports/detail';
  static const String notificationsRoute = '/notifications';
  static const String profileRoute = '/profile';
  static const String supportRoute = '/support';
  static const String settingsRoute = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case onboardingRoute:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case registerRoute:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case homeRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );
      case medicationListRoute:
        return MaterialPageRoute(
          builder: (_) => const MedicationListScreen(),
          settings: settings,
        );
      case medicationDetailRoute:
        return MaterialPageRoute(
          builder: (_) => MedicationDetailScreen(id: args as String?),
          settings: settings,
        );
      case addMedicationRoute:
        return MaterialPageRoute(
          builder: (_) => const AddMedicationScreen(),
          settings: settings,
        );
      case remindersRoute:
        return MaterialPageRoute(
          builder: (_) => const RemindersScreen(),
          settings: settings,
        );
      case reminderDetailRoute:
        return MaterialPageRoute(
          builder: (_) => ReminderDetailScreen(id: args as String?),
          settings: settings,
        );
      case reportsRoute:
        return MaterialPageRoute(
          builder: (_) => const ReportsScreen(),
          settings: settings,
        );
      case reportDetailRoute:
        return MaterialPageRoute(
          builder: (_) => ReportDetailScreen(id: args as String?),
          settings: settings,
        );
      case notificationsRoute:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
          settings: settings,
        );
      case profileRoute:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      case supportRoute:
        return MaterialPageRoute(
          builder: (_) => const SupportScreen(),
          settings: settings,
        );
      case settingsRoute:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
