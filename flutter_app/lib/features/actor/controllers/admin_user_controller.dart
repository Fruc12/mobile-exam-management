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
    // Si on a déjà des données, on ne met pas en loading pour éviter le spinner bloquant
    final hasData = state.hasValue;
    if (!hasData) state = const AsyncValue.loading();
    
    final result = await AsyncValue.guard(() => _service.getAllUsers());
    state = result;
  }
}

final adminUserControllerProvider = StateNotifierProvider<AdminUserController, AsyncValue<List<UserModel>>>((ref) {
  return AdminUserController(ref.watch(adminUserServiceProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => "");

// OPTIMISATION : Provider filtré mémorisé (Memoized)
// Ce provider ne recalculera la liste que si les utilisateurs changent OU si la recherche change.
final filteredUsersProvider = Provider<AsyncValue<List<UserModel>>>((ref) {
  final usersAsync = ref.watch(adminUserControllerProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return usersAsync.whenData((users) {
    if (query.isEmpty) return users;
    return users.where((u) => 
      u.name.toLowerCase().contains(query) || 
      u.email.toLowerCase().contains(query)
    ).toList();
  });
});
