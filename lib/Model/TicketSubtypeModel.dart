class TicketSubtype {
  final int ticketSubtypeId;
  final String ticketSubtypeName;

  TicketSubtype({
    required this.ticketSubtypeId,
    required this.ticketSubtypeName,
  });

  factory TicketSubtype.fromJson(Map<String, dynamic> json) {
    return TicketSubtype(
      ticketSubtypeId: json['ticket_subtype_mast_id'] ?? 0,
      ticketSubtypeName: json['ticket_subtype_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_subtype_mast_id': ticketSubtypeId,
      'ticket_subtype_name': ticketSubtypeName,
    };
  }
} 