import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/actor_model.dart';
import '../services/actor_service.dart';

final actorServiceProvider = Provider((ref) => ActorService(DioClient.create()));

class ActorController extends StateNotifier<AsyncValue<List<ActorModel>>> {
  final ActorService _service;

  ActorController(this._service) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    // state = const AsyncValue.loading();
    // state = await AsyncValue.guard(() => _service.getActors());
  }

  Future<ActorModel?> createActor({
    required String npi,
    required String nRib,
    required File idCard,
    required File rib,
    required String birthdate,
    required String birthplace,
    required String diploma,
    required String bank,
    String? phone,
    int? userId,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _service.createActor(
          npi: npi,
          nRib: nRib,
          idCard: idCard,
          rib: rib,
          birthdate: birthdate,
          birthplace: birthplace,
          diploma: diploma,
          bank: bank,
          phone: phone,
          userId: userId,
        ));

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      throw result.error!;
    } else {
      await refresh();
      return result.value;
    }
  }

  Future<void> updateActor(
    int id, {
    required String npi,
    required String nRib,
    File? idCard,
    File? rib,
    required String birthdate,
    required String birthplace,
    required String diploma,
    required String bank,
    String? phone,
  }) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _service.updateActor(
          id,
          npi: npi,
          nRib: nRib,
          idCard: idCard,
          rib: rib,
          birthdate: birthdate,
          birthplace: birthplace,
          diploma: diploma,
          bank: bank,
          phone: phone,
        ));

    if (result.hasError) {
      state = AsyncValue.error(result.error!, result.stackTrace!);
      throw result.error!;
    } else {
      await refresh();
    }
  }

  Future<void> deleteActor(int id) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() => _service.deleteActor(id));
    if (!result.hasError) {
      await refresh();
    } else {
      state = AsyncValue.error(result.error!, result.stackTrace!);
    }
  }
}

final actorControllerProvider =
    StateNotifierProvider<ActorController, AsyncValue<List<ActorModel>>>((ref) {
  return ActorController(ref.watch(actorServiceProvider));
});

final actorDetailProvider = FutureProvider.family<ActorModel, int>((ref, id) async {
  return ref.watch(actorServiceProvider).getActor(id);
});
