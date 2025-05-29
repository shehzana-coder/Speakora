import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  double _totalRevenue = 0.0;
  double _completionRate = 0.0;
  List<Map<String, dynamic>> _studentGrowth = [];
  List<Map<String, dynamic>> _teacherGrowth = [];
  List<Map<String, dynamic>> _topCourses = [];
  String _selectedPeriod = 'Last 30 Days';
  final List<String> _periods = [
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'All Time'
  ];

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Determine time range
      DateTime? startDate;
      switch (_selectedPeriod) {
        case 'Last 30 Days':
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case 'Last 3 Months':
          startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        case 'Last 6 Months':
          startDate = DateTime.now().subtract(const Duration(days: 180));
          break;
        case 'All Time':
          startDate = null;
          break;
      }

      // Fetch sessions
      Query<Map<String, dynamic>> sessionsQuery =
          _firestore.collection('sessions');
      if (startDate != null) {
        sessionsQuery = sessionsQuery.where('dateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      final sessionsSnapshot = await sessionsQuery.get();

      // Calculate revenue and completion rate
      double revenue = 0.0;
      int completedSessions = 0;
      int totalSessions = sessionsSnapshot.size;
      Map<String, int> courseCounts = {};

      for (var doc in sessionsSnapshot.docs) {
        final data = doc.data();
        if (data['status'] == 'completed') {
          completedSessions++;
          revenue += (data['price'] as num?)?.toDouble() ?? 0.0;
        }
        final course = data['course'] ?? 'Unknown';
        courseCounts[course] = (courseCounts[course] ?? 0) + 1;
      }

      // Fetch user growth
      Query<Map<String, dynamic>> studentsQuery =
          _firestore.collection('students');
      Query<Map<String, dynamic>> teachersQuery =
          _firestore.collection('teachers');
      if (startDate != null) {
        studentsQuery = studentsQuery.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
        teachersQuery = teachersQuery.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      final studentsSnapshot = await studentsQuery.get();
      final teachersSnapshot = await teachersQuery.get();

      // Group growth by month
      Map<String, int> studentGrowthMap = {};
      Map<String, int> teacherGrowthMap = {};
      final now = DateTime.now();
      final months = _selectedPeriod == 'All Time'
          ? 12
          : (_selectedPeriod == 'Last 6 Months' ? 6 : 3);

      for (int i = 0; i < months; i++) {
        final monthDate = DateTime(now.year, now.month - i, 1);
        final monthKey = DateFormat('MMM yyyy').format(monthDate);
        studentGrowthMap[monthKey] = 0;
        teacherGrowthMap[monthKey] = 0;
      }

      for (var doc in studentsSnapshot.docs) {
        final createdAt = (doc['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) {
          final monthKey = DateFormat('MMM yyyy').format(createdAt);
          if (studentGrowthMap.containsKey(monthKey)) {
            studentGrowthMap[monthKey] = studentGrowthMap[monthKey]! + 1;
          }
        }
      }

      for (var doc in teachersSnapshot.docs) {
        final createdAt = (doc['createdAt'] as Timestamp?)?.toDate();
        if (createdAt != null) {
          final monthKey = DateFormat('MMM yyyy').format(createdAt);
          if (teacherGrowthMap.containsKey(monthKey)) {
            teacherGrowthMap[monthKey] = teacherGrowthMap[monthKey]! + 1;
          }
        }
      }

      // Prepare top courses
      final topCourses = courseCounts.entries
          .map((e) => {'course': e.key, 'count': e.value})
          .toList()
          .sublist(0, courseCounts.length > 5 ? 5 : courseCounts.length);

      setState(() {
        _totalRevenue = revenue;
        _completionRate =
            totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0;
        _studentGrowth = studentGrowthMap.entries
            .map((e) => {'month': e.key, 'count': e.value})
            .toList()
            .reversed
            .toList();
        _teacherGrowth = teacherGrowthMap.entries
            .map((e) => {'month': e.key, 'count': e.value})
            .toList()
            .reversed
            .toList();
        _topCourses = topCourses;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching analytics: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error loading analytics: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodFilter(),
                  const SizedBox(height: 16),
                  _buildMetricsCards(),
                  const SizedBox(height: 24),
                  _buildGrowthChart(),
                  const SizedBox(height: 24),
                  _buildPieChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodFilter() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButtonFormField(
          value: _selectedPeriod,
          items: _periods
              .map((period) => DropdownMenuItem(
                    value: period,
                    child: Text(period, style: GoogleFonts.poppins()),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPeriod = value! as String;
              _fetchAnalytics();
            });
          },
          decoration: InputDecoration(
            labelText: 'Time Period',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue[600]!),
            ),
            filled: true,
            fillColor: Colors.blue[50],
          ),
          style: GoogleFonts.poppins(),
        ));
  }

  Widget _buildMetricsCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          title: 'Total Revenue',
          value: _totalRevenue.toStringAsFixed(2),
          icon: Icons.attach_money,
          color: Colors.green,
          subtitle: 'From completed sessions',
        ),
        _buildMetricCard(
          title: 'Session Completion',
          value: '${_completionRate.toStringAsFixed(1)}%',
          icon: Icons.check_circle,
          color: Colors.blue,
          subtitle: 'Completed vs. total sessions',
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Growth',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _studentGrowth.isEmpty
                  ? Center(
                      child: Text(
                        'No growth data available',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: [
                              ..._studentGrowth.map((e) => e['count'] as int),
                              ..._teacherGrowth.map((e) => e['count'] as int),
                            ]
                                .fold<int>(
                                    0,
                                    (prev, count) =>
                                        count > prev ? count : prev)
                                .toDouble() *
                            1.2,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= _studentGrowth.length) {
                                  return const SizedBox();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: Text(
                                    _studentGrowth[index]['month']
                                        .split(' ')[0],
                                    style: GoogleFonts.poppins(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barGroups:
                            List.generate(_studentGrowth.length, (index) {
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: (_studentGrowth[index]['count'] as int)
                                    .toDouble(),
                                color: Colors.blue,
                                width: 12,
                              ),
                              BarChartRodData(
                                toY: (_teacherGrowth[index]['count'] as int)
                                    .toDouble(),
                                color: Colors.green,
                                width: 12,
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(color: Colors.blue, label: 'Students'),
                const SizedBox(width: 16),
                _buildLegend(color: Colors.green, label: 'Teachers'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _buildPieChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Courses by Enrollment',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _topCourses.isEmpty
                  ? Center(
                      child: Text(
                        'No course data available',
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: Colors.grey[600]),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: _topCourses.asMap().entries.map((entry) {
                          final index = entry.key;
                          final course = entry.value;
                          return PieChartSectionData(
                            color: _getPieColor(index),
                            value: (course['count'] as int).toDouble(),
                            title: '${course['course']}\n${course['count']}',
                            radius: 60,
                            titleStyle: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPieColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }
}
