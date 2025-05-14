class DashTicketModel {
  final String? ticketNumber;
  final String? createdDate;
  final String? ticketType;
  final String? department;
  final String? priority;
  final String? status;
  final int? insertedBy;

  DashTicketModel({
    this.ticketNumber,
    this.createdDate,
    this.ticketType,
    this.department,
    this.priority,
    this.status,
    this.insertedBy,
  });

  factory DashTicketModel.fromJson(Map<String, dynamic> json) {
    return DashTicketModel(
      ticketNumber: json['ticket_no'],
      createdDate: json['createdDate'],
      ticketType: json['ticketType'],
      department: json['department'],
      priority: json['priority'],
      status: json['status'],
      insertedBy: json['inserted_by'],
    );
  }
}

class TicketListResponse {
  final bool success;
  final String message;
  final List<DashTicketModel> data;

  TicketListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TicketListResponse.fromJson(Map<String, dynamic> json) {
    List<DashTicketModel> tickets = [];
    if (json['Data'] != null) {
      tickets = (json['Data'] as List)
          .map((ticket) => DashTicketModel.fromJson(ticket))
          .toList();
    }

    return TicketListResponse(
      success: json['Success'] ?? false,
      message: json['Message'] ?? '',
      data: tickets,
    );
  }
}