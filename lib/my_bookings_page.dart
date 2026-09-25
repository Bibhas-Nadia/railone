import 'package:flutter/material.dart';
import 'upcoming_bookings.dart';
import 'completed_bookings.dart';
import 'cancelled_bookings.dart';
import 'all_bookings.dart';
import 'database_helper.dart';


class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  int _currentIndex = 0; // Defaulting to 1 (Completed) to match your screenshot

  final List<Widget> _pages = [
    const UpcomingBookings(),
    const CompletedBookings(),
    const CancelledBookings(),
    const AllBookings(),
  ];



  // --- ADD THESE METHODS ---
  @override
  void initState() {
    super.initState();
    _refreshBookingStatuses();
  }

  Future<void> _refreshBookingStatuses() async {
    // Run the silent update
    await DatabaseHelper().silentUpdateBookingStatuses();

    // Call setState so the currently selected tab fetches the freshly updated database rows
    if (mounted) {
      setState(() {});
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D6EFD), // Blue
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white)),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Bookings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      // Bottom Bar styling updated to match UI
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Colors.white, // The white pill shape behind active icon
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12);
                }
                return const TextStyle(color: Colors.grey, fontSize: 12);
              }),
            ),
            child: NavigationBar(
              height: 75,
              backgroundColor: const Color(0xFFEAF4FB), // Light blue appbar tint
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) => setState(() => _currentIndex = index),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.local_activity_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.local_activity, color: Colors.green),
                  label: 'Upcoming',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fact_check_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.fact_check, color: Colors.green),
                  label: 'Completed',
                ),
                NavigationDestination(
                  icon: Icon(Icons.cancel_presentation_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.cancel_presentation, color: Colors.green),
                  label: 'Cancelled',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.receipt_long, color: Colors.green),
                  label: 'All',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
