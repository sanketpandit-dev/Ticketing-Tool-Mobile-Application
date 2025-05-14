import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/TicketSubtypeModel.dart';

class TicketSubtypeService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com/api';

  Future<List<TicketSubtype>> getTicketSubtypesByType(int ticket_type_mast_id) async {
    try {
      final url = Uri.parse('$baseUrl/ticket/getTicketSubTypesByType?ticket_type_mast_id=$ticket_type_mast_id');
      print('Making GET request to: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          print('Parsed JSON data: $jsonData');

          if (jsonData.isEmpty) {
            print('Warning: No ticket subtypes found for ticket type $ticket_type_mast_id');
            return [];
          }

          final ticketSubtypes = <TicketSubtype>[];
          for (var json in jsonData) {
            try {
              final ticketSubtype = TicketSubtype.fromJson(json);
              if (ticketSubtype.ticketSubtypeId != 0 && ticketSubtype.ticketSubtypeName.isNotEmpty) {
                ticketSubtypes.add(ticketSubtype);
              } else {
                print('Skipping invalid ticket subtype: $json');
              }
            } catch (e) {
              print('Error parsing individual ticket subtype: $e\nJSON: $json');
            }
          }

          print('Successfully created ${ticketSubtypes.length} ticket subtypes');
          print('Ticket subtypes: ${ticketSubtypes.map((t) => '${t.ticketSubtypeId}: ${t.ticketSubtypeName}').join(', ')}');
          return ticketSubtypes;
        } catch (e) {
          print('Error parsing ticket subtype data: $e');
          throw Exception('Failed to parse ticket subtype data: $e');
        }
      } else {
        throw Exception('Failed to load ticket subtypes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTicketSubtypesByType: $e');
      throw Exception('Failed to load ticket subtypes: $e');
    }
  }
}