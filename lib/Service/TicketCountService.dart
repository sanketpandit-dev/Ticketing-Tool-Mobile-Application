import 'dart:convert';
import 'package:http/http.dart' as http;

class TicketCountService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com/api/Ticket';

  Future<int> getTicketCount({required String insertedBy, String? status}) async {
    String url = '$baseUrl/GetTicketCount?insertedBy=$insertedBy';
    if (status != null && status.isNotEmpty) {
      url += '&status=$status';
    }
    print('TicketCountService API Request: $url');
    final response = await http.get(Uri.parse(url));
    print('TicketCountService API Response: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Handle list response
      if (data is List && data.isNotEmpty && data[0]['ticketCount'] != null) {
        return data[0]['ticketCount'] as int;
      }
      // Handle empty list
      if (data is List && data.isEmpty) {
        return 0;
      }
      // Fallbacks
      if (data is Map && data.containsKey('count')) {
        return data['count'] as int;
      } else if (data is int) {
        return data;
      } else if (data is String) {
        return int.tryParse(data) ?? 0;
      }
      return 0;
    } else {
      throw Exception('Failed to load ticket count');
    }
  }
} 