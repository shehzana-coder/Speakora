// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'videoplayer.dart';
import 'package:myproject/studentsscreens/teacheravailability.dart';

class TutorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> tutorData;

  const TutorProfileScreen({Key? key, required this.tutorData})
      : super(key: key);

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  bool _showFullDescription = true; // Controls "Show less" / "Show more"
  String _videoAssetPath = 'assets/images/video.mp4';

  @override
  void initState() {
    super.initState();
    // Initialize video player with a video from assets
    _initializeVideoThumbnail();
  }

  Future<void> _initializeVideoThumbnail() async {
    try {
      _videoPlayerController = VideoPlayerController.asset(_videoAssetPath);

      await _videoPlayerController.initialize();

      // Set the video to the first frame, but don't play it
      // This is just for the thumbnail
      await _videoPlayerController.seekTo(const Duration(milliseconds: 100));

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      print("Error initializing video thumbnail: $e");
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Widget _buildVideoSection() {
    return GestureDetector(
      onTap: () {
        // Navigate to dedicated video player screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(
              videoUrl: _videoAssetPath, // Pass asset path
              tutorName: widget.tutorData['name'],
              isAssetVideo: true, // Flag to indicate this is an asset video
            ),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: _isVideoInitialized
            ? Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _videoPlayerController.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController),
                  ),
                  // Play icon overlay
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.play_circle_fill,
                      size: 50.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.tutorData['isFavorite']
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.tutorData['isFavorite']
                  ? Colors.red
                  : const Color.fromARGB(255, 1, 1, 1),
            ),
            onPressed: () {
              // Toggle favorite status
              setState(() {
                widget.tutorData['isFavorite'] =
                    !widget.tutorData['isFavorite'];
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Section
                SizedBox(
                  width: double.infinity,
                  height: 250,
                  child: _isVideoInitialized
                      ? VideoPlayer(_videoPlayerController)
                      : Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                // Profile Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/3.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Profile Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutorData['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Birth in ${widget.tutorData['country']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildCountryFlag(widget.tutorData['country']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats Section
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.verified,
                        label: 'Verified',
                        iconColor: widget.tutorData['verified']
                            ? Colors.black
                            : Colors.grey,
                      ),
                      _buildStatItem(
                        icon: Icons.star,
                        text: '${widget.tutorData['rating']}',
                        label: 'Rating',
                        iconColor: Colors.amber,
                      ),
                      _buildStatItem(
                        text: '\$${widget.tutorData['price']}',
                        label: 'Per lesson',
                      ),
                      _buildStatItem(
                        text: '${widget.tutorData['reviews']}',
                        label: 'Reviews',
                      ),
                      _buildStatItem(
                        text: '${widget.tutorData['lessons']}',
                        label: 'Lessons',
                      ),
                    ],
                  ),
                ),

                // Super Tutor Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.workspace_premium,
                            color: const Color.fromARGB(255, 255, 144, 187),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Super Tutor',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 144, 187),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(
                          '${widget.tutorData['name']} is a highly rated and reliable tutor.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: const Color.fromARGB(255, 255, 144, 187),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'High demand',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 144, 187),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 28.0),
                        child: Text(
                          '6 lessons booked in the last 12 hours',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // About Me Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'About me',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Looking to polish your advanced English, I am here to guide you every step of the way. My goal is to make learning English simple, enjoyable, and effective. I specialize in personalized lessons tailored to each student\'s needs and goals. Whether you are preparing for exams like IELTS or TOEFL, improving business communication, or learning English for travel, I can help. My teaching style is interactive and student-centered, focusing on real-life usage and practical skills. I believe every student learns best when they feel supported and confident.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        maxLines: _showFullDescription ? null : 3,
                        overflow: _showFullDescription
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showFullDescription = !_showFullDescription;
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 132, 120, 120)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _showFullDescription ? 'Show less' : 'Show more',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Languages Section
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'English',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 144, 187),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Native',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Others',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color.fromARGB(255, 255, 144, 187),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'German',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: const Color.fromARGB(255, 255, 144, 187),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Urdu',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Schedule Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const SessionSchedulingScreen()),
                        );
                        // Handle schedule viewing
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'See my Schedule',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

                // Reviews Section
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text(
                        '5 - 15 reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Review Cards
                Container(
                  height: 200, // Fixed height for review cards
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildReviewCard(
                        name: 'Amna',
                        flag: '🇮🇳',
                        daysAgo: '3 days ago',
                        avatarUrl: 'assets/images/2.png',
                      ),
                      const SizedBox(width: 16),
                      _buildReviewCard(
                        name: 'Alex',
                        flag: '🇺🇸',
                        daysAgo: '5 days ago',
                        avatarUrl: 'assets/images/3.png',
                      ),
                      const SizedBox(width: 16),
                      _buildReviewCard(
                        name: 'Sarah',
                        flag: '🇬🇧',
                        daysAgo: '1 week ago',
                        avatarUrl: 'assets/images/4.png',
                      ),
                    ],
                  ),
                ),

                // Show All Reviews Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: OutlinedButton(
                    onPressed: () {
                      // Handle show all reviews
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: const Text(
                      'Show all reviews',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // My Resume Section
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: ListTile(
                    title: const Text(
                      'My resume',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle resume navigation
                    },
                  ),
                ),

                // Teaching Subjects Section
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: ListTile(
                    title: const Text(
                      'Teaching subjects',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Handle teaching subjects navigation
                    },
                  ),
                ),

                // Add extra space at the bottom for the fixed bottom buttons
                const SizedBox(height: 100),
              ],
            ),
          ),

          // Fixed Bottom Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Message Button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_bubble_outline,
                          color: Colors.black),
                      onPressed: () {
                        // Handle message
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Buy Trial Session Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      SessionSchedulingScreen()));
                          // Handle buying trial session
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                              255, 255, 144, 187), // Pink color
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Buy trial session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    IconData? icon,
    String? text,
    required String label,
    Color iconColor = Colors.black,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: iconColor,
                size: 24,
              )
            else if (text != null)
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
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

  Widget _buildReviewCard({
    required String name,
    required String flag,
    required String daysAgo,
    required String avatarUrl,
  }) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage(avatarUrl),
                onBackgroundImageError: (exception, stackTrace) {
                  // Handle error loading image
                },
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(flag, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  Text(
                    daysAgo,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Excellent teacher! Very patient and explains concepts clearly. Looking forward to more lessons.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
