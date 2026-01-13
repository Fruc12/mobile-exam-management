import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/api_config.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';
import '../controllers/actor_controller.dart';
import '../controllers/admin_user_controller.dart';
import '../models/actor_model.dart';

class ActorDetailScreen extends ConsumerWidget {
  final int? actorId;
  final int? userId;

  const ActorDetailScreen({super.key, this.actorId, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (actorId != null && actorId != 0) {
      final actorAsync = ref.watch(actorDetailProvider(actorId!));

      return Scaffold(
        appBar: AppBar(
          title: const Text("Détails du profil"),
          actions: [
            actorAsync.whenData((actor) => PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.push('/actors/${actor.id}/edit', extra: actor);
                        break;
                      case 'delete':
                        _showDeleteConfirmation(context, ref, actor);
                        break;
                      case 'logout':
                        _showLogoutConfirmation(context, ref);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Modifier le profil'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_forever, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Supprimer le profil', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )).value ?? const SizedBox.shrink(),
          ],
        ),
        body: actorAsync.when(
          data: (actor) => _buildActorDetails(context, actor),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _buildErrorState(ref),
        ),
      );
    } else {
      return _buildEmptyProfileState(context, ref);
    }
  }

  Widget _buildActorDetails(BuildContext context, ActorModel actor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(actor),
          const SizedBox(height: 24),
          _buildInfoSection("Informations Personnelles", [
            _infoTile(Icons.fingerprint, "NPI", actor.npi),
            _infoTile(Icons.cake, "Date de naissance", actor.birthdate.toLocal().toString().split(' ')[0]),
            _infoTile(Icons.location_on, "Lieu de naissance", actor.birthplace),
            _infoTile(Icons.school, "Diplôme", actor.diploma),
            _infoTile(Icons.phone, "Téléphone", actor.phone ?? "Non renseigné"),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection("Informations Bancaires", [
            _infoTile(Icons.account_balance, "Banque", actor.bank),
            _infoTile(Icons.credit_card, "Numéro RIB", actor.nRib),
          ]),
          const SizedBox(height: 24),
          const Text(
            "Documents justificatifs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDocumentPreview(context, "Carte d'Identité", actor.idCard),
          const SizedBox(height: 16),
          _buildDocumentPreview(context, "Relevé d'Identité Bancaire (RIB)", actor.rib),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyProfileState(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authControllerProvider).user;
    String userName = "Utilisateur";
    
    if (userId != null) {
      final users = ref.read(adminUserControllerProvider).value;
      final user = users?.firstWhere((u) => u.id == userId, orElse: () => UserModel(id: userId!, name: "Utilisateur", email: "", role: "user"));
      userName = user?.name ?? "Utilisateur";
    } else if (authUser != null) {
      userName = authUser.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
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
                    SizedBox(width: 12),
                    Text('Se déconnecter', style: TextStyle(color: Colors.red)),
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
              "Profil de $userName",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Veuillez renseigner vos informations pour finaliser votre profil acteur.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                final targetId = userId ?? authUser?.id;
                context.pushReplacement('/actors/create?userId=$targetId');
              },
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

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Impossible de charger les détails'),
          ElevatedButton(
            onPressed: () => ref.refresh(actorDetailProvider(actorId!)),
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref, ActorModel actor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le profil ?"),
        content: const Text("Cette action est irréversible. Toutes les informations d'acteur seront effacées."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ANNULER")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("SUPPRIMER"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final currentUser = ref.read(authControllerProvider).user;
        await ref.read(actorControllerProvider.notifier).deleteActor(actor.id);
        
        if (currentUser?.isAdmin == true) {
          // PROCESS ADMIN : Rafraîchir la liste et revenir à la liste
          await ref.read(adminUserControllerProvider.notifier).refresh();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil supprimé par l'admin")));
            context.go('/actors'); // Retour à la liste des utilisateurs
          }
        } else {
          // PROCESS USER : Rafraîchir l'utilisateur courant et revenir au dashboard
          await ref.read(authControllerProvider.notifier).tryAutoLogin();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Votre profil acteur a été supprimé")));
            context.go('/actors'); // Retour au dashboard qui affichera l'état vide
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
        }
      }
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

  Widget _buildHeader(ActorModel actor) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              actor.user?.name.substring(0, 1).toUpperCase() ?? "A",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            actor.user?.name ?? "Acteur #${actor.id}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            actor.user?.email ?? "",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.blue.shade700, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(BuildContext context, String title, String fileName) {
    final mediaUrl = "${ApiConfig.baseUrl}/storage/$fileName";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showFullScreenMedia(context, mediaUrl),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                      mediaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenMedia(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            title: Text("Aperçu Image"),
          ),
          body: Center(
            child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain)),
          ),
        ),
      ),
    );
  }
}
