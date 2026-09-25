import 'package:flutter/material.dart';
import 'booking_page.dart';
import 'database.dart';
import 'my_bookings_page.dart';
import 'station_distance_page.dart';
import 'profile_page.dart';
import 'contact_sync_page.dart';

void main() {
  runApp(const RailOneApp());
}

class RailOneApp extends StatelessWidget {
  const RailOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RailOne',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        fontFamily: 'sans-serif',
      ),
      // --- UPDATED: Set the initial route to the SplashScreen ---
      home: const SplashScreen(),
    );
  }
}

// --- NEW SPLASH SCREEN WIDGET ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 1. Setup the Zoom-Out Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // The animation itself takes 2 seconds
      vsync: this,
    );

    // Tween from 1.3 (slightly zoomed in) to 1.0 (normal size)
    _animation = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward(); // Start the animation

    // 2. Wait exactly 3 seconds, then navigate to HomePage
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose animation controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The background color matches the white background of flash.png
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset(
            'assets/flash.png', // Ensure this matches your file name in assets
            width: 180, // Adjust size as needed
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
// --------------------------------

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Reusable function to show the 'Coming Soon' message on ANY button click
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Navigation function ONLY for Unreserved and Bottom Nav
  void _navigateToPage(BuildContext context, String pageName) {
    if (pageName == 'unreserved') {
     Navigator.push(
        context,
        MaterialPageRoute(
          // --- UPDATED: Navigate to your real page instead of Dummy ---
          builder: (context) => const UnreservedBookingPage(),
        ),
      );
    }
    else if(pageName == 'My Bookings')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          // --- UPDATED: Navigate to your real page instead of Dummy ---
          builder: (context) => const MyBookingsPage(),
        ),
      );
    }
    else if(pageName == 'tables')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          // --- UPDATED: Navigate to your real page instead of Dummy ---
          builder: (context) => const DatabaseViewerPage(),
        ),
      );
    }
    else if(pageName == 'distance')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          // --- UPDATED: Navigate to your real page instead of Dummy ---
          builder: (context) => const StationDistancePage(),
        ),
      );
    }
    else if(pageName == 'Profile')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          // --- UPDATED: Navigate to your real page instead of Dummy ---
          builder: (context) => const ProfilePage(),
        ),
      );
    }
    else if(pageName == 'contacts')
    {
      Navigator.push(
        context,
        MaterialPageRoute(
          // --- UPDATED: Navigate to your real page instead of Dummy ---
          builder: (context) => const ContactSyncPage(),
        ),
      );
    }



  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlueText = Color(0xFF14224A);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // --- CUSTOM APP BAR HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _showComingSoon(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.translate, color: Colors.blue, size: 24),
                      ),
                    ),

                    // --- REPLACED TEXT WITH LOGO IMAGE ---
                    Image.asset(
                      'assets/logo.png',
                      height: 55,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'RailOne',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
                      ),
                    ),

                    GestureDetector(
                      onTap: () => _showComingSoon(context),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: const Icon(Icons.notifications_none, size: 24),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Text(
                                '1',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- GREETING ---
                const Text(
                  'Hi, Bibhas Das!',
                  style: TextStyle(color: darkBlueText, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),

                // --- JOURNEY PLANNER SECTION ---
                const Text(
                  'Journey Planner',
                  style: TextStyle(color: darkBlueText, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildJourneyCard(context, 'Reserved', 'assets/reserved.png', () => _showComingSoon(context)),
                    _buildJourneyCard(context, 'Unreserved', 'assets/unreserved.png', () => _navigateToPage(context, 'unreserved')),
                    _buildJourneyCard(context, 'Platform', 'assets/platform.png', () => _navigateToPage(context, 'platform')),//_showComingSoon(context)),
                  ],
                ),
                const SizedBox(height: 24),

                // --- MORE OFFERINGS SECTION ---
                const Text(
                  'More Offerings',
                  style: TextStyle(color: darkBlueText, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Fixed GridView to prevent bottom overflow using mainAxisExtent
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 8,
                    mainAxisExtent: 115,
                  ),
                  children: [
                    _buildOfferingItem(context, 'Search\nTrains', 'assets/search.png', const Color(0xFFFFF0F5), const Color(0xFFF48FB1),()=> _navigateToPage(context, 'distance')),
                    _buildOfferingItem(context, 'PNR\nStatus', 'assets/pnr.png', const Color(0xFFF1F8E9), const Color(0xFF4CAF50),()=> _navigateToPage(context, 'tables')),
                    _buildOfferingItem(context, 'Coach\nPosition', Icons.train, const Color(0xFFE1F5FE), const Color(0xFF2196F3),()=> _navigateToPage(context, 'xxxxx')),
                    _buildOfferingItem(context, 'Track Your\nTrain', Icons.directions_subway, const Color(0xFFFFF8E1), const Color(0xFFFFB300),()=> _navigateToPage(context, 'xxxxx')),
                    _buildOfferingItem(context, 'Order\nFood', Icons.fastfood, const Color(0xFFE8EAF6), const Color(0xFF5C6BC0),()=> _navigateToPage(context, 'contacts')),
                    _buildOfferingItem(context, 'File\nRefund', 'assets/refund.png', const Color(0xFFEEEEEE), const Color(0xFF616161),()=> _navigateToPage(context, 'xxxx')),
                    _buildOfferingItem(context, 'Rail\nMadad', Icons.handshake, const Color(0xFFFFEBEE), const Color(0xFFE57373),()=> _navigateToPage(context, 'xxxxx')),
                    _buildOfferingItem(context, 'Go To\nWAVES', 'assets/waves.png', const Color(0xFFaf98b3), Colors.white,()=> _navigateToPage(context, 'xxxxx')),
                  ],
                ),
                const SizedBox(height: 24),

                // --- DO YOU KNOW SECTION ---
                const Text(
                  'Do You know?',
                  style: TextStyle(color: darkBlueText, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 230,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFactCard(
                        'assets/know1.png',
                        'First ever passenger train was run between Bori Bandar to Thane on April 16, 1853.',
                      ),
                      _buildFactCard(
                        'assets/know2.png',
                        'Chenab Railway Bridge in Dharot, Jammu & Kashmir is the World\'s highest Railway Bridge.',
                      ),
                      _buildFactCard(
                        'assets/know3.png',
                        "Noney Bridge is going to be world's tallest railway bridge pier at the height of 141 meters.",
                      ),
                      _buildFactCard(
                        'assets/know4.png',
                        "Shree Siddaroodha Swamiji Railway Station Hubbali is the world's longest Railway Platform with length of 1505 meters.",
                      ),
                      _buildFactCard(
                        'assets/know5.png',
                        "99% Electrification is achieved in Indian Railways.",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E88E5),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        onTap: (index) {
          List<String> pages = ['Home', 'My Bookings', 'Profile', 'menu'];
          _navigateToPage(context, pages[index]);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_number_outlined), label: 'My Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildJourneyCard(BuildContext context, String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 105,
              height: 105,
              color: Colors.grey.shade200,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF14224A), fontSize: 14, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferingItem(
    BuildContext context,
    String title,
    dynamic iconSource,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap
  ) {
    return GestureDetector(
     onTap: onTap,// => onta _navigateToPage(context, 'distance'),//_showComingSoon(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: iconSource is IconData
              ? Icon(iconSource, color: iconColor, size: 30)
              : Image.asset(
                iconSource.toString(),
                width: 45,
                height: 45,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF14224A),
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactCard(String imagePath, String text) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 130,
              width: 200,
              color: Colors.grey.shade300,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}













// --- DUMMY NAVIGATION PAGE ---
class DummyNavigationPage extends StatelessWidget {
  final String title;

  const DummyNavigationPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Welcome to the $title Page!\n\n(This is a placeholder)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Color(0xFF14224A)),
        ),
      ),
    );
  }
}
