import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:tickteting_tool/Controller/update_ticket_controller.dart';


class Viewfullticketdetails extends StatefulWidget {
  final Map<String, dynamic> ticketData;

  const Viewfullticketdetails({
    Key? key,
    required this.ticketData,
  }) : super(key: key);

  @override
  _TicketDetailPageState createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<Viewfullticketdetails> {
  final TextEditingController _remarkController = TextEditingController();
  String _selectedStatus = 'Query Replied';
  List<File> _selectedFiles = [];
  final List<String> _statusOptions = [

    'Query Replied',

  ];

  final UpdateTicketController _ticketController = UpdateTicketController();
  final List<Map<String, dynamic>> _remarks = [];
  bool _isLoading = false;

  String _description = '';
  List<Map<String, dynamic>> _attachments = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingDetails = false;


  final Map<String, int> _statusIdMap = {

    'Query Replied': 1003,

  };

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.ticketData['status'] ?? 'Query Replied';

    if (!_statusOptions.contains(_selectedStatus)) {
      _selectedStatus = 'Query Replied';
    }
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://taskmgmtapi.alphonsol.com/api/ticket/get-ticket-details?ticketNo=${widget.ticketData['ticket_no']}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final attachmentsRaw = List<Map<String, dynamic>>.from(data['attachments'] ?? []);
        final baseUrl = 'http://taskmgmtapi.alphonsol.com/';

        final processedAttachments = attachmentsRaw.map((attachment) {
          return {
            ...attachment,
            'attachmentUrl': baseUrl + (attachment['filePath'] ?? ''),
          };
        }).toList();

        setState(() {
          _description = data['description'] ?? '';
          _attachments = processedAttachments;
          _transactions = List<Map<String, dynamic>>.from(data['transactions'] ?? []);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ticket details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }



  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles = result.paths
              .map((path) => File(path!))
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking files: $e')),
      );
    }
  }

  Future<void> _addRemark() async {
    if (_remarkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a remark')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get status ID from the map, default to Query Replied (1003)
      final statusId = _statusIdMap[_selectedStatus] ?? 1003;

      // Call the controller to update ticket
      final results = await _ticketController.uploadMultipleFiles(
        ticketNo: widget.ticketData['ticket_no'],
        remark: _remarkController.text,
        files: _selectedFiles,
        statusId: statusId,
      );

      // Check if all operations were successful
      bool allSuccessful = results.every((result) => result['success'] == true);

      if (allSuccessful) {
        // Add remark to local state for immediate UI update
        setState(() {
          _remarks.add({
            'text': _remarkController.text,
            'timestamp': DateTime.now(),
            'files': _selectedFiles.map((file) => file.path.split('/').last).toList(),
          });
          _remarkController.clear();
          _selectedFiles = [];
          widget.ticketData['status'] = _selectedStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket updated successfully')),
        );

        // Refresh ticket details to show the latest changes
        _fetchTicketDetails();
      } else {
        // Some operations failed, show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Some operations failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateTicket() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get status ID from the map, default to Query Replied (1003)
      final statusId = _statusIdMap[_selectedStatus] ?? 1003;

      // Call the controller to update ticket status (without files or remarks)
      final result = await _ticketController.updateTicketStatus(
        ticketNo: widget.ticketData['ticket_no'],
        remark: '', // Empty remark for status update only
        statusId: statusId,
      );

      if (result['success']) {
        setState(() {
          widget.ticketData['status'] = _selectedStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket status updated successfully')),
        );

        // Refresh ticket details to show the latest changes
        _fetchTicketDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: ${result['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    final DateTime date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Ticket Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
      ),
      body: _isLoading || _isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTicketHeader(),
            const SizedBox(height: 16),
            _buildTicketDetails(),
            const SizedBox(height: 16),
            _buildTransactionHistory(),
            const SizedBox(height: 16),

            if (_remarks.isNotEmpty) const SizedBox(height: 16),

            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3B82F6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.ticketData['ticket_no'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.ticketData['status'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Created on ${_formatDate(widget.ticketData['createdDate'])}',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor([String? status]) {
    final statusToCheck = status?.toLowerCase() ?? widget.ticketData['status']?.toLowerCase();

    switch (statusToCheck) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'query raised':
        return Colors.purple;
      case 'query replied':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  Widget _buildTicketDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ticket Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Ticket Type', widget.ticketData['ticketType']),
          _buildInfoRow('Department', widget.ticketData['department']),
          _buildInfoRow('Priority', widget.ticketData['priority']),
          if (_description.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
          if (_attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Attachments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _attachments.map((attachment) {
                return InkWell(
                  onTap: () async {
                    final url = attachment['attachmentUrl'];
                    print("Trying to launch: $url");

                    if (url != null && await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not open attachment')),
                      );
                    }
                  },

                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          attachment['fileName'].length > 15
                              ? attachment['fileName'].substring(0, 12) + '...'
                              : attachment['fileName'],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    if (_transactions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _transactions.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final transaction = _transactions[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction['statusName']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(transaction['statusName']),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            transaction['statusName'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(DateTime.parse(transaction['insertedDate'])),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    if (transaction['remarks']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Text(
                        transaction['remarks'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                    if (transaction['queryRemark']?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.question_answer,
                              color: Colors.blue,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                transaction['queryRemark'],
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

}