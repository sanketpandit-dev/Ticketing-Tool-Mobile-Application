class TicketResponseModel {
  final String status;
  final String ticketNo;
  final int ticketId;
  final String message;

  TicketResponseModel({
    required this.status,
    required this.ticketNo,
    required this.ticketId,
    required this.message,
  });

  factory TicketResponseModel.fromJson(Map<String, dynamic> json) {
    return TicketResponseModel(
      status: json['Status'] ?? '',
      ticketNo: json['TicketNo'] ?? '',
      ticketId: json['TicketId'] ?? 0,
      message: json['Message'] ?? '',
    );
  }
}