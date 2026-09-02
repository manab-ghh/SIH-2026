import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../shared/models/user_model.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storageService = StorageService();

  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.login,
        data: {'phone': phone, 'password': password},
      );

      final token = response.data['data']['token'];
      final user = UserModel.fromJson(response.data['data']['user']);

      await _storageService.saveToken(token);
      return user;
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<UserModel> demoLogin() async {
    try {
      final response = await _apiClient.dio.post(ApiConstants.demoLogin);

      final token = response.data['data']['token'];
      final user = UserModel.fromJson(response.data['data']['user']);

      await _storageService.saveToken(token);
      return user;
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    String? email,
    String? preferredLanguage,
    String? location,
    String? craftSpecialty,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'phone': phone,
          'password': password,
          'email': email ?? '',
          'preferredLanguage': preferredLanguage ?? 'hi',
          'location': location ?? 'Varanasi, India',
          'craftSpecialty': craftSpecialty ?? 'Handicrafts',
        },
      );

      final token = response.data['data']['token'];
      final user = UserModel.fromJson(response.data['data']['user']);

      await _storageService.saveToken(token);
      return user;
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final token = await _storageService.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await _apiClient.dio.get(ApiConstants.me);
      return UserModel.fromJson(response.data['data']['user']);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? preferredLanguage,
    String? location,
    String? craftSpecialty,
    String? profileImage,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiConstants.profile,
        data: {
          if (name != null) 'name': name,
          if (preferredLanguage != null) 'preferredLanguage': preferredLanguage,
          if (location != null) 'location': location,
          if (craftSpecialty != null) 'craftSpecialty': craftSpecialty,
          if (profileImage != null) 'profileImage': profileImage,
        },
      );
      return UserModel.fromJson(response.data['data']['user']);
    } catch (e) {
      throw ApiClient.formatError(e);
    }
  }

  Future<void> logout() async {
    await _storageService.clearAuth();
  }
}
