import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedDate = DateTime.now();
  int? selectedDay; // ← nullable, default tidak ada yang dipilih

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

  // Cek apakah tanggal ini punya event
  bool _hasEvent(int day) {
    return allEvents.any(
      (e) =>
          e['date'].day == day &&
          e['date'].month == focusedDate.month &&
          e['date'].year == focusedDate.year,
    );
  }

  // Ambil event berdasarkan tanggal yang dipilih
  List<Map<String, dynamic>> _getEventsByDay(int day) {
    return allEvents
        .where(
          (e) =>
              e['date'].day == day &&
              e['date'].month == focusedDate.month &&
              e['date'].year == focusedDate.year,
        )
        .toList();
  }

  // Ambil semua event di bulan yang sedang ditampilkan
  List<Map<String, dynamic>> _getMonthlyEvents() {
    final events = allEvents
        .where(
          (e) =>
              e['date'].month == focusedDate.month &&
              e['date'].year == focusedDate.year,
        )
        .toList();
    events.sort((a, b) => a['date'].compareTo(b['date']));
    return events;
  }

  void _showMonthYearPicker() {
    int currentYear = DateTime.now().year;
    int startYear = currentYear - 5;
    int totalYears = 16;

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
                          setState(() {
                            focusedDate = tempDate;
                            selectedDay =
                                null; // reset pilihan saat ganti bulan
                          });
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

  // Bottom sheet View All — tampil semua event bulan ini
  void _showViewAll() {
    final monthlyEvents = _getMonthlyEvents();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
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
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semua Event ${months[focusedDate.month - 1]} ${focusedDate.year}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: monthlyEvents.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada event di bulan ini',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: monthlyEvents.length,
                        itemBuilder: (context, index) {
                          final event = monthlyEvents[index];
                          DateTime date = event['date'];
                          String dateText =
                              "${date.day} ${months[date.month - 1]} ${date.year}";
                          return _eventTile(
                            dateText,
                            event['title'],
                            event['time'],
                            event['color'],
                          );
                        },
                      ),
              ),
            ],
          ),
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
              () => setState(() {
                focusedDate = DateTime(focusedDate.year, focusedDate.month - 1);
                selectedDay = null; // reset saat ganti bulan
              }),
            ),
            const SizedBox(width: 10),
            _circleNav(
              Icons.chevron_right,
              () => setState(() {
                focusedDate = DateTime(focusedDate.year, focusedDate.month + 1);
                selectedDay = null; // reset saat ganti bulan
              }),
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
        bool hasEvent = _hasEvent(day);

        return GestureDetector(
          onTap: () {
            // Semua tanggal bisa di-tap
            setState(() => selectedDay = day);
          },
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
              if (hasEvent && !isSelected)
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
    // Kalau ada tanggal dipilih → tampil event di tanggal itu
    // Kalau tidak ada → tampil teks info
    final List<Map<String, dynamic>> eventsToShow = selectedDay != null
        ? _getEventsByDay(selectedDay!)
        : [];

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
            GestureDetector(
              onTap:
                  _showViewAll, // ← tap view all buka bottom sheet semua event
              child: Text(
                'View all',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E6AF9),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Kalau belum ada tanggal dipilih
        if (selectedDay == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Icon(Icons.touch_app, color: Colors.grey, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Tap tanggal untuk melihat event',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        // Tanggal dipilih tapi tidak ada event
        else if (eventsToShow.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Icon(Icons.event_busy, color: Colors.grey, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada event di tanggal $selectedDay\n${months[focusedDate.month - 1]} ${focusedDate.year}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        // Tampil event di tanggal yang dipilih
        else
          ...eventsToShow.map((event) {
            DateTime date = event['date'];
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
