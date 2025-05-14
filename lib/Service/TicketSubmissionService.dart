import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/TicketRequestModel.dart';
import 'package:tickteting_tool/Model/TicketResponseModel.dart';

class TicketSubmissionService {
  final String baseUrl = 'http://taskmgmtapi.alphonsol.com';
  final storage = FlutterSecureStorage();


  Future<TicketResponseModel> raiseTicket({
    required String ticketName,
    required String ticketDescription,
    required int departmentId,
    required int ticketTypeId,
    required int ticketSubTypeId,
    required int priorityId,
    required String fileName,
    required String base64FileContent,
  }) async {
    try {
      final userId = await storage.read(key: 'userId');
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final url = Uri.parse('$baseUrl/api/ticketraise');

      final Map<String, dynamic> payload = {
        'TicketName': ticketName,
        'TicketDescription': ticketDescription,
        'DepartmentId': departmentId,
        'TicketTypeId': ticketTypeId,
        'TicketSubTypeId': ticketSubTypeId,
        'Priority': priorityId,
        'IsManual': 1,
        'InsertedBy': int.parse(userId),
        'TicketStatus': 1,
        'FileName': fileName,
        'Base64FileContent': base64FileContent
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return TicketResponseModel.fromJson(responseData);
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting ticket: $e');
    }
  }

  // ✅ New method using TicketRequestModel
  Future<TicketResponseModel> raiseTicketFromModel(TicketRequestModel model) async {
    try {
      final url = Uri.parse('$baseUrl/api/ticket/raise');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TicketResponseModel.fromJson(data);
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting ticket: $e');
    }
  }
}
