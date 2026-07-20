import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../controllers/laporan_controller.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../widgets/card_container.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/bar_trend_chart.dart';
import '../../widgets/laporan_terbaru_item.dart';

/// Route: '/admin/dashboard'
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = LaporanController.instance;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          const Sidebar(currentRoute: '/admin/dashboard'),
          Expanded(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TopBar(
                      breadcrumb: 'PORTAL ADMIN / DINAS',
                      title: 'DASHBOARD',
                      trailing: SearchAndAvatar(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kartu statistik — dihitung langsung dari data laporan
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'TOTAL LAPORAN',
                                    value: '${controller.total}',
                                    note: 'Data saat ini',
                                    noteColor: AppColors.green,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'MENUNGGU VERIFIKASI',
                                    value: '${controller.menungguVerifikasi}',
                                    note: 'Perlu ditinjau',
                                    noteColor: AppColors.gold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'SEDANG DIPROSES',
                                    value: '${controller.sedangDiproses}',
                                    note: 'Ditangani tim',
                                    noteColor: AppColors.blue,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'SELESAI',
                                    value: '${controller.selesai}',
                                    note: controller.total == 0
                                        ? '0% dari total'
                                        : '${((controller.selesai / controller.total) * 100).round()}% dari total',
                                    noteColor: AppColors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Chart + Laporan terbaru
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: CardContainer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          const SizedBox(
                                            height: 220,
                                            child: BarTrendChart(
                                              values: [58, 66, 40, 82, 74, 96],
                                              labels: [
                                                'Feb',
                                                'Mar',
                                                'Apr',
                                                'Mei',
                                                'Jun',
                                                'Jul',
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: CardContainer(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              style: TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                            )
                                          else
                                            for (
                                              int i = 0;
                                              i < controller.terbaru.length;
                                              i++
                                            ) ...[
                                              LaporanTerbaruItem(
                                                judul:
                                                    controller.terbaru[i].judul,
                                                lokasi: controller
                                                    .terbaru[i]
                                                    .pelapor,
                                                status: controller
                                                    .terbaru[i]
                                                    .status,
                                                color: controller
                                                    .terbaru[i]
                                                    .statusColor,
                                              ),
                                              if (i !=
                                                  controller.terbaru.length - 1)
                                                const Divider(
                                                  color: AppColors.cardBorder,
                                                  height: 24,
                                                ),
                                            ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
