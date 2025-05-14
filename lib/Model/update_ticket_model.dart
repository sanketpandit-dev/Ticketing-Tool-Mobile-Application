
class UpdateTicketModel {
  final String ticketNo;
  final int userId;
  final int statusId;
  final String? queryReply;
  final String? fileName;
  final String? base64FileContent;

  UpdateTicketModel({
    required this.ticketNo,
    required this.userId,
    required this.statusId,
    this.queryReply,
    this.fileName,
    this.base64FileContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'TicketNo': ticketNo,
      'UserId': userId,
      'StatusId': statusId,
      'QueryReply': queryReply,
      'FileName': fileName,
      'Base64FileContent': base64FileContent,
    };
  }
}