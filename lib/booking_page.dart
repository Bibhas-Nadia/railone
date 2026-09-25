

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'database_helper.dart'; // Import your new DB helper
import 'unreserve_journey_page.dart';

// --- MAIN BOOKING PAGE ---
class UnreservedBookingPage extends StatefulWidget {
  const UnreservedBookingPage({super.key});

  @override
  State<UnreservedBookingPage> createState() => _UnreservedBookingPageState();
}

class _UnreservedBookingPageState extends State<UnreservedBookingPage> {
  String selectedTicketType = 'Normal';
  String selectedLocation = 'Outside Station';

  Map<String, String>? sourceStation;
  Map<String, String>? destinationStation;

  // List to hold dynamic recent searches from SQLite
  List<Map<String, dynamic>> recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  // Fetch searches from SQLite
  Future<void> _loadRecentSearches() async {
    final data = await DatabaseHelper().getRecentSearches();
    setState(() {
      recentSearches = data;
    });
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

  void _swapStations() {
    setState(() {
      final temp = sourceStation;
      sourceStation = destinationStation;
      destinationStation = temp;
    });
  }

  Future<void> _openSearchPage(bool isSource) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchStationPage(
          title: isSource ? 'Source' : 'Destination',
        ),
      ),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        if (isSource) {
          sourceStation = result;
        } else {
          destinationStation = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF0D6EFD);
    const Color textDark = Color(0xFF14224A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Unreserved E-Ticket',
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Icon(Icons.close, color: primaryBlue, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Booking Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Normal / Season Toggle
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildToggleButton('Normal', selectedTicketType == 'Normal', true, () {
                            setState(() => selectedTicketType = 'Normal');
                          }),
                          _buildToggleButton('Season', selectedTicketType == 'Season', true, () {
                            setState(() => selectedTicketType = 'Season');
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Outside / At Station Toggle
                    Row(
                      children: [
                        _buildToggleButton('Outside Station', selectedLocation == 'Outside Station', false, () {
                          setState(() => selectedLocation = 'Outside Station');
                        }, showIcon: true),
                        const SizedBox(width: 8),
                        _buildToggleButton('At Station', selectedLocation == 'At Station', false, () {
                          setState(() => selectedLocation = 'At Station');
                        }, showIcon: true),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Station Selection (From / To)
                    Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('From', style: TextStyle(color: Colors.lightBlue, fontSize: 16, fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () => _openSearchPage(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.directions_transit, color: Colors.grey.shade400),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sourceStation != null ? '${sourceStation!['name']} - ${sourceStation!['code']}' : 'Source',
                                        style: TextStyle(
                                          // FIX: Adjusted font size to make bold text smaller (14 instead of 16)
                                          fontSize: sourceStation != null ? 14 : 16,
                                          color: sourceStation != null ? textDark : Colors.grey.shade400,
                                          fontWeight: sourceStation != null ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text('To', style: TextStyle(color: Colors.lightBlue, fontSize: 16, fontWeight: FontWeight.w500)),
                            GestureDetector(
                              onTap: () => _openSearchPage(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.directions_transit, color: Colors.grey.shade400),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        destinationStation != null ? '${destinationStation!['name']} - ${destinationStation!['code']}' : 'Destination',
                                        style: TextStyle(
                                          // FIX: Adjusted font size to make bold text smaller
                                          fontSize: destinationStation != null ? 14 : 16,
                                          color: destinationStation != null ? textDark : Colors.grey.shade400,
                                          fontWeight: destinationStation != null ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Swap Button
                        Positioned(
                          right: 16,
                          child: GestureDetector(
                            onTap: _swapStations,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.swap_vert, color: primaryBlue),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (sourceStation == null || destinationStation == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both stations')));
                            return;
                          }

                          // Save to SQLite database before proceeding
                          await DatabaseHelper().insertRecentSearch(sourceStation!, destinationStation!);

                          // Refresh the recent searches list
                          _loadRecentSearches();

                          // Redirect to processing page
                          if(context.mounted){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UnreservedJourneyPage(
                                  source: sourceStation!,
                                  destination: destinationStation!,
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Proceed To Book', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _showComingSoon,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: primaryBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Check Upcoming Trains', style: TextStyle(fontSize: 16, color: primaryBlue)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Recent Searches Section (Now Dynamic!)
              const Text('Recent Searches', style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              recentSearches.isEmpty
              ? const Text("No recent searches yet.", style: TextStyle(color: Colors.grey))
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: recentSearches.map((search) {
                    return _buildRecentSearchCard(
                      '${search['from_name']}, ${search['from_code']}',
                      '${search['to_name']}, ${search['to_code']}'
                    );
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, bool isPillStyle, VoidCallback onTap, {bool showIcon = false}) {
    if (isPillStyle) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.all(4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? const Color(0xFF0D6EFD) : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    } else {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            // FIX: Adjusted vertical padding and added horizontal padding so the icon isn't cramped
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D6EFD) : Colors.white,
              border: Border.all(color: isSelected ? const Color(0xFF0D6EFD) : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible( // Wrap in flexible to prevent text overflow
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 13, // Slightly reduced to fit better with the icon
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                ),
                if (showIcon) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 16, color: isSelected ? Colors.white : Colors.grey.shade400)
                ]
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildRecentSearchCard(String from, String to) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDBE7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(from, style: const TextStyle(color: Color(0xFF14224A), fontSize: 13), textAlign: TextAlign.center),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Icon(Icons.swap_calls, color: Colors.blue, size: 20),
          ),
          Text(to, style: const TextStyle(color: Color(0xFF14224A), fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// --- SEARCH STATION PAGE ---
// (Your SearchStationPage remains exactly the same as before!)
class SearchStationPage extends StatefulWidget {
  final String title;
  const SearchStationPage({super.key, required this.title});

  @override
  State<SearchStationPage> createState() => _SearchStationPageState();
}

class _SearchStationPageState extends State<SearchStationPage> {
  List<Map<String, String>> allStations = [];
  List<Map<String, String>> filteredStations = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    try {
      final String data = await rootBundle.loadString('assets/wb_stations.csv');
      LineSplitter ls = const LineSplitter();
      List<String> lines = ls.convert(data);
      List<Map<String, String>> stations = [];

      for (int i = 1; i < lines.length; i++) {
        List<String> row = lines[i].split(',');
        if (row.length >= 10) {
          stations.add({
            'name': row[1].trim().toUpperCase(),
            'code': row[2].trim().toUpperCase(),
            'district': row[7].trim().toUpperCase(),
            'state': row[8].trim().toUpperCase(),
          });
        }
      }

      setState(() {
        allStations = stations;
        filteredStations = stations.take(50).toList();
      });
    } catch (e) {
      debugPrint("Error loading CSV: $e");
    }
  }

  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredStations = allStations.take(50).toList();
      });
      return;
    }

    List<Map<String, String>> dummySearchList = [];
    dummySearchList.addAll(allStations);

    if (query.isNotEmpty) {
      List<Map<String, String>> dummyListData = [];
      for (var item in dummySearchList) {
        if (item['name']!.contains(query.toUpperCase()) || item['code']!.contains(query.toUpperCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        filteredStations = dummyListData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF14224A);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Icon(Icons.close, color: Color(0xFF0D6EFD), size: 20),
            ),
          ),
        ),
        title: const Text('Search Station', style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: searchController,
                  onChanged: _filterSearchResults,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: const Icon(Icons.mic, color: Colors.grey),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.green.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.green.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.green.shade400),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: filteredStations.isEmpty
              ? const Center(child: Text("Type to search stations..."))
              : ListView.separated(
                itemCount: filteredStations.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                itemBuilder: (context, index) {
                  final station = filteredStations[index];
                  return ListTile(
                    onTap: () {
                      Navigator.pop(context, station);
                    },
                    title: Text(
                      '${station['name']} - ${station['code']}',
                      style: const TextStyle(color: textDark, fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${station['district']}, ${station['state']}',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PROCEED TO BOOK (SUCCESS PAGE) ---
// (Remains the same as before)
// class ProceedToBookPage extends StatelessWidget {
//   const ProceedToBookPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Processing Booking...')),
//       body: const Center(
//         child: Text(
//           'Booking Logic Goes Here!',
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }
