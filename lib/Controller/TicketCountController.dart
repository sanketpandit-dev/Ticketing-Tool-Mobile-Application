import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tickteting_tool/Service/TicketCountService.dart';

class TicketCountController extends ChangeNotifier {
  final TicketCountService _service = TicketCountService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  int totalCount = 0;
  int pendingCount = 0;
  int completeCount = 0;
  int discardCount = 0;
  int confirmedCount = 0;
  bool isLoading = false;
  String error = '';

  Future<void> loadCounts() async {
    isLoading = true;
    error = '';
    notifyListeners();
    try {
      String? userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found in secure storage');
      }
      totalCount = await _service.getTicketCount(insertedBy: userId);
      pendingCount = await _service.getTicketCount(insertedBy: userId, status: '1');
      completeCount = await _service.getTicketCount(insertedBy: userId, status: '1004');
      discardCount = await _service.getTicketCount(insertedBy: userId, status: '8');
      //confirmedCount = await _service.getTicketCount(insertedBy: userId, status: '1004');
    } catch (e) {
      error = e.toString();
      totalCount = pendingCount = completeCount = discardCount = 0;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
} 