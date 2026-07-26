import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api.dart';
import '../utils/auth_storage.dart';

class AuthService {
  /// LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(Api.login),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await AuthStorage.saveToken(data['token'].toString());
      return {'success': true, 'data': data};
    }
    return {'success': false, 'message': data['message']};
  }

  /// REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String noHp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse(Api.register),
      headers: {'Accept': 'application/json'},
      body: {
        'name': name,
        'email': email,
        'no_hp': noHp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await AuthStorage.saveToken(data['token'].toString());
      return {'success': true, 'data': data};
    }
    return {'success': false, 'message': data['message']};
  }

  /// LOGOUT
  Future<void> logout() async {
    final token = await AuthStorage.getToken();
    if (token != null) {
      await http.post(
        Uri.parse(Api.logout),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    }
    await AuthStorage.clearToken();
  }
}
