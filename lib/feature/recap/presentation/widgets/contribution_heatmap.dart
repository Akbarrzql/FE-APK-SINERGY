import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ContributionHeatMap extends StatelessWidget {
  final Map<DateTime, int> datasets;
  final DateTime endDate;

  const ContributionHeatMap({
    super.key,
    required this.datasets,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Tentukan range tanggal: 365 hari (52 minggu)
    // GitHub graph biasanya berakhir pada hari Sabtu di minggu berjalan
    final DateTime end = DateTime(endDate.year, endDate.month, endDate.day);
    final int endWeekday = end.weekday; // 1 (Sen) - 7 (Min)
    
    // Geser end ke Sabtu terdekat (jika bukan Sabtu) agar grid rapi (GitHub style)
    // Di GitHub, baris terakhir adalah Sabtu. 
    // Tapi di layout kita (7 baris), kita bisa tentukan baris 0 = Minggu atau Senin.
    // Kita gunakan standar: Baris 0 = Minggu, Baris 6 = Sabtu.
    
    final int daysToSaturday = (6 - (end.weekday % 7));
    final DateTime gridEnd = end.add(Duration(days: daysToSaturday));
    
    // Ambil 53 minggu agar mencakup full setahun dengan rapi
    final DateTime gridStart = gridEnd.subtract(const Duration(days: (53 * 7) - 1));
    
    final int weeksCount = 53;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double cellSize = _calculateCellSize(constraints.maxWidth);
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                reverse: true, // Scroll ke ujung kanan (terbaru) secara default
                child: IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMonthLabels(gridStart, weeksCount, cellSize),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDayLabels(cellSize),
                          const SizedBox(width: 8),
                          _buildHeatMapGrid(gridStart, weeksCount, cellSize),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFooter(),
            ],
          ),
        );
      },
    );
  }

  double _calculateCellSize(double maxWidth) {
    // Basic adaptive sizing
    if (maxWidth > 600) return 14.0;
    if (maxWidth > 400) return 12.0;
    return 10.0;
  }

  Widget _buildMonthLabels(DateTime gridStart, int weeksCount, double cellSize) {
    List<Widget> labels = [];
    DateTime current = gridStart;
    int? lastMonth;

    for (int i = 0; i < weeksCount; i++) {
      // Periksa apakah minggu ini adalah awal bulan baru
      if (current.month != lastMonth) {
        labels.add(
          SizedBox(
            width: (cellSize + 3) * 4, // Kira-kira lebar 4 minggu
            child: Text(
              DateFormat.MMM().format(current),
              style: GoogleFonts.poppins(
                color: const Color(0xFF8B949E),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
        lastMonth = current.month;
        // Loncat beberapa minggu agar label tidak tumpang tindih
        i += 3; 
        current = current.add(const Duration(days: 28));
      } else {
        labels.add(SizedBox(width: cellSize + 3));
        current = current.add(const Duration(days: 7));
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 32), // Offset untuk day labels
      child: Row(children: labels),
    );
  }

  Widget _buildDayLabels(double cellSize) {
    final days = ['', 'Mon', '', 'Wed', '', 'Fri', ''];
    return Column(
      children: List.generate(7, (index) {
        return Container(
          height: cellSize + 2, // cell + margin
          alignment: Alignment.centerLeft,
          child: Text(
            days[index],
            style: GoogleFonts.poppins(
              color: const Color(0xFF8B949E),
              fontSize: 9,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeatMapGrid(DateTime gridStart, int weeksCount, double cellSize) {
    return Row(
      children: List.generate(weeksCount, (weekIdx) {
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: Column(
            children: List.generate(7, (dayIdx) {
              final date = gridStart.add(Duration(days: weekIdx * 7 + dayIdx));
              final normalizedDate = DateTime(date.year, date.month, date.day);
              
              // Jika tanggal di masa depan (melebihi endDate), tetap render tapi transparan atau sembunyikan jika mau GitHub style
              // Namun user minta FULL, jadi kita tetap render background kosong jika di masa depan.
              final isFuture = date.isAfter(endDate);
              final count = isFuture ? -1 : (datasets[normalizedDate] ?? 0);

              return Tooltip(
                message: isFuture 
                  ? 'Upcoming' 
                  : '${DateFormat('MMM d, yyyy').format(date)}: $count contributions',
                triggerMode: TooltipTriggerMode.tap,
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.symmetric(vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isFuture ? Colors.transparent : _getColor(count),
                    borderRadius: BorderRadius.circular(2),
                    border: isFuture ? null : Border.all(
                      color: Colors.white.withOpacity(0.05),
                      width: 0.5,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Learn how we count contributions',
          style: GoogleFonts.poppins(
            color: const Color(0xFF8B949E),
            fontSize: 10,
          ),
        ),
        Row(
          children: [
            Text(
              'Less ',
              style: GoogleFonts.poppins(color: const Color(0xFF8B949E), fontSize: 10),
            ),
            _buildLegendBox(0),
            _buildLegendBox(2),
            _buildLegendBox(5),
            _buildLegendBox(8),
            _buildLegendBox(12),
            Text(
              ' More',
              style: GoogleFonts.poppins(color: const Color(0xFF8B949E), fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendBox(int count) {
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      decoration: BoxDecoration(
        color: _getColor(count),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Color _getColor(int count) {
    if (count == -1) return Colors.transparent;
    if (count == 0) return const Color(0xFF161B22);
    if (count < 3) return const Color(0xFF0E4429);
    if (count < 6) return const Color(0xFF006D32);
    if (count < 10) return const Color(0xFF26A641);
    return const Color(0xFF39D353);
  }
}
