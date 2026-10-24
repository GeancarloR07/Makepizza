import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_providers.dart';
import '../../core/constants/app_constants.dart';

/// Barra compacta con avatar + nombre + correo.
/// - Toca el avatar o cualquier parte para ir al Perfil.
/// - Si no hay usuario, sugiere iniciar sesión.
/// - NO muestra rol ni botón de cerrar sesión (eso queda en ProfileScreen).
class MiniProfileBar extends ConsumerWidget {
  final EdgeInsetsGeometry padding;
  final bool elevated;

  const MiniProfileBar({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final profileAsync = ref.watch(userProfileProvider);

    final card = Card(
      elevation: elevated ? 1 : 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, Routes.profile),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: profileAsync.when(
            loading: () => Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(context, width: 140, height: 14),
                      const SizedBox(height: 6),
                      _shimmerBox(context, width: 180, height: 12),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            error: (e, _) => Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  child: const Icon(Icons.person_off),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Error cargando perfil',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            data: (p) {
              final displayName = (p?.name?.trim().isNotEmpty == true)
                  ? p!.name!
                  : 'Usuario';
              final email = p?.email ?? user?.email ?? 'Inicia sesión';
              final photoUrl = p?.photoUrl;

              return Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    foregroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? const Icon(Icons.person, size: 26)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              );
            },
          ),
        ),
      ),
    );

    return Padding(padding: padding, child: card);
  }

  Widget _shimmerBox(
    BuildContext context, {
    required double width,
    required double height,
  }) {
    // placeholder sencillo (sin paquete extra)
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
