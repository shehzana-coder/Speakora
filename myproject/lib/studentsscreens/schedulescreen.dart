import 'package:flutter/material.dart';
import 'messagescreen.dart';
// Import the screens we'll navigate to
import 'tutorhomescreen.dart';
import 'profilesetting.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Schedule',
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
              backgroundImage: const AssetImage('assets/images/3.png'),
              // If you don't have the image in assets, use a placeholder:
              // backgroundColor: Colors.grey,
              // child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "You'll see your tutors and lesson schedule here",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Schedule your session now and connect with your tutor at your convenience. Select the date and time that suits you best and take the next step in your learning journey.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Handle find tutor action
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TutorScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 255, 144, 187), // Pink color as shown in the image
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Find a tutor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Schedule tab is selected
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(
            255, 255, 144, 187), // Pink color for selected tab
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
    // Skip navigation if we're already on the Schedule screen (index 2)
    if (index == 2) return;

    // Clear the navigation stack and go to the selected screen
    switch (index) {
      case 0:
        // Navigate to Search/Tutor Home Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TutorScreen()),
        );
        break;
      case 1:
        // Navigate to Messages Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MessagesScreen()),
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
}

// Placeholder screens for navigation
// These would be replaced by your actual screen implementations
