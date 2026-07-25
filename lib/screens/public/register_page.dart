import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController konfirmasiController = TextEditingController();

  final AuthService _authService = AuthService();

  bool hidePassword = true;
  bool hideKonfirmasi = true;
  bool isLoading = false;

  static const Color primaryColor = Color(0xFFF5B41B);
  static const Color backgroundColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF1F2633);

  Future<void> _handleRegister() async {
    // Basic client-side checks before hitting the API.
    if (namaController.text.trim().isEmpty ||
        noHpController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua kolom.")),
      );
      return;
    }

    if (passwordController.text != konfirmasiController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await _authService.register(
      name: namaController.text.trim(),
      email: emailController.text.trim(),
      noHp: noHpController.text.trim(),
      password: passwordController.text,
      passwordConfirmation: konfirmasiController.text,
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil, silakan masuk.")),
      );

      Navigator.pushReplacementNamed(context, "/login");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Registrasi gagal.")),
      );
    }
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
                  "DAFTAR AKUN",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Buat akun RoadFix untuk mulai melaporkan kerusakan jalan dan memantau status laporan.",
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Nama Lengkap",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: namaController,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "Masukkan nama lengkap",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "No. HP",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: noHpController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "08xxxxxxxxxx",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

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
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "nama@email.com",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "••••••••",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: backgroundColor,

                    suffixIcon: IconButton(
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Konfirmasi Password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: konfirmasiController,
                  obscureText: hideKonfirmasi,
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "••••••••",
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),
                    filled: true,
                    fillColor: backgroundColor,

                    suffixIcon: IconButton(
                      icon: Icon(
                        hideKonfirmasi
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          hideKonfirmasi = !hideKonfirmasi;
                        });
                      },
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                    ),

                    onPressed: isLoading ? null : _handleRegister,

                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            "Daftar",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [

                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            "/login",
                          );
                        },
                        child: const Text(
                          "Masuk di sini",
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
                      style: TextStyle(
                        color: Colors.white70,
                      ),
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
    namaController.dispose();
    noHpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }
}