import 'package:flutter/material.dart';
import 'package:tubesppbcs/screens/public/login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color primaryColor = Color(0xFFF5B41B);
  static const Color backgroundColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF1F2633);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [

            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "RF",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [

                Text(
                  "ROADFIX",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Text(
                  "Sistem Pelaporan Jalan Rusak",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                )
              ],
            )
          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Text(
              "Masuk",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 8),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, "/register");
            },
            child: const Text("Daftar"),
          ),

          const SizedBox(width: 20),
        ],
      ),

      body: SingleChildScrollView(

        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 25,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(35),

                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Row(
                  children: [

                    Expanded(
                      flex: 3,

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "LAYANAN PELAPORAN INFRASTRUKTUR JALAN",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "LIHAT JALAN\nRUSAK?\nLAPORKAN\nLEWAT SINI.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              height: 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            "RoadFix membantu masyarakat melaporkan jalan rusak\n"
                            "kepada instansi terkait secara cepat.\n\n"
                            "Unggah lokasi dan foto kerusakan, kemudian pantau\n"
                            "status laporan hingga selesai diperbaiki.",
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.5,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 35),

                          Row(
                            children: [

                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),

                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "/login");
                                },

                                icon: const Icon(Icons.add),

                                label: const Text(
                                  "Buat Laporan",
                                ),
                              ),

                              const SizedBox(width: 18),

                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.grey.shade700,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                ),

                                onPressed: () {
                                  Navigator.pushNamed(
                                      context, "/login");
                                },

                                child: const Text(
                                  "Lacak Laporan",
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Icon(
                          Icons.add_road,
                          size: 220,
                          color: primaryColor.withOpacity(.9),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 45),

              const Text(
                "BAGAIMANA ALURNYA",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: Row(
                  children: const [

                    StepCard(
                      number: "01",
                      title: "Masuk",
                      color: Colors.blue,
                      description:
                          "Daftar akun terlebih dahulu kemudian login sebagai warga.",
                    ),

                    SizedBox(width: 20),

                    StepCard(
                      number: "02",
                      title: "Verifikasi",
                      color: Colors.orange,
                      description:
                          "Admin memeriksa kevalidan laporan yang dikirim warga.",
                    ),

                    SizedBox(width: 20),

                    StepCard(
                      number: "03",
                      title: "Diproses",
                      color: Colors.deepOrange,
                      description:
                          "Laporan diteruskan kepada petugas untuk diperbaiki.",
                    ),

                    SizedBox(width: 20),

                    StepCard(
                      number: "04",
                      title: "Selesai",
                      color: Colors.green,
                      description:
                          "Perbaikan selesai dan warga mendapat notifikasi.",
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class StepCard extends StatelessWidget {

  final String number;
  final String title;
  final String description;
  final Color color;

  const StepCard({
    super.key,
    required this.number,
    required this.title,
    required this.description,
    required this.color,
  });
    @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LandingPage.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(.18),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white70,
                height: 1.6,
                fontSize: 15,
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward_rounded,
              color: color,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }
}