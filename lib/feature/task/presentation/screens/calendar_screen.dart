import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 1. STATE LOGIKA
  DateTime focusedDate = DateTime.now();
  int selectedDay = DateTime.now().day;

  // 2. DATA MASTER EVENT (Model Data)
  // Ini adalah sumber data tunggal. Titik di kalender dan daftar di bawah akan mengambil dari sini.
  final List<Map<String, dynamic>> allEvents = [
    {
      "date": DateTime(2026, 5, 12),
      "title": "Analisis Data Keuangan",
      "time": "09.00 WIB",
      "color": const Color(0xFF1E6AF9),
    },
    {
      "date": DateTime(2026, 5, 22),
      "title": "Deadline Task #30",
      "time": "23.00 WIB",
      "color": const Color(0xFF1E6AF9),
    },
    {
      "date": DateTime(2026, 5, 24),
      "title": "Pengecekan Fitur Chat",
      "time": "12.00 WIB",
      "color": Colors.orange,
    },
    {
      "date": DateTime(2026, 6, 10),
      "title": "Review UI/UX MountOne",
      "time": "14.00 WIB",
      "color": Colors.green,
    },
    {
      "date": DateTime(2026, 6, 11),
      "title": "Assigmen Impal",
      "time": "23.49 WIB",
      "color": const Color.fromARGB(255, 70, 1, 3),
    },
  ];

  final List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  void _showMonthYearPicker() {
    int currentYear = DateTime.now().year;
    int startYear = currentYear - 5;
    int totalYears = 5 + 1 + 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        DateTime tempDate = focusedDate;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 10),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: totalYears,
                            itemBuilder: (context, index) {
                              int year = startYear + index;
                              bool isSelected = year == tempDate.year;
                              return ListTile(
                                title: Center(
                                  child: Text(
                                    "$year",
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? const Color(0xFF1E6AF9)
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                onTap: () => setModalState(
                                  () =>
                                      tempDate = DateTime(year, tempDate.month),
                                ),
                              );
                            },
                          ),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 12,
                            itemBuilder: (context, index) {
                              bool isSelected = (index + 1) == tempDate.month;
                              return ListTile(
                                title: Center(
                                  child: Text(
                                    months[index],
                                    style: GoogleFonts.poppins(
                                      color: isSelected
                                          ? const Color(0xFF1E6AF9)
                                          : Colors.black,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                onTap: () => setModalState(
                                  () => tempDate = DateTime(
                                    tempDate.year,
                                    index + 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E6AF9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          setState(() => focusedDate = tempDate);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Confirm",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E6AF9), Color(0xFF1652C9)],
              ),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendarHeader(),
                const SizedBox(height: 5),
                Text(
                  'Check your monthly schedule',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 30),
                _buildWeekDays(),
                const SizedBox(height: 15),
                _buildCalendarGrid(),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildEventSection(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: _showMonthYearPicker,
          child: Row(
            children: [
              Text(
                '${months[focusedDate.month - 1]} ${focusedDate.year}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        Row(
          children: [
            _circleNav(
              Icons.chevron_left,
              () => setState(
                () => focusedDate = DateTime(
                  focusedDate.year,
                  focusedDate.month - 1,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _circleNav(
              Icons.chevron_right,
              () => setState(
                () => focusedDate = DateTime(
                  focusedDate.year,
                  focusedDate.month + 1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _circleNav(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  Widget _buildWeekDays() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days
          .map(
            (day) => Text(
              day,
              style: GoogleFonts.poppins(
                color: Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    int daysInMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        int day = index + 1;
        bool isSelected = day == selectedDay;

        // Logika Titik: Cek apakah ada event di tanggal, bulan, dan tahun ini
        bool hasTask = allEvents.any(
          (e) =>
              e['date'].day == day &&
              e['date'].month == focusedDate.month &&
              e['date'].year == focusedDate.year,
        );

        return GestureDetector(
          onTap: () => setState(() => selectedDay = day),
          child: Column(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (hasTask && !isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventSection() {
    // FILTER: Hanya ambil event yang bulan dan tahunnya sesuai dengan kalender
    final monthlyEvents = allEvents
        .where(
          (e) =>
              e['date'].month == focusedDate.month &&
              e['date'].year == focusedDate.year,
        )
        .toList();

    // Urutkan berdasarkan tanggal terkecil
    monthlyEvents.sort((a, b) => a['date'].compareTo(b['date']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              'View all',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E6AF9),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (monthlyEvents.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "No events for this month",
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
          )
        else
          ...monthlyEvents.map((event) {
            DateTime date = event['date'];
            // Format tanggal Indonesia sederhana
            String dateText =
                "${date.day} ${months[date.month - 1]} ${date.year}";

            return _eventTile(
              dateText,
              event['title'],
              event['time'],
              event['color'],
            );
          }).toList(),
      ],
    );
  }

  Widget _eventTile(String date, String title, String time, Color tagColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
                ),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
