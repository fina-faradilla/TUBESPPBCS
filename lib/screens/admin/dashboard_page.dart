import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../controllers/laporan_controller.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/card_container.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/bar_trend_chart.dart';
import '../../widgets/laporan_terbaru_item.dart';
import '../../utils/responsive.dart';

/// Route: '/admin/dashboard'
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final LaporanController controller = LaporanController.instance;

  @override
  void initState() {
    super.initState();
    // Muat data laporan asli dari database saat dashboard dibuka, supaya
    // statistik & grafik tidak kosong kalau pengguna belum pernah membuka
    // halaman "Kelola Laporan" sebelumnya.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.muatData());
  }

  @override
  Widget build(BuildContext context) {
    final bool mobile = isMobileWidth(context);
    final double pagePad = mobile ? 16 : 28;

    final Widget content = AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final statCards = [
          StatCard(
            title: 'TOTAL LAPORAN',
            value: '${controller.total}',
            note: 'Data saat ini',
            noteColor: AppColors.green,
          ),
          StatCard(
            title: 'MENUNGGU VERIFIKASI',
            value: '${controller.menungguVerifikasi}',
            note: 'Perlu ditinjau',
            noteColor: AppColors.gold,
          ),
          StatCard(
            title: 'SEDANG DIPROSES',
            value: '${controller.sedangDiproses}',
            note: 'Ditangani tim',
            noteColor: AppColors.blue,
          ),
          StatCard(
            title: 'SELESAI',
            value: '${controller.selesai}',
            note: controller.total == 0
                ? '0% dari total'
                : '${((controller.selesai / controller.total) * 100).round()}% dari total',
            noteColor: AppColors.green,
          ),
        ];

        // Di laptop: 4 kartu sejajar dalam satu baris.
        // Di HP: grid 2x2 supaya tiap kartu tetap cukup lebar untuk dibaca.
        final Widget statSection = mobile
            ? Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: statCards[0]),
                      const SizedBox(width: 12),
                      Expanded(child: statCards[1]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: statCards[2]),
                      const SizedBox(width: 12),
                      Expanded(child: statCards[3]),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: statCards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: statCards[1]),
                  const SizedBox(width: 16),
                  Expanded(child: statCards[2]),
                  const SizedBox(width: 16),
                  Expanded(child: statCards[3]),
                ],
              );

        final trenCard = CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TREN LAPORAN PER BULAN',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 220,
                child: (controller.isLoading && controller.total == 0)
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.gold,
                        ),
                      )
                    : BarTrendChart(
                        values: controller.trenBulananValues
                            .map((v) => v.toDouble())
                            .toList(),
                        labels: controller.trenBulananLabels,
                      ),
              ),
            ],
          ),
        );

        final terbaruCard = CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LAPORAN TERBARU',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              if (controller.terbaru.isEmpty)
                const Text(
                  'Belum ada laporan.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                )
              else
                for (int i = 0; i < controller.terbaru.length; i++) ...[
                  LaporanTerbaruItem(
                    judul: controller.terbaru[i].judul,
                    lokasi: controller.terbaru[i].pelapor,
                    status: controller.terbaru[i].status,
                    color: controller.terbaru[i].statusColor,
                  ),
                  if (i != controller.terbaru.length - 1)
                    const Divider(color: AppColors.cardBorder, height: 24),
                ],
            ],
          ),
        );

        // Di laptop: chart & laporan terbaru sejajar (3:2).
        // Di HP: ditumpuk vertikal supaya masing-masing tetap lega.
        final Widget bottomSection = mobile
            ? Column(
                children: [
                  trenCard,
                  const SizedBox(height: 16),
                  terbaruCard,
                ],
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: trenCard),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: terbaruCard),
                  ],
                ),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBar(
              breadcrumb: 'PORTAL ADMIN / DINAS',
              title: 'DASHBOARD',
              trailing: mobile ? null : const SearchAndAvatar(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(pagePad, 8, pagePad, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    statSection,
                    const SizedBox(height: 20),
                    bottomSection,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (mobile) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.sidebarBg,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text('RoadFix',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16)),
        ),
        drawer: const Drawer(
          backgroundColor: Colors.transparent,
          child: Sidebar(currentRoute: '/admin/dashboard'),
        ),
        body: content,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/dashboard'),
          Expanded(child: content),
        ],
      ),
    );
  }
}