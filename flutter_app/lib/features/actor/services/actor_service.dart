import 'dart:io';
import 'package:dio/dio.dart';
import '../models/actor_model.dart';

class ActorService {
  final Dio dio;

  ActorService(this.dio);

  Future<List<ActorModel>> getActors() async {
    final res = await dio.get('/api/actors');
    final List data = res.data['data'];
    return data.map((json) => ActorModel.fromJson(json)).toList();
  }

  Future<ActorModel> getActor(int id) async {
    final res = await dio.get('/api/actors/$id');
    return ActorModel.fromJson(res.data['data']);
  }

  Future<ActorModel> createActor({
    required String npi,
    required String nRib,
    required File idCard,
    required File rib,
    required String birthdate,
    required String birthplace,
    required String diploma,
    required String bank,
    String? phone,
    int? userId, // Ajout du userId optionnel
  }) async {
    final formData = FormData.fromMap({
      'npi': npi,
      'n_rib': nRib,
      'birthdate': birthdate,
      'birthplace': birthplace,
      'diploma': diploma,
      'bank': bank,
      if (phone != null) 'phone': phone,
      if (userId != null) 'user_id': userId, // Transmission du userId au backend
      'id_card': await MultipartFile.fromFile(idCard.path),
      'rib': await MultipartFile.fromFile(rib.path),
    });

    try {
      final res = await dio.post('/api/actors', data: formData);
      return ActorModel.fromJson(res.data['data']);
    }
    on DioException catch (e) {
      throw e.response?.data['message'];
    }
  }

  Future<ActorModel> updateActor(
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
    final formData = FormData.fromMap({
      '_method': 'PUT',
      'npi': npi,
      'n_rib': nRib,
      'birthdate': birthdate,
      'birthplace': birthplace,
      'diploma': diploma,
      'bank': bank,
      if (phone != null) 'phone': phone,
      if (idCard != null) 'id_card': await MultipartFile.fromFile(idCard.path),
      if (rib != null) 'rib': await MultipartFile.fromFile(rib.path),
    });

    final res = await dio.post('/api/actors/$id', data: formData);
    return ActorModel.fromJson(res.data['data']);
  }

  Future<void> deleteActor(int id) async {
    await dio.delete('/api/actors/$id');
  }
}
