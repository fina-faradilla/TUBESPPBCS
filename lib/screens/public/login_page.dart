import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();
  
  bool isLoading = false;

  bool rememberMe = false;
  bool obscurePassword = true;

  static const Color primaryColor = Color(0xFFF5B41B);
  static const Color backgroundColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF1F2633);

  Future<void> login() async {
  print("LOGIN DIKLIK");

  setState(() {
    isLoading = true;
  });

  final result = await authService.login(
    email: emailController.text.trim(),
    password: passwordController.text,
  );

  print(result);

  setState(() {
    isLoading = false;
  });

  if (result['success']) {
    final roleId = result['data']['user']['role_id'];

    if (!mounted) return;

    if (roleId == 1) {
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      Navigator.pushReplacementNamed(context, "/home");
    }
  } else {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
      ),
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
            width: 430,
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
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.5,
                  ),
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
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(
                    hintText: "nama@email.com",
                    hintStyle:
                        const TextStyle(color: Colors.white38),

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
                  style: const TextStyle(color: Colors.white),

                  decoration: InputDecoration(

                    hintText: "••••••••",

                    hintStyle: const TextStyle(
                      color: Colors.white38,
                    ),

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
                        style: TextStyle(
                          color: primaryColor,
                        ),
                      ),
                    )
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

                    onPressed: isLoading ? null : login,

                    child: const Text(
                      "Masuk",
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
                        "Belum punya akun? ",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            "/register",
                          );
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}