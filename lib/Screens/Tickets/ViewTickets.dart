import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/TicketController.dart';
import 'package:tickteting_tool/Model/TicketModel.dart';
import 'package:tickteting_tool/Screens/Tickets/UpdateTickets.dart';
import 'package:tickteting_tool/Screens/Tickets/ViewFullTicketDetails.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  _TicketListScreenState createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Ticket> _filteredTickets = [];
  String? _selectedStatus;


  final List<String> _statusOptions = [
    'All',
    'Pending',
    'In Process',
    'Query Raised',
    'Release',
    'Close',
    'Reopen',
    'Discard',
    'Resolved',
    'Query Replied',
    'Confirmed',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketController>(context, listen: false).loadTickets();
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
        _filterTickets();
      }
    });
  }

  void _filterTickets() {
    final query = _searchController.text.toLowerCase();
    final ticketController = Provider.of<TicketController>(context, listen: false);
    final allTickets = ticketController.tickets;

    setState(() {
      // First filter by status if selected
      List<Ticket> statusFiltered = _selectedStatus == null || _selectedStatus == 'All'
          ? allTickets
          : allTickets.where((ticket) => ticket.status == _selectedStatus).toList();

      // Then apply text search if there's a query
      if (query.isEmpty) {
        _filteredTickets = statusFiltered;
      } else {
        _filteredTickets = statusFiltered.where((ticket) {
          return ticket.ticketNo.toLowerCase().contains(query) ||
              ticket.ticketType.toLowerCase().contains(query) ||
              ticket.department.toLowerCase().contains(query) ||
              ticket.priority.toLowerCase().contains(query) ||
              ticket.status.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Check if the edit button should be enabled based on status
  bool _isEditEnabled(String status) {
    return status == 'Query Raised' || status == 'Query Replied';
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
        return Colors.orange;
      case 'In Process':
        return Colors.blue;
      case 'Query Raised':
        return Colors.orange.shade700;
      case 'Release':
        return Colors.teal;
      case 'Close':
        return Colors.grey.shade700;
      case 'Reopen':
        return Colors.deepOrange;
      case 'Additional Query':
        return Colors.amber;
      case 'Discard':
        return Colors.red;
      case 'Resolved':
        return Colors.green;
      case 'Query Replied':
        return Colors.indigo;
      case 'Confirmed':
        return Colors.deepPurple;
      default:
        return Colors.blue;
    }
  }


  void _showEditNotAllowedNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit option is only available for "Query Raised" and "Query Replied" statuses'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
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

  Widget _buildStatusFilterDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: _selectedStatus,
            hint: Text(
              'Status',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w500,
              ),
            ),
            icon: Icon(
              Icons.filter_list,
              color: Color(0xFF3B82F6),
              size: 20,
            ),
            isDense: true,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(8),
            dropdownColor: Colors.white,
            style: TextStyle(color: Color(0xFF3B82F6)),
            items: _statusOptions.map((String status) {
              return DropdownMenuItem<String>(
                value: status == 'All' ? null : status,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 3,horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: status == _selectedStatus
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedStatus = value;
                _filterTickets();
              });
            },
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
        
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
            'Tickets',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          ),
          backgroundColor: Color(0xFF3B82F6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          actions: [
            if (!_isSearching) _buildStatusFilterDropdown(),
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
              onPressed: _toggleSearch,
            ),
          ],
        
        ),
      ),
      body: Consumer<TicketController>(
        builder: (context, ticketController, child) {
          if (ticketController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ticketController.error.isNotEmpty) {
            return Center(child: Text(ticketController.error, style: TextStyle(color: Colors.red)));
          }

          final tickets = _isSearching || _selectedStatus != null ? _filteredTickets : ticketController.tickets;
          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found'));
          }

          return ListView.builder(
            itemCount: tickets.length,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, index) {
              final Ticket ticket = tickets[index];
              final dateFormat = DateFormat('M/d/yyyy');
              final timeFormat = DateFormat('h:mm a');
              DateTime? createdDateTime;
              String formattedDate = '';
              String formattedTime = '';

              try {
                createdDateTime = DateTime.parse(ticket.createdDate);
                formattedDate = dateFormat.format(createdDateTime);
                formattedTime = timeFormat.format(createdDateTime);
              } catch (e) {
                formattedDate = ticket.createdDate;
              }

              final bool canEdit = _isEditEnabled(ticket.status);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      // Header section with colored border and status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: getStatusColor(ticket.status),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              ticket.ticketNo,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Spacer(),
                            Text(
                              ticket.status,
                              style: TextStyle(
                                color: getStatusColor(ticket.status),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(height: 1, thickness: 1, color: Colors.grey.shade200),

                      // Content section
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.ticketType,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.department,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  formattedTime,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: getPriorityColor(ticket.priority).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
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
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Button section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.3),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.visibility, size: 16, color: Colors.white),
                                  label: const Text(
                                    'View',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Viewfullticketdetails(ticketData: {
                                          'ticket_no': ticket.ticketNo,
                                          'status': ticket.status,
                                          'createdDate': ticket.createdDate,
                                          'ticketType': ticket.ticketType,
                                          'department': ticket.department,
                                          'priority': ticket.priority,
                                        }),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    elevation: 4,
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    // BoxShadow(
                                    //   color: canEdit
                                    //       ? Colors.blue.withOpacity(0.2)
                                    //       : Colors.grey.withOpacity(0.2),
                                    //   spreadRadius: 1,
                                    //   blurRadius: 6,
                                    //   offset: const Offset(0, 3),
                                    // ),
                                  ],
                                ),
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    Icons.edit,
                                    size: 16,
                                    color: canEdit ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                                  ),
                                  label: Text(
                                    'Edit',
                                    style: TextStyle(
                                      color: canEdit ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  onPressed: canEdit
                                      ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TicketDetailPage(
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
                                  }
                                      : () => _showEditNotAllowedNotification(),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: canEdit ? const Color(0xFF3B82F6) : Colors.grey.shade400,
                                    side: BorderSide(
                                      color: canEdit ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),


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