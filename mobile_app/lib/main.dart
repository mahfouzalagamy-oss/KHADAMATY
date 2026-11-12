import 'package:flutter/material.dart';
import 'core/routes/app_routes.dart';
import 'core/services/app_state_service.dart';
import 'core/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppStateService.instance;
  if (state.supabaseUrl.isNotEmpty && state.supabaseAnonKey.isNotEmpty) {
    state.connectSupabase(state.supabaseUrl, state.supabaseAnonKey);
  }
  runApp(const KhadamatyEgyptApp());
}

class KhadamatyEgyptApp extends StatelessWidget {
  const KhadamatyEgyptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final state = AppStateService.instance;
        return MaterialApp(
          title: 'خدماتي KHADAMATY - منصة الصيانة المنزلية',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(state.currentRole),
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.onGenerateRoute,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}