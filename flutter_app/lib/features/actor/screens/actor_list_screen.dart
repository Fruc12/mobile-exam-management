import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/actor_controller.dart';
import '../models/actor_model.dart';

class ActorListScreen extends ConsumerWidget {
  const ActorListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorsAsync = ref.watch(actorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Acteurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(actorControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: actorsAsync.when(
        data: (actors) => ListView.builder(
          itemCount: actors.length,
          itemBuilder: (context, index) {
            final actor = actors[index];
            return ListTile(
              title: Text(actor.user?.name ?? 'Inconnu'),
              subtitle: Text("${actor.bank} - ${actor.diploma}"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/actors/${actor.id}'),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/actors/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
