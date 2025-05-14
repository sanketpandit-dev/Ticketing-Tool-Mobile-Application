class Ticket {
  final String ticketNo;
  final String createdDate;
  final String ticketType;
  final String department;
  final String priority;
  final String status;

  Ticket({
    required this.ticketNo,
    required this.createdDate,
    required this.ticketType,
    required this.department,
    required this.priority,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketNo: json['ticket_no'] ?? '',
      createdDate: json['createdDate'] ?? '',
      ticketType: json['ticketType'] ?? '',
      department: json['department'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
    );
  }
} 