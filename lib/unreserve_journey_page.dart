import 'dart:math';
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'ticket_details_page.dart';


import 'dart:convert'; // Required for LineSplitter
import 'package:flutter/services.dart'; // Required for rootBundle


// --- UNRESERVED JOURNEY PAGE ---
class UnreservedJourneyPage extends StatefulWidget {
  final Map<String, String> source;
  final Map<String, String> destination;

  const UnreservedJourneyPage({
    super.key,
    required this.source,
    required this.destination,
  });

  @override
  State<UnreservedJourneyPage> createState() => _UnreservedJourneyPageState();
}

class _UnreservedJourneyPageState extends State<UnreservedJourneyPage> {
  int adultCount = 1;
  int childCount = 0;

  bool isLoadingData = true;
  double distanceKm = 0.0;
  double baseFarePerAdult = 0.0;
  double totalFare = 0.0;

  // Lets the user manually correct the fare if the auto-calculated one looks wrong.
  bool fareManuallyEdited = false;

  // Optional "via" route text shown on the ticket.
  final TextEditingController viaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRouteDetailsFromWeb();
  }

  @override
  void dispose() {
    viaController.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming Soon!'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }














  Future<List<String>> getLocations(String source, String destination) async {
    try {
      // 1. Load the CSV data
      final String data = await rootBundle.loadString('assets/wb_stations.csv');
      const LineSplitter ls = LineSplitter();
      List<String> lines = ls.convert(data);

      String? sourceLocation;
      String? destinationLocation;

      // Normalize inputs for comparison
      final String searchSource = source.trim().toUpperCase();
      final String searchDest = destination.trim().toUpperCase();

      //debugPrint("Search Source: ${searchSource}");
      //debugPrint("Search Destination: ${searchDest}");

      // 2. Iterate through rows (skipping header)
      for (int i = 1; i < lines.length; i++) {
        List<String> row = lines[i].split(',');
        //debugPrint("Line: ${lines[i]}");

        if (row.length >= 10) {
          String stationName = row[1].trim().toUpperCase();
          String coord = row[13].trim();
          //debugPrint("station: ${stationName}, Location: ${coord}");

          // Check for Source
          if (sourceLocation == null && stationName == searchSource) {
            sourceLocation = coord;
          }
          // Check for Destination
          else if (destinationLocation == null && stationName == searchDest) {
            destinationLocation = coord;
          }
        }

        // 3. Efficiency: Stop searching if both are found
        if (sourceLocation != null && destinationLocation != null) break;
      }

      // Return the list in the specific order requested
      return [
        sourceLocation ?? "Source Not Found",
        destinationLocation ?? "Destination Not Found"
      ];

    } catch (e) {
      debugPrint("Error loading CSV: $e");
      return ["Error", "Error"];
    }
  }



  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295; // Math.PI / 180 (to convert to radians)

    final double a = 0.5 - cos((lat2 - lat1) * p) / 2 +
    cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }





  // Simulating a web API call to fetch distance and fare
  Future<void> _fetchRouteDetailsFromWeb() async {
    setState(() {
      isLoadingData = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Mocking an API response: We generate consistent pseudo-random distance
    // based on the station names so the same route always gives the same distance.
    // int srcLen = widget.source['name']?.length ?? 5;
    // int destLen = widget.destination['name']?.length ?? 5;
    //
    // double fetchedDistance = ((srcLen * destLen * 25) % 950) + 15.0; // Simulated km












    List<String> locations = await getLocations(
      widget.source['name']?.toString() ?? '',
      widget.destination['name']?.toString() ?? '',
    );

    // 1. Safety check to ensure we actually got coordinates
    if (!locations[0].contains('/') || !locations[1].contains('/')) {
      debugPrint("Error: Could not retrieve valid coordinates for distance calculation.");
      return;
    }

    // 2. Split and parse into 4 variables
    List<String> sourceParts = locations[0].split('/');
    List<String> destParts = locations[1].split('/');

    double sLat = double.parse(sourceParts[0]);
    double sLon = double.parse(sourceParts[1]);
    double dLat = double.parse(destParts[0]);
    double dLon = double.parse(destParts[1]);

    // 3. Calculate distance in KM
    double distance = calculateDistance(sLat, sLon, dLat, dLon);

    debugPrint("Source: $sLat, $sLon");
    debugPrint("Destination: $dLat, $dLon");
    debugPrint("Distance: ${distance.toStringAsFixed(2)} KM");
















    double fetchedDistance = distance.roundToDouble();

    // Real West Bengal Suburban (EMU/MEMU) 2nd Class slab fare, not a flat per-km rate.
    double fetchedFare = calculateLocalFare(fetchedDistance).toDouble();

    if (mounted) {
      setState(() {
        distanceKm = fetchedDistance;
        baseFarePerAdult = fetchedFare;
        // A fresh distance fetch should recompute automatically unless the
        // user has already corrected the fare by hand for this journey.
        if (!fareManuallyEdited) {
          _calculateTotalFare();
        }
        isLoadingData = false;
      });
    }
  }

  // Official Kolkata Suburban (EMU/MEMU) 2nd Class fare chart.
  int calculateLocalFare(double distanceInKm) {
    if (distanceInKm <= 0) return 0;
    if (distanceInKm <= 15) return 5;
    if (distanceInKm <= 45) return 10;
    if (distanceInKm <= 70) return 15;
    if (distanceInKm <= 100) return 20;
    if (distanceInKm <= 125) return 25;
    if (distanceInKm <= 150) return 30;
    if (distanceInKm <= 175) return 35;
    if (distanceInKm <= 200) return 40;

    // For distances above 200 km on ordinary non-suburban trains
    return 40 + (((distanceInKm - 200) / 25).ceil() * 5);
  }

  void _calculateTotalFare() {
    // Child fare is typically half of adult fare in unreserved, rounded
    double childFare = (baseFarePerAdult / 2).roundToDouble();
    totalFare = (adultCount * baseFarePerAdult) + (childCount * childFare);
  }

  // Lets the user manually fix the fare if it still looks wrong after auto-calculation.
  Future<void> _showEditFareDialog() async {
    final TextEditingController fareEditController =
    TextEditingController(text: totalFare.toStringAsFixed(0));

    final dynamic result = await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Fare'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'If the calculated fare looks wrong, you can correct it here.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fareEditController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                  labelText: 'Total Fare',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'reset'),
              child: const Text('Reset to Auto'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? val = double.tryParse(fareEditController.text.trim());
                Navigator.pop(dialogContext, val);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || result == null) return;

    if (result == 'reset') {
      setState(() {
        fareManuallyEdited = false;
        _calculateTotalFare();
      });
    } else if (result is double) {
      setState(() {
        totalFare = result;
        fareManuallyEdited = true;
      });
    }
  }














  String _generateRandomNumber(int length) {
    final rand = Random();
    String result = '';
    for (int i = 0; i < length; i++) {
      result += rand.nextInt(10).toString();
    }
    return result;
  }

  String _generateHex(int length) {
    final rand = Random();
    const chars = '0123456789ABCDEF';
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }


























  Future<void> _bookTicket() async {
    if (isLoadingData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait, fetching fare details...')),
      );
      return;
    }

    final rand = Random();
    String irNum = _generateRandomNumber(12);

    String terminalId = 'R269${rand.nextInt(90) + 10}';
    String gsinNo = '19AAAGM0289C1ZG';
    String journeyId = _generateHex(10);

    Map<String, dynamic> bookingData = {
      // FIXED: Added null fallback '??' to prevent the "Null is not a subtype of String" error
      'source_name': widget.source['name'] ?? 'Unknown',
      'dest_name': widget.destination['name'] ?? 'Unknown',
      'adult_count': adultCount,
      'child_count': childCount,
      'booking_time': DateTime.now().toIso8601String(),
      'fare': totalFare,
      'distance': distanceKm,
      'status': 'upcoming',
      'train_type': 'ORDINARY',
      'class_type': 'SECOND',
      'ticket_type': 'JOURNEY',
      'ir_number': irNum,
      'terminal_id': terminalId,
      'gsin_no': gsinNo,
      'journey_id': journeyId,
      'via': viaController.text.trim(),
    };

    await DatabaseHelper().insertBooking(bookingData);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket Booked Successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketDetailsPage(ticketData: bookingData),
        ),
      );
    }
  }



























  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D6EFD);
    const Color textDark = Color(0xFF14224A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unreserved Journey', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text('E-Ticket', style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Stations
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.source['name'] ?? 'Unknown', style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(widget.source['code'] ?? '--', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Icon(Icons.arrow_right_alt, color: Colors.grey.shade400, size: 32),
                    if (!isLoadingData)
                      Text('${distanceKm.toStringAsFixed(1)} km', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.destination['name'] ?? 'Unknown', style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.right),
                      Text(widget.destination['code'] ?? '--', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Via (optional route stations)
                  Text('Via (optional)', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: viaController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'e.g. Dum Dum, Naihati',
                      prefixIcon: Icon(Icons.alt_route, color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.blue.shade100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Train Type
                  Text('Train Type', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                  const SizedBox(height: 8),
                  // FIXED: Changed 'Row' to 'Wrap' to prevent RenderFlex overflow
                  Wrap(
                    spacing: 8.0, // horizontal gap between buttons
                    runSpacing: 8.0, // vertical gap if they wrap to the next line
                    children: [
                      _buildPillButton('ORDINARY', true, () {}),
                      _buildPillButton('MAIL/EXP', false, _showComingSoon),
                      _buildDropdownPill('OTHERS', _showComingSoon),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ticket Type
                  Text('Ticket Type', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildPillButton('JOURNEY', true, () {}),
                      _buildPillButton('RETURN', false, _showComingSoon),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Adult Counter
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Adult', style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        _buildCounter(adultCount, (val) {
                          if (val >= 1 && val <= 4) {
                            setState(() {
                              adultCount = val;
                              if (!fareManuallyEdited) _calculateTotalFare();
                            });
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Child Counter
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue.shade100),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Child', style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        _buildCounter(childCount, (val) {
                          if (val >= 0 && val <= 4) {
                            setState(() {
                              childCount = val;
                              if (!fareManuallyEdited) _calculateTotalFare();
                            });
                          }
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Aged between 5 and 12 years on the day of Travel', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 24),

                  // Class
                  Text('Class', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _buildPillButton('SECOND', true, () {}),
                      _buildPillButton('FIRST', false, _showComingSoon),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avail Concession
                  Row(
                    children: [
                      Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Text('Avail Concession', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Fare and Book Button
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.confirmation_number_outlined, color: primaryBlue),
                        const SizedBox(width: 8),
                        const Text('Fare', style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        isLoadingData
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                        : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('₹ ${totalFare.toStringAsFixed(0)}', style: const TextStyle(color: textDark, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: _showEditFareDialog,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit, size: 14, color: Colors.blue.shade700),
                              ),
                            ),
                          ],
                        ),
                        if (fareManuallyEdited)
                          Text('Manually edited', style: TextStyle(color: Colors.orange.shade700, fontSize: 10)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('Fare Breakup', style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoadingData ? null : _bookTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: const Text('Book Now', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D6EFD) : Colors.white,
          border: Border.all(color: isSelected ? const Color(0xFF0D6EFD) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownPill(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ensure it only takes needed space inside Wrap
          children: [
            Text(text, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(int value, Function(int) onChanged) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(value - 1),
          child: const Icon(Icons.remove, color: Color(0xFF0D6EFD), size: 24),
        ),
        const SizedBox(width: 16),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFF0D6EFD),
            shape: BoxShape.circle,
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () => onChanged(value + 1),
          child: const Icon(Icons.add, color: Color(0xFF0D6EFD), size: 24),
        ),
      ],
    );
  }
}
