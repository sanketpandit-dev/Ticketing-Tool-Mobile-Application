import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tickteting_tool/Model/update_ticket_model.dart';

class UpdateTicketController {
  final String apiUrl = 'http://taskmgmtapi.alphonsol.com/api/updateticketstatus';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Get user ID from secure storage
  Future<int> _getUserId() async {
    final userId = await _secureStorage.read(key: 'userId');
    print("🔍 Secure Storage Read: userId = $userId");

    if (userId == null || userId.isEmpty) {
      throw Exception("❌ User ID not found in secure storage");
    }

    return int.parse(userId);
  }

  // Convert a file to base64
  Future<String> _fileToBase64(File file) async {
    List<int> fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes);
  }

  // Update ticket status with optional remark and file attachment
  Future<Map<String, dynamic>> updateTicketStatus({
    required String ticketNo,
    required String remark,
    List<File>? files,
    int statusId = 1003,
  }) async {
    try {
      final userId = await _getUserId();
      print("✅ Retrieved userId: $userId");

      File? fileToUpload;
      String? fileName;
      String? base64FileContent;

      if (files != null && files.isNotEmpty) {
        fileToUpload = files.first;
        fileName = fileToUpload.path.split('/').last;
        base64FileContent = await _fileToBase64(fileToUpload);
      }

      final model = UpdateTicketModel(
        ticketNo: ticketNo,
        userId: userId,
        statusId: statusId,
        queryReply: remark,
        fileName: fileName,
        base64FileContent: base64FileContent,
      );

      final body = jsonEncode(model.toJson());

      print("📤 API Request Body: $body");

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📥 API Response Status: ${response.statusCode}");
      print("📥 API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Failed to update ticket: ${response.statusCode}',
          'details': response.body,
        };
      }
    } catch (e) {
      print("❌ Error: $e");
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Upload multiple files sequentially
  Future<List<Map<String, dynamic>>> uploadMultipleFiles({
    required String ticketNo,
    required String remark,
    required List<File> files,
    int statusId = 1003,
  }) async {
    List<Map<String, dynamic>> results = [];

    if (files.isNotEmpty) {
      final firstResult = await updateTicketStatus(
        ticketNo: ticketNo,
        remark: remark,
        files: [files.first],
        statusId: statusId,
      );
      results.add(firstResult);

      for (int i = 1; i < files.length; i++) {
        final nextResult = await updateTicketStatus(
          ticketNo: ticketNo,
          remark: '', // No remark for remaining files
          files: [files[i]],
          statusId: statusId,
        );
        results.add(nextResult);
      }
    } else {
      final result = await updateTicketStatus(
        ticketNo: ticketNo,
        remark: remark,
        statusId: statusId,
      );
      results.add(result);
    }

    return results;
  }
}
