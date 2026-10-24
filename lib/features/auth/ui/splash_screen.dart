import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../tooling/seed/auto_seed_service.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) async {
        if (user == null) {
          Navigator.pushReplacementNamed(context, Routes.login);
        } else {
          // 👇 si tus reglas requieren usuario autenticado
          await AutoSeeder.run();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, Routes.home);
          }
        }
      });
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
