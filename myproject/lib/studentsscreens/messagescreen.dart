import 'package:flutter/material.dart';
import 'chatscreen.dart';

// Import the screens we'll navigate to
import 'tutorhomescreen.dart';
import 'schedulescreen.dart';
import 'profilesetting.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        // ignore: prefer_const_literals_to_create_immutables
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: const AssetImage('assets/images/4.png'),
              // If you don't have the image in assets, use a placeholder:
              // backgroundColor: Colors.grey,
              // child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color.fromARGB(255, 255, 144, 187),
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All messages tab
          ListView(
            children: [
              _buildMessageTile(
                name: 'Ahmed N.',
                message: 'Can you tell me the problem...',
                time: '11:48 AM',
                unreadCount: 2,
                profileImage: 'assets/images/4.png',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen()));
                  // Handle message tap - Navigate to chat screen
                },
              ),
              _buildMessageTile(
                name: 'Kashan R.',
                message: 'Can you tell me the problem...',
                time: '11:48 AM',
                unreadCount: 2,
                profileImage: 'assets/images/5.png',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ChatScreen()));
                  // Handle message tap - Navigate to chat screen
                },
              ),
            ],
          ),
          // Archived messages tab
          const Center(
            child: Text('No archived messages'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, // Messages tab is selected
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 255, 144, 187),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        onTap: (index) {
          // Handle navigation based on the tapped index
          _navigateToScreen(context, index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Setting',
          ),
        ],
      ),
    );
  }

  // Method to handle navigation based on the selected tab index
  void _navigateToScreen(BuildContext context, int index) {
    // Skip navigation if we're already on the Messages screen (index 1)
    if (index == 1) return;

    // Navigate to the selected screen
    switch (index) {
      case 0:
        // Navigate to Search/Tutor Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TutorScreen()),
        );
        break;
      case 2:
        // Navigate to Schedule Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ScheduleScreen()),
        );
        break;
      case 3:
        // Navigate to Profile Settings Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ProfileSettingsScreen()),
        );
        break;
    }
  }

  Widget _buildMessageTile({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required String profileImage,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage(profileImage),
        // If you don't have the image in assets, use a placeholder:
        // backgroundColor: Colors.grey,
        // child: const Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        message,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.fromARGB(255, 255, 144, 187),
            ),
            child: Text(
              unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

// Reference implementations for other screens that we're navigating to
// These can be in separate files in your actual project
