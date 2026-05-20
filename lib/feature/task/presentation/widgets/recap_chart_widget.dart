import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RecapChartWidget extends StatelessWidget {
  final String totalDurasi;
  final String activeFilter;
  final List grafikList;

  const RecapChartWidget({
    super.key,
    required this.totalDurasi,
    required this.activeFilter,
    required this.grafikList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$totalDurasi Kontribusi",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_downward, color: Colors.blue, size: 24),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            activeFilter == 'mingguan'
                ? 'Total kontribusimu dalam proyek minggu ini'
                : 'Total kontribusimu dalam proyek bulan ini',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 155,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 120, // Catatan: Sesuaikan maxY ini dengan skala datamu
                barGroups: List.generate(grafikList.length, (index) {
                  final Map<String, dynamic> item = Map<String, dynamic>.from(
                    grafikList[index],
                  );

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (item['value'] as num).toDouble(),
                        color: Colors.blue,
                        width: 18,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final int index = value.toInt();
                        if (index >= 0 && index < grafikList.length) {
                          final Map<String, dynamic> item =
                              Map<String, dynamic>.from(grafikList[index]);

                          return SideTitleWidget(
                            meta: meta,
                            space: 8,
                            child: Text(
                              item['label'].toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
