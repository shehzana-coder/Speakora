import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String _searchQuery = '';
  String _selectedType = 'All';
  final List<String> _types = ['All', 'Teacher Signups', 'Session Bookings'];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
      });

      Query<Map<String, dynamic>> query = _firestore
          .collection('notifications')
          .orderBy('timestamp', descending: true);
      if (_selectedType != 'All') {
        query = query.where('type',
            isEqualTo: _selectedType == 'Teacher Signups'
                ? 'teacher_signup'
                : 'session_booking');
      }

      final snapshot = await query.get();
      setState(() {
        _notifications = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'type': data['type'] ?? 'unknown',
            'userId': data['userId'] ?? '',
            'userName': data['userName'] ?? 'Unknown',
            'details': data['details'] ?? '',
            'timestamp': data['timestamp'] ?? Timestamp.now(),
            'isRead': data['isRead'] ?? false,
            'sessionId': data['sessionId'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading notifications: $e',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleReadStatus(String notificationId, bool currentStatus,
      String userName, String type) async {
    try {
      final newStatus = !currentStatus;
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': newStatus});

      // Log the action
      await _firestore.collection('admin_logs').add({
        'action': 'notification_read_status_changed',
        'adminId': _auth.currentUser?.uid ?? 'unknown',
        'details':
            'Admin marked notification for $userName ($type) as ${newStatus ? 'read' : 'unread'}',
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        final index =
            _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = newStatus;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notification marked as ${newStatus ? 'read' : 'unread'}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error updating read status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating notification: $e',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_searchQuery.isEmpty) return _notifications;
    return _notifications.where((notification) {
      final userName = notification['userName'].toString().toLowerCase();
      final details = notification['details'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return userName.contains(query) || details.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
              children: [
                _buildSearchAndFilter(),
                Expanded(
                  child: _filteredNotifications.isEmpty
                      ? Center(
                          child: Text(
                            'No notifications found',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = _filteredNotifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by user or details',
              hintStyle: GoogleFonts.poppins(
                  color: const Color.fromARGB(255, 0, 0, 0)),
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.blue[50],
            ),
            style:
                GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedType,
            items: _types
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type,
                          style: GoogleFonts.poppins(
                              color: const Color.fromARGB(255, 0, 0, 0))),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
                _fetchNotifications();
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue[600]!),
              ),
              filled: true,
              fillColor: Colors.blue[50],
            ),
            style:
                GoogleFonts.poppins(color: const Color.fromARGB(255, 0, 0, 0)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final timestamp = (notification['timestamp'] as Timestamp?)?.toDate();
    final formattedTime = timestamp != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(timestamp)
        : 'Unknown';
    final isRead = notification['isRead'] as bool;
    final type = notification['type'] == 'teacher_signup'
        ? 'Teacher Signup'
        : 'Session Booking';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      color: isRead ? Colors.white : Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[600],
              child: Icon(
                notification['type'] == 'teacher_signup'
                    ? Icons.person_add
                    : Icons.event,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['userName'],
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['details'],
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                color: isRead ? Colors.green : Colors.orange,
              ),
              onPressed: () => _toggleReadStatus(
                notification['id'],
                isRead,
                notification['userName'],
                type,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
