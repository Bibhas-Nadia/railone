import 'package:flutter/material.dart';


class TicketCardWidget extends StatelessWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onBookAgain;
  final VoidCallback onViewDetails;

  const TicketCardWidget({
    super.key,
    required this.ticket,
    required this.onBookAgain,
    required this.onViewDetails,
  });

  String _formatDate(String? isoString) {
    if (isoString == null) return 'Tue, 21 Apr 26';
    try {
      DateTime dt = DateTime.parse(isoString);
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[dt.weekday - 1]}, ${dt.day} ${months[dt.month - 1]} ${dt.year.toString().substring(2)}';
    } catch (e) {
      return 'Unknown Date';
    }
  }



  // Inside TicketCardWidget build method
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onViewDetails, // Makes the whole ticket card clickable
        child: CustomPaint(
          painter: TicketPainter(
            bgColor: const Color(0xFFF7F8FA),
            borderColor: Colors.green.shade600,
            dashColor: Colors.green.shade300,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ... rest of your existing Column code (Padding, Rows, etc.)
              // Decreased padding for a more compact look
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  children: [
                    // Top Row: Unreserved Pill & UTS Number
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Unreserved',
                            style: TextStyle(color: Colors.purple.shade300, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        // "UTS:" in grey, Number in black
                        RichText(
                          text: TextSpan(
                            text: 'UTS: ',
                            style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: ticket['journey_id']?.toString().toUpperCase() ?? 'XEE9ECA34F',
                                style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Middle Row: Ticket Type & Booking Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ticket Type', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(ticket['ticket_type'] ?? 'JOURNEY', style: const TextStyle(color: Colors.black87, fontSize: 12)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Booking Date', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                            const SizedBox(height: 2),
                            Text(_formatDate(ticket['booking_time']), style: const TextStyle(color: Colors.black87, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bottom Row: Stations and Distance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            ticket['source_name'] ?? 'SEALDAH',
                            style: const TextStyle(color: Colors.black87, fontSize: 12), // Removed bold
                          ),
                        ),
                        Text(
                          '  — ${ticket['distance']?.toStringAsFixed(0) ?? 3} km —  ',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                        ),
                        Expanded(
                          child: Text(
                            ticket['dest_name'] ?? 'PARK CIRCUS',
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.black87, fontSize: 12), // Removed bold
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons Area
              SizedBox(
                height: 44, // Slightly shorter for compactness
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: onBookAgain,
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12))),
                        ),
                        child: const Text('Book Again', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 15)), // Removed bold
                      ),
                    ),
                    VerticalDivider(color: Colors.grey.shade300, width: 1, thickness: 1, indent: 10, endIndent: 10),
                    Expanded(
                      child: TextButton(
                        onPressed: onViewDetails,
                        style: TextButton.styleFrom(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12))),
                        ),
                        child: const Text('View Details', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 15)), // Removed bold
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }



  // @override
  // Widget build(BuildContext context) {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: CustomPaint(
  //       painter: TicketPainter(
  //         bgColor: const Color(0xFFF7F8FA), // Greyish inside color
  //         borderColor: Colors.green.shade600,
  //         dashColor: Colors.green.shade300,
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           // Decreased padding for a more compact look
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
  //             child: Column(
  //               children: [
  //                 // Top Row: Unreserved Pill & UTS Number
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //                       decoration: BoxDecoration(
  //                         color: Colors.purple.shade50,
  //                         borderRadius: BorderRadius.circular(6),
  //                       ),
  //                       child: Text(
  //                         'Unreserved',
  //                         style: TextStyle(color: Colors.purple.shade300, fontWeight: FontWeight.bold, fontSize: 12),
  //                       ),
  //                     ),
  //                     // "UTS:" in grey, Number in black
  //                     RichText(
  //                       text: TextSpan(
  //                         text: 'UTS: ',
  //                         style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600),
  //                         children: [
  //                           TextSpan(
  //                             text: ticket['journey_id']?.toString().toUpperCase() ?? 'XEE9ECA34F',
  //                             style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 16),
  //
  //                 // Middle Row: Ticket Type & Booking Date
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         Text('Ticket Type', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
  //                         const SizedBox(height: 2),
  //                         Text(ticket['ticket_type'] ?? 'JOURNEY', style: const TextStyle(color: Colors.black87, fontSize: 12)),
  //                       ],
  //                     ),
  //                     Column(
  //                       crossAxisAlignment: CrossAxisAlignment.end,
  //                       children: [
  //                         Text('Booking Date', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
  //                         const SizedBox(height: 2),
  //                         Text(_formatDate(ticket['booking_time']), style: const TextStyle(color: Colors.black87, fontSize: 12)),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 12),
  //
  //                 // Bottom Row: Stations and Distance
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: Text(
  //                         ticket['source_name'] ?? 'SEALDAH',
  //                         style: const TextStyle(color: Colors.black87, fontSize: 12), // Removed bold
  //                       ),
  //                     ),
  //                     Text(
  //                       '  — ${ticket['distance']?.toStringAsFixed(0) ?? 3} km —  ',
  //                       style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
  //                     ),
  //                     Expanded(
  //                       child: Text(
  //                         ticket['dest_name'] ?? 'PARK CIRCUS',
  //                         textAlign: TextAlign.right,
  //                         style: const TextStyle(color: Colors.black87, fontSize: 12), // Removed bold
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //
  //           // Action Buttons Area
  //           SizedBox(
  //             height: 44, // Slightly shorter for compactness
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 Expanded(
  //                   child: TextButton(
  //                     onPressed: onBookAgain,
  //                     style: TextButton.styleFrom(
  //                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12))),
  //                     ),
  //                     child: const Text('Book Again', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 15)), // Removed bold
  //                   ),
  //                 ),
  //                 VerticalDivider(color: Colors.grey.shade300, width: 1, thickness: 1, indent: 10, endIndent: 10),
  //                 Expanded(
  //                   child: TextButton(
  //                     onPressed: onViewDetails,
  //                     style: TextButton.styleFrom(
  //                       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(12))),
  //                     ),
  //                     child: const Text('View Details', style: TextStyle(color: Color(0xFF0D6EFD), fontSize: 15)), // Removed bold
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class TicketPainter extends CustomPainter {
  final Color bgColor;
  final Color borderColor;
  final Color dashColor;

  TicketPainter({required this.bgColor, required this.borderColor, required this.dashColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = bgColor..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = borderColor..style = PaintingStyle.stroke..strokeWidth = 1.0;

    final path = Path();
    final radius = 12.0; // Decreased ticket border radius
    final notchRadius = 16.0;
    final notchY = size.height - 44.0; // Matches the 44px button row height

    // Draw Ticket Outline Path
    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: Radius.circular(radius));

    path.lineTo(size.width, notchY - notchRadius);
    path.arcToPoint(Offset(size.width, notchY + notchRadius), radius: Radius.circular(notchRadius), clockwise: false);

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: Radius.circular(radius));

    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius), radius: Radius.circular(radius));

    path.lineTo(0, notchY + notchRadius);
    path.arcToPoint(Offset(0, notchY - notchRadius), radius: Radius.circular(notchRadius), clockwise: false);

    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0), radius: Radius.circular(radius));

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    final dashPaint = Paint()..color = dashColor..style = PaintingStyle.stroke..strokeWidth = 1.0;
    double dashWidth = 4;
    double dashSpace = 4;

    // Line now starts exactly at the edge of the notch and ends at the other edge
    double startX = notchRadius;
    while (startX < size.width - notchRadius) {
      canvas.drawLine(Offset(startX, notchY), Offset(startX + dashWidth, notchY), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
