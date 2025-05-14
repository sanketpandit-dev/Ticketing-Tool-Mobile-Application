import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/TicketTypeModel.dart';

class TicketTypeService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com/api';

  Future<List<TicketType>> getTicketTypesByDepartment(int departmentId) async {
    try {
      print('Making API request to: $baseUrl/ticket/getTicketTypesByDepartment?dept_mast_id=$departmentId');
      final response = await http.get(
        Uri.parse('$baseUrl/ticket/getTicketTypesByDepartment?dept_mast_id=$departmentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final List<dynamic> jsonData = json.decode(response.body);
          print('Parsed JSON data: $jsonData');
          
          if (jsonData.isEmpty) {
            print('Warning: No ticket types found for department $departmentId');
            return [];
          }

          final ticketTypes = <TicketType>[];
          for (var json in jsonData) {
            try {
              final ticketType = TicketType.fromJson(json);
              if (ticketType.ticketTypeId != 0 && ticketType.ticketTypeName.isNotEmpty) {
                ticketTypes.add(ticketType);
              } else {
                print('Skipping invalid ticket type: $json');
              }
            } catch (e) {
              print('Error parsing individual ticket type: $e\nJSON: $json');
            }
          }
          
          print('Successfully created ${ticketTypes.length} ticket types');
          print('Ticket types: ${ticketTypes.map((t) => '${t.ticketTypeId}: ${t.ticketTypeName}').join(', ')}');
          return ticketTypes;
        } catch (e) {
          print('Error parsing ticket type data: $e');
          throw Exception('Failed to parse ticket type data: $e');
        }
      } else {
        throw Exception('Failed to load ticket types: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getTicketTypesByDepartment: $e');
      throw Exception('Failed to load ticket types: $e');
    }
  }
} 