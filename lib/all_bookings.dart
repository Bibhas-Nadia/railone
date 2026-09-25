import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'ticket_card_widget.dart';
import 'unreserve_journey_page.dart';
import 'ticket_details_page.dart';

class AllBookings extends StatefulWidget {
  const AllBookings({super.key});

  @override
  State<AllBookings> createState() => _AllBookingsState();
}

class _AllBookingsState extends State<AllBookings> {
  List<Map<String, dynamic>> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await DatabaseHelper().getBookingsByStatus('all');
    setState(() {
      _tickets = data;
      _isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Top Header section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            child: SizedBox(
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'All tickets (${_tickets.length})',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: _fetchData,
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Body section (Shows Empty State OR List of Tickets)
        Expanded(
          child: _tickets.isEmpty
          ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_activity, // Ticket outline icon
                  size: 100,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Tickets Found. Swipe down to refresh.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
          : ListView.builder(
            itemCount: _tickets.length,




            itemBuilder: (context, index) {
              final ticket = _tickets[index];
              return TicketCardWidget(
                ticket: ticket,

                onBookAgain: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UnreservedJourneyPage(
                        source: {"name": (ticket['source_name'] ?? 'SEALDAH').toString()},
                        destination: {"name": (ticket['dest_name'] ?? 'PARK CIRCUS').toString()},
                      ),
                    ),
                  );
                },

                onViewDetails: () {

                  // FIX: Safely casting dynamic map to String map to prevent "Null" type errors
                  final Map<String, String> safeTicketData = ticket.map(
                    (key, value) => MapEntry(key, value?.toString() ?? ''),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TicketDetailsPage(ticketData: safeTicketData),
                    ),
                  );
                }

              );
            }

          ),
        ),
      ],
    );
  }
}
