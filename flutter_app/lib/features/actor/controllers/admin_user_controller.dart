import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user_model.dart';

final adminUserServiceProvider = Provider((ref) => AdminUserService(DioClient.create()));

class AdminUserService {
  final _dio;
  AdminUserService(this._dio);

  Future<List<UserModel>> getAllUsers() async {
    final res = await _dio.get('/api/admin/users');
    final List data = res.data['data'];
    return data.map((json) => UserModel.fromJson(json)).toList();
  }
}

class AdminUserController extends StateNotifier<AsyncValue<List<UserModel>>> {
  final AdminUserService _service;
  String _searchQuery = "";

  AdminUserController(this._service) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.getAllUsers());
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
  }

  List<UserModel> filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((u) => u.name.toLowerCase().contains(_searchQuery)).toList();
  }
}

final adminUserControllerProvider = StateNotifierProvider<AdminUserController, AsyncValue<List<UserModel>>>((ref) {
  return AdminUserController(ref.watch(adminUserServiceProvider));
});

final searchQueryProvider = StateProvider<String>((ref) => "");
