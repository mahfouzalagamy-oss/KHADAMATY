import 'package:flutter/material.dart';
import '../../features/auth/otp_login_screen.dart';
import '../../features/auth/technician_registration_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/orders/create_order_screen.dart';
import '../../features/orders/track_order_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String registerTech = '/register-tech';
  static const String home = '/home';
  static const String createOrder = '/create-order';
  static const String trackOrder = '/track-order';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const OtpLoginScreen(), settings: settings);
      case registerTech:
        return MaterialPageRoute(builder: (_) => const TechnicianRegistrationScreen(), settings: settings);
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
      case createOrder:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => CreateOrderScreen(initialServiceName: args?['service'] as String?),
          settings: settings,
        );
      case trackOrder:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TrackOrderScreen(orderId: args?['orderId'] as String?),
          settings: settings,
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);
    }
  }
}