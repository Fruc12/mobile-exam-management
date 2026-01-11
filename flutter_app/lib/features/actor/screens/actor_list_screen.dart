import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../controllers/admin_user_controller.dart';
import 'actor_detail_screen.dart';

class ActorListScreen extends ConsumerWidget {
  const ActorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Optimisation : On n'écoute que ce qui est nécessaire pour cette page
    final user = ref.watch(authControllerProvider.select((s) => s.user));

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user.isAdmin) {
      return const _AdminDashboard();
    } else {
      if (user.actor != null) {
        return ActorDetailScreen(actorId: user.actor!.id);
      }
      return _UserDashboard(user: user);
    }
  }
}

class _AdminDashboard extends ConsumerStatefulWidget {
  const _AdminDashboard();

  @override
  ConsumerState<_AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<_AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation du provider filtré optimisé
    final filteredUsersAsync = ref.watch(filteredUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Utilisateurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adminUserControllerProvider.notifier).refresh(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un utilisateur...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: filteredUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text("Aucun utilisateur trouvé"));
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(adminUserControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final hasActor = user.actor != null;

                return ListTile(
                  key: ValueKey(user.id), // Performance : Aide Flutter à identifier les éléments
                  leading: CircleAvatar(
                    backgroundColor: hasActor ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(
                      hasActor ? Icons.person : Icons.person_outline,
                      color: hasActor ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(hasActor ? "Acteur: ${user.actor!.bank}" : "Profil incomplet"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    if (hasActor) {
                      context.push('/actors/${user.actor!.id}');
                    } else {
                      context.push('/actors/0?userId=${user.id}');
                    }
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}

class _UserDashboard extends ConsumerWidget {
  final UserModel user;
  const _UserDashboard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil Acteur'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutConfirmation(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle_outlined, size: 100, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              "Bienvenue, ${user.name} !",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Veuillez renseigner vos informations pour finaliser votre profil.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.push('/actors/create'),
              icon: const Icon(Icons.add),
              label: const Text("COMPLÉTER MON PROFIL"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showLogoutConfirmation(BuildContext context, WidgetRef ref) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Déconnexion"),
      content: const Text("Voulez-vous vraiment vous déconnecter ?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ANNULER")),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("SE DÉCONNECTER"),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await ref.read(authControllerProvider.notifier).logout();
  }
}
