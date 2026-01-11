import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user_model.dart';

final adminUserServiceProvider = Provider((ref) => AdminUserService(DioClient.create()));

class AdminUserService {
  final Dio _dio;
  AdminUserService(this._dio);

  Future<List<UserModel>> getAllUsers() async {
    final res = await _dio.get('/api/users');
    final dynamic rawData = res.data is Map ? res.data['data'] : res.data;

    if (rawData is List) {
      return rawData.map((json) => UserModel.fromJson(json)).toList();
    } else if (rawData is Map) {
      return rawData.values.map((json) => UserModel.fromJson(json)).toList();
    }
    return [];
  }
}

class AdminUserController extends StateNotifier<AsyncValue<List<UserModel>>> {
  final AdminUserService _service;

  AdminUserController(this._service) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getAllUsers());
  }

  List<UserModel> filterUsers(List<UserModel> users, String query) {
    if (query.isEmpty) return users;
    final lowerQuery = query.toLowerCase();
    return users.where((u) {
      return u.name.toLowerCase().contains(lowerQuery) || 
             u.email.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

final adminUserControllerProvider = StateNotifierProvider<AdminUserController, AsyncValue<List<UserModel>>>((ref) {
  return AdminUserController(ref.watch(adminUserServiceProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => "");
