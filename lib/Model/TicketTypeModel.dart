class TicketType {
  final int ticketTypeId;
  final String ticketTypeName;
  final int departmentId;

  TicketType({
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.departmentId,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    print('Parsing ticket type JSON: $json');
    
    // Handle potential null values with default values
    final ticketTypeId = json['ticket_type_mast_id'] ?? 0;
    final ticketTypeName = json['ticket_type_name'] ?? '';
    final departmentId = json['dept_mast_id'] ?? 0;

    // Validate the values
    if (ticketTypeId == 0 || ticketTypeName.isEmpty || departmentId == 0) {
      print('Warning: Invalid ticket type data - ID: $ticketTypeId, Name: $ticketTypeName, DeptID: $departmentId');
    }

    return TicketType(
      ticketTypeId: ticketTypeId,
      ticketTypeName: ticketTypeName,
      departmentId: departmentId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_type_mast_id': ticketTypeId,
      'ticket_type_name': ticketTypeName,
      'dept_mast_id': departmentId,
    };
  }
} 