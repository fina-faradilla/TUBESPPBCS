import 'package:flutter/material.dart';
import 'package:tubesppbcs/screens/public/login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const Color primaryColor = Color(0xFFF5B41B);
  static const Color backgroundColor = Color(0xFF161B22);
  static const Color cardColor = Color(0xFF1F2633);

  // Breakpoint: below this width we switch to the mobile layout.
  static const double mobileBreakpoint = 700;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleSpacing: 16,
        title: Builder(
          builder: (context) {
            final isMobile = MediaQuery.of(context).size.width < mobileBreakpoint;

            return Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                const SizedBox(width: 10),
                // On narrow phones we hide the subtitle so this row never
                // has to fight the "Masuk"/"Daftar" buttons for space.
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "ROADFIX",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (!isMobile)
                        const Text(
                          "Sistem Pelaporan Jalan Rusak",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/login");
            },
            child: const Text(
              "Masuk",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
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
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < mobileBreakpoint;
            final horizontalPadding = isMobile ? 16.0 : 30.0;
            final heroPadding = isMobile ? 22.0 : 35.0;
            final heroFontSize = isMobile ? 34.0 : 48.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(heroPadding),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: isMobile
                          ? _HeroContent(
                              isMobile: true,
                              heroFontSize: heroFontSize,
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: _HeroContent(
                                    isMobile: false,
                                    heroFontSize: heroFontSize,
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
                                ),
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
            );
          },
        ),
      ),
    );
  }
}

/// The text block + buttons inside the hero card.
/// Shared between the desktop (Row) and mobile (Column) layouts so the
/// content itself never has to change, only its arrangement.
class _HeroContent extends StatelessWidget {
  final bool isMobile;
  final double heroFontSize;

  const _HeroContent({
    required this.isMobile,
    required this.heroFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "LAYANAN PELAPORAN INFRASTRUKTUR JALAN",
          style: TextStyle(
            color: LandingPage.primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          "LIHAT JALAN RUSAK?\nLAPORKAN LEWAT SINI.",
          style: TextStyle(
            color: Colors.white,
            fontSize: heroFontSize,
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "RoadFix membantu masyarakat melaporkan jalan rusak "
          "kepada instansi terkait secara cepat. Unggah lokasi dan foto "
          "kerusakan, kemudian pantau status laporan hingga selesai diperbaiki.",
          style: TextStyle(
            color: Colors.white70,
            height: 1.5,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 30),

        // Mobile: buttons stacked full-width (the standard mobile CTA
        // pattern — much easier to tap than two small side-by-side buttons).
        // Desktop: buttons stay side-by-side as before.
        if (isMobile)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LandingPage.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Buat Laporan"),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade700),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/login");
                  },
                  child: const Text("Lacak Laporan"),
                ),
              ),
            ],
          )
        else
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: LandingPage.primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                icon: const Icon(Icons.add),
                label: const Text("Buat Laporan"),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade700),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/login");
                },
                child: const Text("Lacak Laporan"),
              ),
            ],
          ),
      ],
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
        border: Border.all(color: Colors.white10),
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