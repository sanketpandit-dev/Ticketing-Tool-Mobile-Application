import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/ResolvedTicketsCheckController.dart';
import 'package:tickteting_tool/Controller/update_ticket_controller.dart';
import 'package:tickteting_tool/Model/TicketModel.dart';
import 'package:tickteting_tool/Screens/Tickets/UpdateTickets.dart';
import 'package:tickteting_tool/Screens/User%20Dashboard/ReopenTicket.dart';

class Resolvedticketscheck extends StatefulWidget {
  const Resolvedticketscheck({Key? key}) : super(key: key);

  @override
  _Resolvedticketscheck createState() => _Resolvedticketscheck();
}

class _Resolvedticketscheck extends State<Resolvedticketscheck> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Ticket> _filteredTickets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Resolvedticketscheckcontroller>(context, listen: false).loadTickets();
    });
    _searchController.addListener(_filterTickets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredTickets = [];
      }
    });
  }

  void _filterTickets() {
    final query = _searchController.text.toLowerCase();
    final ticketController = Provider.of<Resolvedticketscheckcontroller>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredTickets = ticketController.tickets;
      } else {
        _filteredTickets = ticketController.tickets.where((ticket) {
          return ticket.ticketNo.toLowerCase().contains(query) ||
              ticket.ticketType.toLowerCase().contains(query) ||
              ticket.department.toLowerCase().contains(query) ||
              ticket.priority.toLowerCase().contains(query) ||
              ticket.status.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green.shade700;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.yellow;
      case 'In Process':
        return const Color(0xFF1976D2);
      case 'Query Raised':
        return const Color(0xFFFB8C00); // Alert Orange
      case 'Release':
        return const Color(0xFF00796B); // Teal
      case 'Close':
        return const Color(0xFF455A64); // Dark Grey
      case 'Reopen':
        return const Color(0xFFE64A19); // Orange Red
      case 'Additional Query':
        return const Color(0xFFFBC02D); // Light Amber
      case 'Discard':
        return const Color(0xFFD32F2F); // Destructive Red
      case 'Resolved':
        return const Color(0xFF388E3C); // Success Green
      case 'Query Replied':
        return const Color(0xFF5C6BC0); // Indigo
      case 'Confirmed':
        return const Color(0xFF512DA8); // Deep Purple
      default:
        return Colors.black;
    }
  }



  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search tickets...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
        )
            : const Text(
          'Ticket List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF3B82F6),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: Consumer<Resolvedticketscheckcontroller>(
        builder: (context, ticketController, child) {
          if (ticketController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ticketController.error.isNotEmpty) {
            return Center(child: Text(ticketController.error, style: TextStyle(color: Colors.red)));
          }
          final tickets = _isSearching ? _filteredTickets : ticketController.tickets;
          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found'));
          }
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final Ticket ticket = tickets[index];
              final dateFormat = DateFormat('M/d/yyyy h:mm:ss a');
              final formattedDate = dateFormat.format(DateTime.tryParse(ticket.createdDate) ?? DateTime.now());
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with Ticket Number and Status
                      Row(
                        children: [
                          Text(
                            ticket.ticketNo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(ticket.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ticket.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Ticket Type
                      Text(
                        ticket.ticketType,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Priority and Department
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: getPriorityColor(ticket.priority).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: getPriorityColor(ticket.priority),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              ticket.priority,
                              style: TextStyle(
                                color: getPriorityColor(ticket.priority),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            ticket.department,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 8),

                      // Created Date
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            'Created: $formattedDate',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                              label: const Text('Confirm & Close'),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Confirm'),
                        content: const Text('Are you sure you want to close this ticket?'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmed == true) {
                    final controller = UpdateTicketController();

                    final result = await controller.updateTicketStatus(
                      ticketNo: ticket.ticketNo,
                      remark: '',
                      statusId: 1004,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['success']
                              ? 'Ticket closed successfully.'
                              : 'Failed to close ticket.'),
                          backgroundColor: result['success'] ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                },

                                 style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),

                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                              label: const Text('Reopen'),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Reopenticket(
                                      ticketData: {
                                        'ticket_no': ticket.ticketNo,
                                        'status': ticket.status,
                                        'createdDate': ticket.createdDate,
                                        'ticketType': ticket.ticketType,
                                        'department': ticket.department,
                                        'priority': ticket.priority,
                                      },
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}