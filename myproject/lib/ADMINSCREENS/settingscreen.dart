import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _platformName = 'Speakora';
  String _supportEmail = 'support@speakora.com';
  bool _sessionUpdates = true;
  bool _newRegistrations = true;
  bool _autoApproveTeachers = false;
  bool _requireAdmin2FA = false;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final doc = await _firestore.collection('settings').doc('platform_settings').get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _platformName = data['platformName'] ?? 'Speakora';
          _supportEmail = data['supportEmail'] ?? 'support@speakora.com';
          _sessionUpdates = data['notifications']?['sessionUpdates'] ?? true;
          _newRegistrations = data['notifications']?['newRegistrations'] ?? true;
          _autoApproveTeachers = data['autoApproveTeachers'] ?? false;
          _requireAdmin2FA = data['requireAdmin2FA'] ?? false;
        });
      }
    } catch (e) {
      print('Error fetching settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading settings: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      final settings = {
        'platformName': _platformName,
        'supportEmail': _supportEmail,
        'notifications': {
          'sessionUpdates': _sessionUpdates,
          'newRegistrations': _newRegistrations,
        },
        'autoApproveTeachers': _autoApproveTeachers,
        'requireAdmin2FA': _requireAdmin2FA,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('settings').doc('platform_settings').set(settings, SetOptions(merge: true));

      // Log the update
      await _firestore.collection('admin_logs').add({
        'action': 'settings_updated',
        'adminId': _auth.currentUser?.uid ?? 'unknown',
        'details': 'Admin updated platform settings',
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved successfully', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error saving settings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchSettings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('General Settings'),
                    _buildGeneralSettings(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Notification Preferences'),
                    _buildNotificationSettings(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('User Management'),
                    _buildUserManagementSettings(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Security'),
                    _buildSecuritySettings(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: _platformName,
              decoration: InputDecoration(
                labelText: 'Platform Name',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.blue[50],
              ),
              style: GoogleFonts.poppins(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a platform name';
                }
                return null;
              },
              onChanged: (value) {
                _platformName = value;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _supportEmail,
              decoration: InputDecoration(
                labelText: 'Support Email',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.blue[50],
              ),
              style: GoogleFonts.poppins(),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a support email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              onChanged: (value) {
                _supportEmail = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Session Updates', style: GoogleFonts.poppins()),
              subtitle: Text(
                'Receive email notifications for session status changes',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              value: _sessionUpdates,
              onChanged: (value) {
                setState(() {
                  _sessionUpdates = value;
                });
              },
              activeColor: Colors.blue[600],
            ),
            SwitchListTile(
              title: Text('New Registrations', style: GoogleFonts.poppins()),
              subtitle: Text(
                'Receive email notifications for new user registrations',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
              value: _newRegistrations,
              onChanged: (value) {
                setState(() {
                  _newRegistrations = value;
                });
              },
              activeColor: Colors.blue[600],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserManagementSettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SwitchListTile(
          title: Text('Auto-Approve Teachers', style: GoogleFonts.poppins()),
          subtitle: Text(
            'Automatically approve new teacher registrations (not recommended)',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _autoApproveTeachers,
          onChanged: (value) {
            setState(() {
              _autoApproveTeachers = value;
            });
          },
          activeColor: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SwitchListTile(
          title: Text('Require Admin 2FA', style: GoogleFonts.poppins()),
          subtitle: Text(
            'Enforce two-factor authentication for all admin accounts',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _requireAdmin2FA,
          onChanged: (value) {
            setState(() {
              _requireAdmin2FA = value;
            });
          },
          activeColor: Colors.blue[600],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[600],
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                'Save Settings',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}