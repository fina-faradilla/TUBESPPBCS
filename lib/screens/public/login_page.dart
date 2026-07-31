import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/api.dart';
import '../../utils/auth_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool rememberMe = false;
  bool obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryColor = Color(0xFFF5B41B);
  static const Color backgroundColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF1F2633);

  // role_id 1 = Admin -> dashboard admin.
  // role_id lainnya (2 = Warga) -> portal warga.
  static const int kAdminRoleId = 1;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _tampilkanPesan('Email dan kata sandi wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http
          .post(
            Uri.parse(Api.login),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      final body = _tryDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sesuaikan kalau Laravel-mu membungkus response di "data".
        final data = (body['data'] is Map<String, dynamic>)
            ? body['data'] as Map<String, dynamic>
            : body;

        final token = data['access_token'] ?? data['token'];
        if (token == null) {
          _tampilkanPesan('Login berhasil tapi token tidak ditemukan.');
          return;
        }

        final user = (data['user'] is Map<String, dynamic>)
            ? data['user'] as Map<String, dynamic>
            : <String, dynamic>{};

        await AuthStorage.saveToken(token.toString());

        final roleId = user['role_id'];
        final String destination =
            roleId == kAdminRoleId ? '/admin/dashboard' : '/warga/buat-laporan';

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, destination);
        return;
      }

      if (response.statusCode == 422) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = (errors.values.first as List).first;
          _tampilkanPesan(firstError.toString());
        } else {
          _tampilkanPesan(body['message']?.toString() ?? 'Data tidak valid.');
        }
        return;
      }

      if (response.statusCode == 401) {
        _tampilkanPesan('Email atau kata sandi salah.');
        return;
      }

      _tampilkanPesan(
        body['message']?.toString() ??
            'Terjadi kesalahan pada server (${response.statusCode}).',
      );
    } catch (_) {
      _tampilkanPesan(
        'Tidak bisa menghubungi server. Periksa koneksi atau alamat API.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _tryDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  void _tampilkanPesan(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),

          child: Container(
            width: MediaQuery.of(context).size.width < 480
                ? double.infinity
                : 430,
            padding: const EdgeInsets.all(28),

            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "AUTENTIKASI",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "MASUK KE AKUN",
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Gunakan akun untuk melapor dan memantau status laporan Anda.",
                  style: TextStyle(color: Colors.white70, height: 1.5),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Email",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "nama@email.com",
                    hintStyle: const TextStyle(color: Colors.white38),

                    filled: true,
                    fillColor: backgroundColor,

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Kata Sandi",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  enabled: !_isLoading,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "••••••••",

                    hintStyle: const TextStyle(color: Colors.white38),

                    filled: true,
                    fillColor: backgroundColor,

                    suffixIcon: IconButton(
                      color: Colors.white70,
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      activeColor: primaryColor,

                      onChanged: (value) {
                        setState(() {
                          rememberMe = value!;
                        });
                      },
                    ),

                    const Text(
                      "Ingat saya",
                      style: TextStyle(color: Colors.white70),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Lupa kata sandi?",
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                    ),

                    onPressed: _isLoading ? null : _login,

                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            "Masuk",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: Colors.white70),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, "/register");
                        },
                        child: const Text(
                          "Daftar di sini",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                      size: 18,
                    ),
                    label: const Text(
                      "Kembali ke Beranda",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}