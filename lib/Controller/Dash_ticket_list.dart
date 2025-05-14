import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tickteting_tool/Model/Dash_ticket_model.dart';

class TicketListController extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<DashTicketModel> _tickets = [];
  bool _isLoading = false;
  String _error = '';
  String _statusFilter = '';

  List<DashTicketModel> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get statusFilter => _statusFilter;

  Future<void> loadTicketsByStatus(String status) async {
    _statusFilter = status;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null || userId.isEmpty) {
        _error = 'User ID not found. Please login again.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Map Flutter status to API type
      String type;
      switch (status) {
        case 'Total Tickets':
          type = 'Total';
          break;
        case 'Pending':
          type = 'Pending';
          break;
        case 'Confirmed':
          type = 'Confirmed';
          break;
        case 'Discard':
          type = 'Discard';
          break;
        default:
          type = 'Total';
      }

      final uri = Uri.parse(
        'http://taskmgmtapi.alphonsol.com/api/ticket/getDashboardList?type=$type&user_id=$userId',
      );

      print('🔍 API Request: $uri');

      final response = await http.get(uri);

      print('📥 Response Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          _tickets = jsonResponse
              .map<DashTicketModel>((ticket) =>
              DashTicketModel.fromJson(ticket as Map<String, dynamic>))
              .toList();
        } else if (jsonResponse is Map && jsonResponse.containsKey('Data')) {
          final data = jsonResponse['Data'];
          if (data is List) {
            _tickets = data
                .map<DashTicketModel>((ticket) =>
                DashTicketModel.fromJson(ticket as Map<String, dynamic>))
                .toList();
          } else if (data is Map) {
            _tickets = [
              DashTicketModel.fromJson(data as Map<String, dynamic>)
            ];
          } else {
            _tickets = [];
          }
        } else if (jsonResponse is Map) {
          _tickets = [
            DashTicketModel.fromJson(jsonResponse as Map<String, dynamic>)
          ];
        } else {
          _tickets = [];
        }
      } else {
        _error = 'Failed to load tickets. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error loading tickets: $e';
      print('❌ Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
