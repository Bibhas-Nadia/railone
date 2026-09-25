
import 'dart:async';
import 'package:flutter/material.dart';
import 'database_helper.dart'; // Ensure this matches your file path
import 'my_bookings_page.dart'; // Uncomment and update with the actual path to your MyBookingsPage file

class TicketDetailsPage extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const TicketDetailsPage({
    super.key,
    required this.ticketData,
  });

  @override
  State<TicketDetailsPage> createState() => _TicketDetailsPageState();
}

class _TicketDetailsPageState extends State<TicketDetailsPage> {
  Timer? _timer;
  int _start = 300; // 5 minutes timer (300 seconds)

  // Variables to hold the fetched profile data
  String _userName = 'Loading...';
  String _mobileNumber = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Fetch user details from database
    _startTimer();
  }

  // Fetch the name and phone from local SQLite database
  Future<void> _loadUserProfile() async {
    final profileData = await DatabaseHelper().getUserProfile();

    if (mounted) {
      setState(() {
        if (profileData != null) {
          _userName = profileData['name'] ?? 'Bibhas Das';
      _mobileNumber = profileData['phone'] ?? '7384513355';
        } else {
          // Fallback if profile is not setup yet
          _userName = 'Bibhas Das';
      _mobileNumber = '7384513355';
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start <= 0) {
        timer.cancel();
        if (mounted) {
          // Navigate to MyBookingsPage when timer is done
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MyBookingsPage(), // Replace with your actual MyBookingsPage widget
            ),
          );
        }
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  String get _formattedTime {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format: dd MMM YYYY, HH:mm (e.g., 21 Apr 2026, 22:17)
  String _formatBookingDateBox(DateTime dt) {
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    String day = dt.day.toString().padLeft(2, '0');
    String month = months[dt.month - 1];
    String year = dt.year.toString();
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  // Format: dd/MM/yyyy HH:mm
  String _formatStandardDate(DateTime dt) {
    String day = dt.day.toString().padLeft(2, '0');
    String month = dt.month.toString().padLeft(2, '0');
    String year = dt.year.toString();
    String hour = dt.hour.toString().padLeft(2, '0');
    String minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Safe extraction of ticket details
    final dynamic rawDist = widget.ticketData['distance'];
    final double distValue = (rawDist is num) ? rawDist.toDouble() : (double.tryParse(rawDist?.toString() ?? '0') ?? 3.0);
    final String distance = distValue.toStringAsFixed(0);

    final String adult = widget.ticketData['adult_count']?.toString() ?? '1';
    final String child = widget.ticketData['child_count']?.toString() ?? '0';
    final String tktType = widget.ticketData['ticket_type']?.toString().toUpperCase() ?? 'JOURNEY';
    final String classType = widget.ticketData['class_type']?.toString().toUpperCase() ?? 'SECOND';
    final String trainType = widget.ticketData['train_type']?.toString().toUpperCase() ?? 'ORDINARY';
    final String fare = widget.ticketData['fare']?.toString() ?? '5.00';
    final String utsNo = widget.ticketData['journey_id']?.toString() ?? 'XEE9ECA34F';
    final String terminalId = widget.ticketData['terminal_id']?.toString() ?? 'R26972';
    final String source = widget.ticketData['source_name']?.toString() ?? 'SEALDAH';
    final String dest = widget.ticketData['dest_name']?.toString() ?? 'PARK CIRCUS';
    final String gstNumber = widget.ticketData['gst_number']?.toString() ?? 'IR:19AAAGM0289C1ZG';

    // 2. Date and Valid Till Calculations
    DateTime bookingDateTime;
    try {
      bookingDateTime = DateTime.parse(widget.ticketData['booking_time']?.toString() ?? DateTime.now().toIso8601String());
    } catch (e) {
      bookingDateTime = DateTime.now();
    }

    // valid till = booked time + (distance in km * 20 minutes)
    int minutesToAdd = (distValue * 20).toInt();
    DateTime validTillDateTime = bookingDateTime.add(Duration(minutes: minutesToAdd));

    final String boxDateFormatted = _formatBookingDateBox(bookingDateTime);
    final String standardBookedDate = _formatStandardDate(bookingDateTime);
    final String standardValidTillDate = _formatStandardDate(validTillDateTime);

    final scaffoldBgColor = Colors.grey.shade200;
    final lightBlueAccent = const Color(0xFFC8E6F5);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2658A6), // UTS Blue Header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Mobile: $_mobileNumber', style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Thank You Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thank You $_userName, Happy Journey !',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
            ),

            // Main Ticket Card Container wrapped in Stack for Notches
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- 1. TOP NARROW LIGHT BLUE STRIP ---
                        Container(
                          height: 12,
                          decoration: BoxDecoration(
                            color: lightBlueAccent,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                        ),

                        // --- 2. BLACK DYNAMIC TICKET BOX (No Border Radius, No Margin) ---
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF1B1B1B), // Dark background
                            borderRadius: BorderRadius.zero,
                            image: DecorationImage(
                              image: AssetImage('assets/ticket_bg.png'),
                              fit: BoxFit.cover,
                              opacity: 0.15,
                            )
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 3. Left Rotated Text & Dotted Line
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: const Text('INDIAN RAILWAYS', style: TextStyle(color: Colors.white54, fontSize: 15, letterSpacing: 1.5)),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomPaint(painter: VerticalDashedLinePainter()),
                                ),

                                // Center Details
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Dynamic preview will close in', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                                        const SizedBox(height: 1),
                                        Text(_formattedTime, style: const TextStyle(color: Colors.redAccent, fontSize: 38, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 3),
                                        const Text('Ticket Booking Date & Time', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                        const SizedBox(height: 1),
                                        Text(boxDateFormatted, style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 1),
                                        Text(terminalId, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                        const SizedBox(height: 4),
                                        const Text('Ticket is Non-Transferable', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                ),

                                // 3. Right Rotated Text & Dotted Line
                                Container(
                                  width: 1,
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomPaint(painter: VerticalDashedLinePainter()),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Center(
                                      child: const Text('भारतीय रेल', style: TextStyle(color: Colors.white54, fontSize: 18, letterSpacing: 1.5)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // --- MAIN WHITE AREA (Details) ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Journey Ticket', style: TextStyle(color: Colors.black87, fontSize: 16)),
                                  Text(utsNo, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Source & Destination
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(child: Text(source, style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.bold))),
                                  Text('—$distance km—', style: const TextStyle(color: Colors.black54, fontSize: 12,)),
                                  Expanded(child: Text(dest, textAlign: TextAlign.right, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold))),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Via & Passengers
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Via', style: TextStyle(color: Colors.black54, fontSize: 13)),
                                      Text('-----', style: TextStyle(color: Colors.black87, fontSize: 15)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('Passenger', style: TextStyle(color: Colors.black54, fontSize: 14)),
                                      Text('$adult Adult, $child Child', style: const TextStyle(color: Colors.black87, fontSize: 15)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),

                              // Dates
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Booked on', style: TextStyle(color: Colors.black54, fontSize: 14)),
                                      Text(standardBookedDate, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text('*Valid Till', style: TextStyle(color: Colors.black54, fontSize: 14)),
                                      Text(standardValidTillDate, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Rest details & GST
                              Text('$classType | $trainType | $tktType | ₹$fare', style: const TextStyle(color: Colors.black87, fontSize: 13,letterSpacing: 1.5)),
                              const SizedBox(height: 2),
                              Text(gstNumber, style: const TextStyle(color: Colors.black87, fontSize: 14)),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        // Divider exactly where notches are
                        const Divider(height: 1, thickness: 1, color: Colors.transparent), // Space holder

                        // --- 5. TEXT UNDER THE NOTCH ---
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                          child: Text(
                            '*Valid for start of journey within 1 hour or until departure of the first train.', // Text from prompt
                            style: TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ),

                        // --- 1 & 5. BOTTOM NARROW LIGHT BLUE STRIP ---
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: lightBlueAccent,
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                        ),












                      ],
                    ),
                  ),

                  // --- 4. NOTCHES (Positioned exactly below the GST number area) ---
                  Positioned(
                    left: -15,
                    bottom: 50, // Moved to bottom position above the text
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: scaffoldBgColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -15,
                    bottom: 50, // Moved to bottom position above the text
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: scaffoldBgColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            //////////////////////////////////////////////////////////////////////////////////////////



            Column(
              children: [
                // Note Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Note: This ticket is non refundable. Ticket is stored\nlocally on the device. Please do not change your\nhandset or perform factory reset.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Book Connecting Journey Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  child:SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.blue.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "Book Connecting Journey",
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ),



                const SizedBox(height: 24),

                // QR Code Image
                Container(
                  //color: Colors.white,
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/qr_code.png', // Replace with your actual asset path
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // Do you know section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey.shade200, // Light grey background
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Do you know?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "IR recovers only 57% of cost of travel on an\naverage.",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey.shade700,

                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "This ticket is booked on a personal user ID.\nIt's sale/purchase is an offence u/s 143 of the\nRailways Act, 1989",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey.shade700,

                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "For enquiry and integrated railway helpline.\nplease dial 139.",
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey.shade700,

                        ),
                      ),
                       const SizedBox(height: 30),
                    ],
                  ),
                ),






              ],
            ),


          /////////////////////////////////////////////////////////////////////////////////////////////
          ],
        ),
      ),
    );
  }
}

// Custom painter used to draw the vertical dashed line safely inside the black container
class VerticalDashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 0;
    final paint = Paint()
    ..color = Colors.white54
    ..strokeWidth = 1;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Dummy class if you don't have the explicit import already in your environment,
// if you do have it, delete this class below and just import your MyBookingsPage.
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: const Center(child: Text('Booking Page')),
    );
  }
}

