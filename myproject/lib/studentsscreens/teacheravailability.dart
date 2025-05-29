import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myproject/studentsscreens/bookingsessionscreen.dart';

class SessionSchedulingScreen extends StatefulWidget {
  const SessionSchedulingScreen({Key? key}) : super(key: key);

  @override
  State<SessionSchedulingScreen> createState() =>
      _SessionSchedulingScreenState();
}

class _SessionSchedulingScreenState extends State<SessionSchedulingScreen> {
  // Selected duration, date and time
  int _selectedDuration = 30;
  DateTime _selectedDate =
      DateTime.now().add(const Duration(days: 2)); // Default to 2 days from now
  String? _selectedTime;
  // Available time slots
  final Map<String, List<String>> _timeSlots = {
    'Morning': ['9 AM', '9:30 AM', '11 AM', '11:30 AM'],
    'Afternoon': ['2:30 PM', '3:30 PM', '4:00 PM'],
    'Evening': ['6:30 PM', '7:30 PM', '8:00 PM', '8:30 PM'],
  };

  // Calendar date range
  final DateTime _startDate = DateTime(2025, 5, 1);
  final DateTime _endDate = DateTime(2025, 5, 15);

  List<DateTime> _getDaysInMonth() {
    List<DateTime> days = [];
    DateTime current = _startDate;

    while (current.isBefore(_endDate.add(const Duration(days: 1)))) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  bool _isDateSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Session title and description
                const Text(
                  '30 min session',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'To discuss your learning plan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),

                // Duration selection
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDuration = 30;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDuration == 30
                              ? Color.fromARGB(255, 255, 144, 187)
                              : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          '30 min',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedDuration = 60;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedDuration == 60
                              ? Color.fromARGB(255, 255, 144, 187)
                              : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          '60 min',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Calendar month header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'May 2025',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Color.fromARGB(255, 255, 144, 187),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar weekday headers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (final day in [
                      'Fri',
                      'Sat',
                      'Sun',
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat'
                    ])
                      SizedBox(
                        width: 32,
                        child: Text(
                          day,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: day == 'Sat'
                                ? Color.fromARGB(255, 255, 144, 187)
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Calendar date selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int i = 1; i <= 9; i++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Using simplified date selection for the demo
                            _selectedDate = DateTime(2025, 5, i);
                            // Clear time selection when date changes
                            _selectedTime = null;
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == 2
                                ? Color.fromARGB(255, 255, 144, 187)
                                : Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              '$i',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: i == 2 ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // Time zone selection
                const Text(
                  'Select the time zone according to your country',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Morning time slots
                _buildTimePeriodSection('Morning', Icons.wb_sunny_outlined),
                const SizedBox(height: 16),

                // Afternoon time slots
                _buildTimePeriodSection('Afternoon', Icons.wb_sunny),
                const SizedBox(height: 16),

                // Evening time slots
                _buildTimePeriodSection('Evening', Icons.nights_stay_outlined),
                const SizedBox(height: 24),

                // Schedule button - CORRECTED CODE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedTime != null
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const BookingSessionScreen(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 144, 187),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 10),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child: const Text(
                      'Schedule session',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Add bottom padding to ensure content is visible above any system UI
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimePeriodSection(String period, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              period,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            for (final time in _timeSlots[period]!)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTime = time;
                  });
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width - 48) / 2,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedTime == time
                          ? Color.fromARGB(255, 255, 144, 187)
                          : Colors.grey[300]!,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _selectedTime == time
                        ? Color.fromARGB(255, 255, 144, 187)
                        : Colors.transparent,
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.black,
                      fontWeight: _selectedTime == time
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _handleScheduleSession() {
    // Implement scheduling logic
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy');
    final scheduledDate = dateFormat.format(_selectedDate);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Session scheduled for $scheduledDate at $_selectedTime'),
        backgroundColor: Color.fromARGB(255, 255, 144, 187),
      ),
    );
  }
}
