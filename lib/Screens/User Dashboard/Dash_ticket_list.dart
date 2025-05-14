import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/Dash_ticket_list.dart';
import 'package:tickteting_tool/Model/Dash_ticket_model.dart';


class DashTicketListScreen extends StatefulWidget {
  final String statusType;

  const DashTicketListScreen({
    Key? key,
    required this.statusType,
  }) : super(key: key);

  @override
  State<DashTicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<DashTicketListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TicketListController>(context, listen: false)
          .loadTicketsByStatus(widget.statusType);
    });
  }

  Color getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'discard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "${widget.statusType} Tickets",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF3B82F6),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              Provider.of<TicketListController>(context, listen: false)
                  .loadTicketsByStatus(widget.statusType);
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      body: Consumer<TicketListController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      controller.loadTicketsByStatus(widget.statusType);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }


          if (controller.tickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined, size: 70, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    'No ${widget.statusType} tickets found',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return _buildTicketList(controller.tickets);
        },
      ),
    );
  }

  Widget _buildTicketList(List<DashTicketModel> tickets) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${tickets.length} ${widget.statusType} Tickets',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columnSpacing: 20,
                      headingRowColor: MaterialStateProperty.all(Colors.lightBlue.withOpacity(0.1)),
                      columns: const [
                        DataColumn(label: Text('Ticket ', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Created Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: tickets.map((ticket) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(ticket.ticketNumber ?? '-'),
                              onTap: () {
                                // View ticket details
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Viewing ticket: ${ticket.ticketNumber}'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  ticket.ticketType ?? '-',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text(ticket.department ?? '-')),
                            DataCell(Text(ticket.priority ?? '-')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: getStatusColor(ticket.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  ticket.status ?? '-',
                                  style: TextStyle(
                                    color: getStatusColor(ticket.status),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                                Text(
                                    ticket.createdDate != null
                                        ? ticket.createdDate!.substring(0, 10)
                                        : '-'
                                )
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}