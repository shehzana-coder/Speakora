import 'package:flutter/material.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                color: const Color.fromARGB(255, 255, 144, 187),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.black),
                    const SizedBox(width: 10),
                    const Text("Profile",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Image with Edit Icon
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/3.png'),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.edit,
                      size: 20,
                      color: Color.fromARGB(255, 255, 144, 187),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Text("Jonathan Patterson",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("hello@reallygreatsite.com",
                  style: TextStyle(color: Colors.grey[600])),

              const SizedBox(height: 20),

              // General Settings Section
              sectionTitle("General Settings"),
              settingTile(
                icon: Icons.settings,
                title: "Mode",
                subtitle: "Dark & Light",
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeColor: const Color.fromARGB(255, 255, 144, 187),
                ),
              ),
              settingTile(
                icon: Icons.vpn_key,
                title: "Change Password",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              settingTile(
                icon: Icons.language,
                title: "Language",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),

              // Information Section
              sectionTitle("Information"),
              settingTile(
                icon: Icons.phone_android,
                title: "About App",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              settingTile(
                icon: Icons.description,
                title: "Terms & Conditions",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              settingTile(
                icon: Icons.privacy_tip,
                title: "Privacy Policy",
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 255, 144, 187),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing: trailing,
      onTap: () {}, // Add navigation or functionality here
    );
  }
}
