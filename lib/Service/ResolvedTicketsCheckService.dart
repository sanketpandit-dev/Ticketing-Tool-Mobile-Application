import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/TicketModel.dart';

class TicketService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com/api/ticket';

  Future<List<Ticket>> getTickets({required String userId, String type = 'Resolved'}) async {
    final url = Uri.parse('$baseUrl/getDashboardList?type=$type&user_id=$userId');
    print('API Request URL: $url');
    final response = await http.get(url);
    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        print('Ticket list JSON: $data');
        return data.map((json) => Ticket.fromJson(json)).toList();
      } else if (data['data'] is List) {
        print('Ticket list JSON: ${data['data']}');

        return (data['data'] as List).map((json) => Ticket.fromJson(json)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load tickets');
    }
  }
}