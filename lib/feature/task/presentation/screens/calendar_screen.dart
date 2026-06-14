import 'package:flutter/material.dart';
import 'package:gabungyuk/core/widget/loading_shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gabungyuk/feature/task/data/models/calendar_event_model.dart';
import 'package:gabungyuk/feature/task/data/repositories/calendar_repository.dart';
import 'package:gabungyuk/feature/home/service/collaboration_service.dart';
import 'package:gabungyuk/feature/home/presentation/detail_collaboration.dart';
import 'package:gabungyuk/core/common/app_ui_helper.dart';
import 'package:gabungyuk/feature/profile/repository/profile_repository.dart';
import 'package:gabungyuk/feature/home/model/view_project_model.dart';
import 'package:gabungyuk/feature/profile/model/view_profile_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../home/model/detail_project_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarRepository _repository = CalendarRepositoryImpl();
  final CollaborationService _collaborationService = CollaborationService();
  final ProfileRepository _profileRepository = ProfileRepositoryImpl();
  DateTime focusedDate = DateTime.now();
  int? selectedDay;
  
  late Future<CalendarEventModel> _calendarFuture;
  Set<int>? _myProjectIds;

  @override
  void initState() {
    super.initState();
    _fetchMyProjects();
    _loadEvents();
  }

  Future<void> _fetchMyProjects() async {
    try {
      final myProjects = await _collaborationService.getMyProjects();
      if (mounted) {
        setState(() {
          _myProjectIds = myProjects.map((p) => p.id).toSet();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _myProjectIds = {};
        });
      }
    }
  }

  void _loadEvents() {
    setState(() {
      _calendarFuture = _repository.fetchCalendarEvents(
        focusedDate.year,
        focusedDate.month,
      );
    });
  }

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

  bool _hasEvent(int day, List<CalendarEvent> events) {
    return events.any((e) => e.deadline.day == day);
  }

  List<CalendarEvent> _getEventsByDay(int day, List<CalendarEvent> events) {
    return events.where((e) => e.deadline.day == day).toList();
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
                                  () => tempDate = DateTime(year, tempDate.month),
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
                                  () => tempDate = DateTime(tempDate.year, index + 1),
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
                            selectedDay = null;
                          });
                          _loadEvents();
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

  void _showViewAll(List<CalendarEvent> monthlyEvents) {
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                          String dateText = "${event.deadline.day} ${months[event.deadline.month - 1]} ${event.deadline.year}";
                          return GestureDetector(
                            onTap: () => _navigateToProjectDetail(event.projectId),
                            child: _eventTile(
                              dateText,
                              event.title,
                              event.time,
                              event.color,
                              event.isDone,
                            ),
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

  Future<void> _navigateToProjectDetail(int projectId) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Fetch project detail
      final detailModel =
          await _collaborationService.getProjectDetail(projectId);
      final profile = await _profileRepository.getViewProfile();

      if (mounted) {
        Navigator.pop(context); // Pop loading

        final project = detailModel.data.project;
        final collaborators = detailModel.data.collaborators;

        // Cari owner yang sebenarnya dari daftar kolaborator
        final ownerCollab = collaborators.firstWhere(
          (c) => c.role.toUpperCase() == 'OWNER',
          orElse: () => Collaborator(
            collaborationId: 0,
            idPengguna: 0,
            namaLengkap: 'Unknown Owner',
            email: '',
            institusi: '',
            bio: '',
            keahlian: '',
            lokasi: '',
            role: 'OWNER',
            status: '',
            requestStatus: '',
          ),
        );
        
        // Map Project to Datum for DetailCollaboration
        final datum = Datum(
          id: project.projectId,
          title: project.title,
          description: project.description,
          category: project.category,
          status: project.status,
          repositoryLink: project.repositoryLink,
          projectPicture: project.projectPicture,
          deadline: project.deadline,
          owner: Owner(
            id: ownerCollab.idPengguna,
            fullName: ownerCollab.namaLengkap,
            email: ownerCollab.email,
            profilePicture: ownerCollab.profilePicture,
          ),
          collaborators: [],
        );

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailCollaboration(
              project: datum,
              owner: profile,
            ),
          ),
        );
        _loadEvents();
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.canPop(context)) Navigator.pop(context); // Pop loading
        AppUiHelper.showError(context, AppUiHelper.readableError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CalendarEventModel>(
      future: _calendarFuture,
      builder: (context, snapshot) {
        List<CalendarEvent> events = snapshot.data?.data ?? [];
        // Pastikan kita menunggu daftar project saya agar filter role bekerja dengan benar
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting || _myProjectIds == null;
        final bool hasError = snapshot.hasError;

        // Terapkan logika filter: sembunyikan event yang sudah selesai jika user bukan owner
        if (_myProjectIds != null) {
          events = events.where((event) {
            final isOwner = _myProjectIds!.contains(event.projectId);
            // Jika project selesai (DONE/COMPLETED) dan user BUKAN owner, maka sembunyikan
            if (!isOwner && event.isDone) {
              return false;
            }
            return true;
          }).toList();
        }

        return RefreshIndicator(
          onRefresh: () async => _loadEvents(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      isLoading
                          ? _buildShimmerCalendar()
                          : hasError
                              ? Center(child: Text("Gagal memuat data", style: GoogleFonts.poppins(color: Colors.white)))
                              : _buildCalendarGrid(events),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildEventSection(events, isLoading),
              ],
            ),
          ),
        );
      },
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
              () {
                setState(() {
                  focusedDate = DateTime(focusedDate.year, focusedDate.month - 1);
                  selectedDay = null;
                });
                _loadEvents();
              },
            ),
            const SizedBox(width: 10),
            _circleNav(
              Icons.chevron_right,
              () {
                setState(() {
                  focusedDate = DateTime(focusedDate.year, focusedDate.month + 1);
                  selectedDay = null;
                });
                _loadEvents();
              },
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
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  Widget _buildShimmerCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
      ),
      itemCount: 35,
      itemBuilder: (context, index) => Center(
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.3),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEvents() {
    return Column(
      children: List.generate(3, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            const LoadingShimmer(width: 4, height: 50, borderRadius: 10),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LoadingShimmer(width: 80, height: 10),
                  const SizedBox(height: 8),
                  const LoadingShimmer(width: double.infinity, height: 14),
                  const SizedBox(height: 4),
                  const LoadingShimmer(width: 60, height: 11),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildWeekDays() {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) => Text(
        day,
        style: GoogleFonts.poppins(
          color: Colors.white60,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid(List<CalendarEvent> events) {
    int daysInMonth = DateTime(focusedDate.year, focusedDate.month + 1, 0).day;
    int firstDayWeekday = DateTime(focusedDate.year, focusedDate.month, 1).weekday;
    
    // Sesuaikan offset jika minggu dimulai dari Senin (1)
    int offset = firstDayWeekday - 1;

    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 10,
      ),
      itemCount: daysInMonth + offset,
      itemBuilder: (context, index) {
        if (index < offset) return const SizedBox.shrink();
        
        int day = index - offset + 1;
        bool isSelected = day == selectedDay;
        List<CalendarEvent> dayEvents = _getEventsByDay(day, events);
        bool hasEvent = dayEvents.isNotEmpty;
        bool allDone = hasEvent && dayEvents.every((e) => e.isDone);
        bool isToday = day == now.day && 
            focusedDate.month == now.month && 
            focusedDate.year == now.year;

        return GestureDetector(
          onTap: () {
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
                  border: isToday && !isSelected
                      ? Border.all(color: Colors.white, width: 1.5)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: (isSelected || isToday) ? FontWeight.bold : FontWeight.normal,
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
                  decoration: BoxDecoration(
                    color: allDone ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventSection(List<CalendarEvent> allEvents, bool isLoading) {
    final List<CalendarEvent> eventsToShow = selectedDay != null
        ? _getEventsByDay(selectedDay!, allEvents)
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
              onTap: () => _showViewAll(allEvents),
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

        if (isLoading && allEvents.isEmpty)
          _buildShimmerEvents()
        else if (selectedDay == null)
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
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
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
                    style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        else
          ...eventsToShow.map((event) {
            String dateText = "${event.deadline.day} ${months[event.deadline.month - 1]} ${event.deadline.year}";
            return GestureDetector(
              onTap: () => _navigateToProjectDetail(event.projectId),
              child: _eventTile(
                dateText,
                event.title,
                event.time,
                event.color,
                event.isDone,
              ),
            );
          }),
      ],
    );
  }

  Widget _eventTile(String date, String title, String time, Color tagColor, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: isDone ? Colors.green : tagColor,
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, 
                          fontSize: 14,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isDone) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Selesai",
                          style: GoogleFonts.poppins(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
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
