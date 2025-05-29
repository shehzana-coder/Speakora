import 'package:flutter/material.dart';
// Import MessageScreen
import 'messagescreen.dart';
import 'schedulescreen.dart' as schedule;
import 'tutorinfo.dart'; // Import the TutorProfileScreen

class TutorScreen extends StatefulWidget {
  const TutorScreen({Key? key}) : super(key: key);

  @override
  _TutorScreenState createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  // Sample tutor data
  final List<Map<String, dynamic>> tutors = [
    {
      'name': 'Ayesha A.',
      'country': 'Pakistan',
      'verified': true,
      'price': 10,
      'lessonDuration': '2 hour lesson',
      'rating': 4.5,
      'reviews': 2,
      'description':
          'Unlock your English Mastery with an Engaging Educator: Experience the Trasformation of......',
      'students': 15,
      'lessons': 475,
      'languages': ['English (native)', '+3'],
      'isFavorite': false,
    },
    {
      'name': 'Rayan T.',
      'country': 'UK',
      'verified': true,
      'price': 15,
      'lessonDuration': '1 hour lesson',
      'rating': 4.5,
      'reviews': 21,
      'description':
          'Unlock your English Mastery with an Engaging Educator: Experience the Trasformation of......',
      'students': 27,
      'lessons': 871,
      'languages': ['English (native)', '+3'],
      'isFavorite': false,
    },
    {
      'name': 'Mary A.',
      'country': 'UK',
      'verified': true,
      'price': 12,
      'lessonDuration': '1 hour lesson',
      'rating': 4.7,
      'reviews': 15,
      'description':
          'Unlock your English Mastery with an Engaging Educator: Experience the Trasformation of......',
      'students': 20,
      'lessons': 650,
      'languages': ['English (native)', '+2'],
      'isFavorite': false,
    },
    {
      'name': 'John D.',
      'country': 'USA',
      'verified': true,
      'price': 18,
      'lessonDuration': '1.5 hour lesson',
      'rating': 4.8,
      'reviews': 32,
      'description':
          'Unlock your English Mastery with an Engaging Educator: Experience the Trasformation of......',
      'students': 35,
      'lessons': 920,
      'languages': ['English (native)', '+1'],
      'isFavorite': false,
    },
    {
      'name': 'Sarah L.',
      'country': 'Canada',
      'verified': true,
      'price': 14,
      'lessonDuration': '1 hour lesson',
      'rating': 4.6,
      'reviews': 18,
      'description':
          'Unlock your English Mastery with an Engaging Educator: Experience the Trasformation of......',
      'students': 22,
      'lessons': 580,
      'languages': ['English (native)', '+2'],
      'isFavorite': false,
    },
  ];

  // Filter options
  final List<String> filterOptions = [
    'Also Speaks',
    'Availability',
    'Country',
    'Price',
    'Native',
    'Experience',
    'Ratings',
    'Topics',
  ];

  // Sorting options
  final List<String> sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Rating: High to Low',
    'Experience: Most lessons',
    'Popularity: Most students',
  ];

  // Track if sorting dropdown is visible
  bool isSortDropdownVisible = false;

  // Currently selected sort option
  String currentSortOption = 'Price: Low to High';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 24,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              'speakora',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filter buttons with guaranteed horizontal scrolling
          SizedBox(
            height: 60, // Fixed height to ensure proper scrolling
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics:
                  const AlwaysScrollableScrollPhysics(), // Ensures scrolling is always enabled
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: filterOptions.map((option) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: const BorderSide(color: Colors.grey),
                          backgroundColor: Colors.white,
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Sort by section with dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.bookmark_outline, color: Colors.grey),
                const Spacer(),
                const Text(
                  'Sort by',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list, color: Colors.black),
                  onSelected: (String value) {
                    setState(() {
                      currentSortOption = value;
                      _sortTutors(value);
                    });
                  },
                  offset: const Offset(0, 40), // Position dropdown below icon
                  itemBuilder: (BuildContext context) {
                    return sortOptions.map((String option) {
                      return PopupMenuItem<String>(
                        value: option,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              option,
                              style: TextStyle(
                                color: currentSortOption == option
                                    ? Color.fromARGB(255, 255, 144, 187)
                                    : Colors.black87,
                                fontWeight: currentSortOption == option
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            if (currentSortOption == option)
                              Icon(
                                Icons.check,
                                color: Color.fromARGB(255, 255, 144, 187),
                              )
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),

          // Tutor list
          Expanded(
            child: ListView.separated(
              itemCount: tutors.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final tutor = tutors[index];
                return InkWell(
                  onTap: () {
                    // Navigate to TutorProfileScreen when a tutor is clicked
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TutorProfileScreen(
                          tutorData: tutor,
                        ),
                      ),
                    ).then((value) {
                      // Update the UI when returning from the profile screen
                      // This ensures any changes (like favorite status) are reflected
                      setState(() {});
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tutor image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/3.png', // Using fixed image; you might want to make this dynamic
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Tutor details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            tutor['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildCountryFlag(tutor['country']),
                                          if (tutor['verified'])
                                            const SizedBox(width: 4),
                                          if (tutor['verified'])
                                            const Icon(Icons.verified,
                                                size: 16,
                                                color: Color.fromARGB(
                                                    255, 255, 144, 187)),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          tutor['isFavorite']
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: tutor['isFavorite']
                                              ? Color.fromARGB(
                                                  255, 255, 144, 187)
                                              : Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            tutors[index]['isFavorite'] =
                                                !tutors[index]['isFavorite'];
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '\$ ${tutor['price']}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            tutor['lessonDuration'],
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${tutor['rating']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Icon(Icons.star,
                                                  size: 16,
                                                  color: Colors.amber),
                                            ],
                                          ),
                                          Text(
                                            '${tutor['reviews']} reviews',
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tutor['description'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.person_outline,
                                size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              '${tutor['students']} students',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${tutor['lessons']} lessons',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.language,
                                size: 16, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              'Speaks ${tutor['languages'][0]} ${tutor['languages'][1]}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 255, 144, 187),
        unselectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            // Navigate to MessageScreen when Messages tab is clicked
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
            );
          }
          if (index == 2) {
            // Navigate to schedule screen when schedule tab is clicked
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const schedule.ScheduleScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.send),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }

  Widget _buildCountryFlag(String country) {
    String flag = '';
    switch (country) {
      case 'UK':
        flag = '🇬🇧';
        break;
      case 'USA':
        flag = '🇺🇸';
        break;
      case 'Pakistan':
        flag = '🇵🇰';
        break;
      case 'Canada':
        flag = '🇨🇦';
        break;
      default:
        flag = '🏳️';
    }
    return Text(flag, style: const TextStyle(fontSize: 16));
  }

  // Method to sort tutors based on selected option
  void _sortTutors(String sortOption) {
    setState(() {
      switch (sortOption) {
        case 'Price: Low to High':
          tutors
              .sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
          break;
        case 'Price: High to Low':
          tutors
              .sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
          break;
        case 'Rating: High to Low':
          tutors.sort(
              (a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
          break;
        case 'Experience: Most lessons':
          tutors.sort(
              (a, b) => (b['lessons'] as num).compareTo(a['lessons'] as num));
          break;
        case 'Popularity: Most students':
          tutors.sort(
              (a, b) => (b['students'] as num).compareTo(a['students'] as num));
          break;
      }
    });
  }
}
