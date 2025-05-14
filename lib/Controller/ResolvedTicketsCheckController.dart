import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tickteting_tool/Model/TicketModel.dart';
import 'package:tickteting_tool/Service/ResolvedTicketsCheckService.dart';

class Resolvedticketscheckcontroller extends ChangeNotifier {
  final TicketService _ticketService = TicketService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String _error = '';

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadTickets() async {
    _isLoading = true;
    _error = '';
    notifyListeners();
    try {
      String? userId = await _secureStorage.read(key: 'userId');
      print('Read userId from secure storage: $userId');
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found in secure storage');
      }
      print('Requesting tickets for userId: $userId');
      _tickets = await _ticketService.getTickets(userId: userId, type: 'Resolved');
    } catch (e) {
      _error = e.toString();
      _tickets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}