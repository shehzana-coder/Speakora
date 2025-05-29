import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class NotVerifiedTeachersScreen extends StatefulWidget {
  const NotVerifiedTeachersScreen({super.key});

  @override
  _NotVerifiedTeachersScreenState createState() =>
      _NotVerifiedTeachersScreenState();
}

class _NotVerifiedTeachersScreenState extends State<NotVerifiedTeachersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _teachers = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot =
          await _firestore.collection('teachers_not_verified').get();
      setState(() {
        _teachers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'fullName': data['about']?['fullName'] ?? 'Unknown',
            'email': data['email'] ?? 'No email',
            'createdAt': data['createdAt'] ?? Timestamp.now(),
            'profileComplete': data['profileComplete'] ?? false,
            'data': data, // Store full data for verification
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching teachers: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error loading teachers: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyTeacher(
      String uid, String fullName, Map<String, dynamic> teacherData) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Verify Teacher',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to verify $fullName? This will move them to the verified teachers list.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Verify', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Move to teachers collection
      await _firestore.collection('teachers').doc(uid).set({
        ...teacherData,
        'profileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Remove from teachers_not_verified
      await _firestore.collection('teachers_not_verified').doc(uid).delete();

      // Log verification
      await _firestore.collection('admin_logs').add({
        'action': 'teacher_verified',
        'teacherId': uid,
        'details': 'Teacher $fullName verified by admin',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Refresh UI
      setState(() {
        _teachers.removeWhere((teacher) => teacher['uid'] == uid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teacher $fullName verified successfully',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error verifying teacher: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error verifying teacher: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteTeacher(String uid, String fullName) async {
    try {
      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Delete Teacher',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete $fullName? This action cannot be undone.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // Delete from Firestore
      await _firestore.collection('teachers_not_verified').doc(uid).delete();

      // Log deletion
      await _firestore.collection('admin_logs').add({
        'action': 'teacher_deleted',
        'teacherId': uid,
        'details': 'Unverified teacher $fullName deleted by admin',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Refresh UI
      setState(() {
        _teachers.removeWhere((teacher) => teacher['uid'] == uid);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Teacher $fullName deleted successfully',
              style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting teacher: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error deleting teacher: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredTeachers {
    if (_searchQuery.isEmpty) return _teachers;
    return _teachers.where((teacher) {
      final name = teacher['fullName'].toString().toLowerCase();
      final email = teacher['email'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Not Verified Teachers',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTeachers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: _filteredTeachers.isEmpty
                      ? Center(
                          child: Text(
                            'No unverified teachers found',
                            style: GoogleFonts.poppins(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredTeachers.length,
                          itemBuilder: (context, index) {
                            final teacher = _filteredTeachers[index];
                            return _buildTeacherCard(teacher);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search by name or email',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
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
        style: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final createdAt = (teacher['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = createdAt != null
        ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
        : 'Unknown';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[600],
              child: Text(
                teacher['fullName']?.substring(0, 1).toUpperCase() ?? 'U',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher['fullName'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teacher['email'],
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registered: $formattedDate',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Profile: ${teacher['profileComplete'] ? 'Complete' : 'Incomplete'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: teacher['profileComplete']
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _verifyTeacher(
                      teacher['uid'], teacher['fullName'], teacher['data']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _deleteTeacher(teacher['uid'], teacher['fullName']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
