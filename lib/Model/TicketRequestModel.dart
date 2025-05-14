class TicketRequestModel {
  final String ticketName;
  final String ticketDescription;
  final int departmentId;
  final int ticketTypeId;
  final int ticketSubTypeId;
  final int priority;
  final int isManual;
  final int insertedBy;
  final int ticketStatus;
  final String? fileName; // made optional
  final String? base64FileContent; // made optional

  TicketRequestModel({
    required this.ticketName,
    required this.ticketDescription,
    required this.departmentId,
    required this.ticketTypeId,
    required this.ticketSubTypeId,
    required this.priority,
    required this.isManual,
    required this.insertedBy,
    required this.ticketStatus,
    this.fileName,
    this.base64FileContent,
  });

  Map<String, dynamic> toJson() {
    return {
      'TicketName': ticketName,
      'TicketDescription': ticketDescription,
      'DepartmentId': departmentId,
      'TicketTypeId': ticketTypeId,
      'TicketSubTypeId': ticketSubTypeId,
      'Priority': priority,
      'IsManual': isManual,
      'InsertedBy': insertedBy,
      'TicketStatus': ticketStatus,
      'FileName': fileName ?? '',
      'Base64FileContent': base64FileContent ?? '',
    };
  }
}
