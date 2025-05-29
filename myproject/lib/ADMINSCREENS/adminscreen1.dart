import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'studentsscreen.dart'; // Adjust import path
import 'verifiedteacherscreen.dart'; // Placeholder
import 'notverifiedteacherscreen.dart'; // Placeholder
import 'sessionscreen.dart'; // Placeholder
import 'analyticalscreen.dart'; // Placeholder
import 'settingscreen.dart'; // Placeholder
import 'coursescreen.dart';
import 'dart:async'; // Added for timer
import 'notificationscreen.dart'; // Placeholder

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedPage = 'Dashboard';
  bool _isLoading = true;
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _recentActivities = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Fetch stats
      final studentsSnapshot = await _firestore.collection('students').get();
      final coursesSnapshot = await _firestore.collection('courses').get();
      final teachersSnapshot = await _firestore.collection('teachers').get();
      final notVerifiedTeachersSnapshot =
          await _firestore.collection('teachers_not_verified').get();
      final sessionsSnapshot = await _firestore.collection('sessions').get();
      final activeSessionsSnapshot = await _firestore
          .collection('sessions')
          .where('status', isEqualTo: 'active')
          .get();

      // Fetch new registrations (last 7 days)
      final oneWeekAgo =
          Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7)));
      final newStudentsSnapshot = await _firestore
          .collection('students')
          .where('createdAt', isGreaterThanOrEqualTo: oneWeekAgo)
          .get();
      final newTeachersSnapshot = await _firestore
          .collection('teachers_not_verified')
          .where('createdAt', isGreaterThanOrEqualTo: oneWeekAgo)
          .get();

      // Fetch recent activities from admin_logs
      final activitiesSnapshot = await _firestore
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      setState(() {
        _stats = {
          'totalStudents': studentsSnapshot.size,
          'totalCourses': coursesSnapshot.size,
          'totalTeachers':
              teachersSnapshot.size + notVerifiedTeachersSnapshot.size,
          'verifiedTeachers': teachersSnapshot.size,
          'notVerifiedTeachers': notVerifiedTeachersSnapshot.size,
          'activeSessions': activeSessionsSnapshot.size,
          'totalSessions': sessionsSnapshot.size,
          'newRegistrations':
              newStudentsSnapshot.size + newTeachersSnapshot.size,
          'pendingApprovals': notVerifiedTeachersSnapshot.size,
        };

        _recentActivities = activitiesSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'type': data['action'],
            'message': data['details'] ?? 'No details',
            'time': _formatTimestamp(data['timestamp']),
            'icon': _getActivityIcon(data['action']),
            'color': _getActivityColor(data['action']),
          };
        }).toList();

        _isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final now = DateTime.now();
    final date = timestamp.toDate();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    return '${difference.inDays} days ago';
  }

  IconData _getActivityIcon(String action) {
    switch (action) {
      case 'teacher_profile_completed':
        return Icons.person_add;
      case 'new_student':
        return Icons.school;
      case 'session_completed':
        return Icons.check_circle;
      case 'verification_approved':
        return Icons.verified;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String action) {
    switch (action) {
      case 'teacher_profile_completed':
        return Colors.orange;
      case 'new_student':
        return Colors.blue;
      case 'session_completed':
        return Colors.green;
      case 'verification_approved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              if (_stats['pendingApprovals'] != null &&
                  _stats['pendingApprovals']! > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_stats['pendingApprovals']}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _buildDashboardContent(),
    );
  }

  Widget _buildDrawer() {
    final navigationItems = [
      {'title': 'Dashboard', 'icon': Icons.dashboard, 'page': 'Dashboard'},
      {
        'title': 'Verified Teachers',
        'icon': Icons.verified_user,
        'page': 'Verified Teachers'
      },
      {
        'title': 'Not Verified Teachers',
        'icon': Icons.person_off,
        'page': 'Not Verified Teachers'
      },
      {'title': 'Students', 'icon': Icons.school, 'page': 'Students'},
      {'title': 'Courses', 'icon': Icons.book, 'page': 'Courses'},
      {'title': 'Sessions', 'icon': Icons.calendar_today, 'page': 'Sessions'},
      {'title': 'Analytics', 'icon': Icons.analytics, 'page': 'Analytics'},
      {'title': 'Settings', 'icon': Icons.settings, 'page': 'Settings'},
    ];

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.apple, color: Colors.blue[600], size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Speakora Platform',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: navigationItems.length,
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final isSelected = _selectedPage == item['page'];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? Colors.blue[50] : Colors.white,
                  ),
                  child: ListTile(
                    leading: Icon(item['icon'] as IconData,
                        color:
                            isSelected ? Colors.blue[600] : Colors.grey[600]),
                    title: Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue[600] : Colors.grey[800],
                      ),
                    ),
                    onTap: () => _navigateToPage(item['page'] as String),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCards(),
          const SizedBox(height: 24),
          _buildQuickActionsAndActivity(),
          const SizedBox(height: 24),
          _buildAdditionalStats(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return _AnimatedStatsCards(stats: _stats);
  }

  Widget _buildQuickActionsAndActivity() {
    return Column(
      children: [
        _buildQuickActions(),
        const SizedBox(height: 16),
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            _buildQuickActionItem(
              'Review Pending Teachers',
              Icons.person_off,
              Colors.orange,
              _stats['notVerifiedTeachers'],
              () => _navigateToPage('Not Verified Teachers'),
            ),
            const SizedBox(height: 8),
            _buildQuickActionItem(
              'Manage Students',
              Icons.school,
              Colors.blue,
              null,
              () => _navigateToPage('Students'),
            ),
            const SizedBox(height: 8),
            _buildQuickActionItem(
              'Manage Courses',
              Icons.book,
              Colors.purple,
              null,
              () => _navigateToPage('Courses'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String title, IconData icon, Color color,
      int? count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                    // ignore: deprecated_member_use
                    fontWeight: FontWeight.w500,
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.8)),
              ),
            ),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            ..._recentActivities
                .map((activity) => _buildActivityItem(activity))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(activity['icon'], color: activity['color'], size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['message'],
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['time'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats() {
    return Row(
      children: [
        Expanded(child: _buildVerificationChart()),
        const SizedBox(width: 16),
        Expanded(child: _buildNewRegistrations()),
      ],
    );
  }

  Widget _buildVerificationChart() {
    final totalTeachers = _stats['totalTeachers'] ?? 1;
    final verificationRate = (_stats['verifiedTeachers'] ?? 0) / totalTeachers;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Teacher Verification',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(6)),
                ),
                const SizedBox(width: 8),
                Text('Verified: ${_stats['verifiedTeachers'] ?? 0}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6)),
                ),
                const SizedBox(width: 8),
                Text('Pending: ${_stats['notVerifiedTeachers'] ?? 0}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 8,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4)),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: verificationRate,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(verificationRate * 100).round()}% verified',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewRegistrations() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'New Registrations',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800]),
            ),
            const SizedBox(height: 16),
            Text(
              '${_stats['newRegistrations'] ?? 0}',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[600]),
            ),
            Text('This week',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 4),
                    Text('Students: ${_stats['newStudents'] ?? 0}',
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 4),
                    Text('Teachers: ${_stats['newTeachers'] ?? 0}',
                        style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(String page) {
    setState(() {
      _selectedPage = page;
    });

    Widget? destination;
    switch (page) {
      case 'Students':
        destination = const StudentsScreen();
        break;
      case 'Verified Teachers':
        destination = const TeacherScreen();
        break;
      case 'Not Verified Teachers':
        destination = const NotVerifiedTeachersScreen();
        break;
      case 'Courses':
        destination = const CoursesScreen();
        break;
      case 'Sessions':
        destination = const SessionsScreen();
        break;
      case 'Analytics':
        destination = const AnalyticsScreen();
        break;
      case 'Settings':
        destination = const SettingsScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => destination!),
    );
  }
}

// Fixed StatefulWidget for animated stats cards
class _AnimatedStatsCards extends StatefulWidget {
  final Map<String, int> stats;

  const _AnimatedStatsCards({required this.stats});

  @override
  __AnimatedStatsCardsState createState() => __AnimatedStatsCardsState();
}

class __AnimatedStatsCardsState extends State<_AnimatedStatsCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  int _currentIndex = 0;

  // Card data with proper initialization
  late List<Map<String, dynamic>> _cards;

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _setupAnimations();
    _startAutoSlide();
  }

  void _initializeCards() {
    _cards = [
      {
        'title': 'Total Students',
        'value': widget.stats['totalStudents']?.toString() ?? '0',
        'icon': Icons.school,
        'color': const Color(0xFF7D1C4A),
        'subtitle': '+${widget.stats['newRegistrations'] ?? 0} this week',
        'gradientStart': const Color(0xFFF7A8C4),
        'gradientEnd': const Color.fromARGB(255, 249, 134, 174),
      },
      {
        'title': 'Total Teachers',
        'value': widget.stats['totalTeachers']?.toString() ?? '0',
        'icon': Icons.people,
        'color': const Color(0xFFA62C2C),
        'subtitle': '${widget.stats['verifiedTeachers'] ?? 0} verified',
        'gradientStart': const Color(0xFFEFDCAB),
        'gradientEnd': const Color.fromARGB(255, 199, 176, 116),
      },
      {
        'title': 'Total Courses',
        'value': widget.stats['totalCourses']?.toString() ?? '0',
        'icon': Icons.book,
        'color': const Color(0xFFA04747),
        'subtitle': 'Active courses',
        'gradientStart': const Color(0xFF7AC6D2),
        'gradientEnd': const Color.fromARGB(255, 88, 160, 171),
      },
      {
        'title': 'Pending Approvals',
        'value': widget.stats['pendingApprovals']?.toString() ?? '0',
        'icon': Icons.pending,
        'color': const Color(0xFFA04747),
        'subtitle': 'Requires attention',
        'gradientStart': const Color.fromARGB(255, 253, 212, 235),
        'gradientEnd': const Color.fromARGB(255, 163, 177, 233),
      },
    ];
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _cards.length;
        });
        _controller.reverse();
      }
    });
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_controller.isAnimating) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Main animated card
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: 1.0 - _fadeAnimation.value,
                  child: Transform.scale(
                    scale: 1.0 - (_fadeAnimation.value * 0.05),
                    child: _buildStatCard(_cards[_currentIndex]),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // Static cards showing other stats
            ..._cards
                .asMap()
                .entries
                .where((entry) => entry.key != _currentIndex)
                .take(2)
                .map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Opacity(
                      opacity: 0.7,
                      child: Transform.scale(
                        scale: 0.95,
                        child: _buildStatCard(entry.value),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(Map<String, dynamic> card) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.transparent,
      child: Container(
        width: 140,
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              card['gradientStart'] as Color,
              card['gradientEnd'] as Color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['title'] as String,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(179, 0, 0, 0),
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card['value'] as String,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (card['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      card['icon'] as IconData,
                      color: card['color'] as Color,
                      size: 16,
                    ),
                  ),
                ],
              ),
              Text(
                card['subtitle'] as String,
                style: const TextStyle(
                    fontSize: 10,
                    color: Color.fromARGB(179, 0, 0, 0),
                    fontWeight: FontWeight.bold),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
