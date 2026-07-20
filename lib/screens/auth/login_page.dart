import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: Row(
        children: [
          // ===================== SIDEBAR =====================
          Container(
            width: 260,
            color: const Color(0xff263238),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.orange,
                  child: Text(
                    "RF",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "RoadFix",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "JEMBATAN LAPOR JALAN RUSAK",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "HALAMAN PUBLIK",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const ListTile(
                  leading: Icon(Icons.home, color: Colors.white),
                  title: Text(
                    "Beranda",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const ListTile(
                    leading: Icon(Icons.login, color: Colors.white),
                    title: Text(
                      "Masuk / Daftar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "PORTAL WARGA",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const ListTile(
                  leading: Icon(Icons.report, color: Colors.white),
                  title: Text(
                    "Buat Laporan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const ListTile(
                  leading: Icon(Icons.history, color: Colors.white),
                  title: Text(
                    "Riwayat Laporan Saya",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const ListTile(
                  leading: Icon(Icons.description, color: Colors.white),
                  title: Text(
                    "Detail Laporan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "PORTAL ADMIN / DINAS",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const ListTile(
                  leading: Icon(Icons.dashboard, color: Colors.white),
                  title: Text(
                    "Dashboard",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text(
                    "Kelola Laporan",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // ===================== FORM LOGIN =====================
          Expanded(
            child: Center(
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: .2),
                      blurRadius: 12,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "AUTENTIKASI",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "MASUK KE AKUN",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Gunakan akun untuk melapor dan memantau status laporan Anda.",
                    ),

                    const SizedBox(height: 25),

                    const Text("Email"),

                    const SizedBox(height: 8),

                    TextField(
                      decoration: InputDecoration(
                        hintText: "nama@email.com",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text("Kata Sandi"),

                    const SizedBox(height: 8),

                    TextField(
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: "********",
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (v) {
                            setState(() {
                              rememberMe = v!;
                            });
                          },
                        ),
                        const Text("Ingat saya"),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text("Lupa kata sandi?"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black),
                          children: [
                            TextSpan(text: "Belum punya akun? "),
                            TextSpan(
                              text: "Daftar di sini",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}