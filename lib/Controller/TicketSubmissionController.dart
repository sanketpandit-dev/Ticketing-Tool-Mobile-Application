import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tickteting_tool/Model/TicketResponseModel.dart';
import 'package:tickteting_tool/Service/TicketSubmissionService.dart';

class TicketSubmissionController extends ChangeNotifier {
  final TicketSubmissionService _ticketService = TicketSubmissionService();
  final storage = FlutterSecureStorage();

  bool _isLoading = false;
  String _error = '';
  TicketResponseModel? _ticketResponse;

  bool get isLoading => _isLoading;
  String get error => _error;
  TicketResponseModel? get ticketResponse => _ticketResponse;

  Future<bool> submitTicket({
    required String subject,
    required String description,
    required int departmentId,
    required int ticketTypeId,
    required int ticketSubTypeId,
    required int priorityId,
    required List<PlatformFile> files,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final userId = await storage.read(key: 'userId');
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      String fileName = '';
      String base64FileContent = '';

      if (files.isNotEmpty) {
        final file = files.first;
        fileName = file.name;

        if (file.bytes != null) {
          base64FileContent = base64Encode(file.bytes!);
        } else if (file.path != null) {
          final bytes = await File(file.path!).readAsBytes();
          base64FileContent = base64Encode(bytes);
        }
      }

      // Debug: print request payload
      print('Submitting ticket with:');
      print('Subject: $subject');
      print('Description: $description');
      print('DepartmentId: $departmentId');
      print('TicketTypeId: $ticketTypeId');
      print('TicketSubTypeId: $ticketSubTypeId');
      print('PriorityId: $priorityId');
      print('FileName: ${fileName}');
      print('Base64 Length: ${base64FileContent.length}');

      _ticketResponse = await _ticketService.raiseTicket(
        ticketName: subject,
        ticketDescription: description,
        departmentId: departmentId,
        ticketTypeId: ticketTypeId,
        ticketSubTypeId: ticketSubTypeId,
        priorityId: priorityId,
        fileName: fileName,
        base64FileContent: base64FileContent,
      );

      print("Response: ${_ticketResponse?.message}");

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print("Error: $e");
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
