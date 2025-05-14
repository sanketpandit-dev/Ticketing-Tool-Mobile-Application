import 'package:flutter/material.dart';
import 'package:tickteting_tool/Model/TicketSubtypeModel.dart';
import 'package:tickteting_tool/Service/TicketSubtypeService.dart';

class TicketSubtypeController extends ChangeNotifier {
  final TicketSubtypeService _ticketSubtypeService = TicketSubtypeService();
  List<TicketSubtype> _ticketSubtypes = [];
  TicketSubtype? _selectedTicketSubtype;
  bool _isLoading = false;
  String _error = '';

  List<TicketSubtype> get ticketSubtypes => _ticketSubtypes;
  TicketSubtype? get selectedTicketSubtype => _selectedTicketSubtype;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadTicketSubtypes(int ticketTypeId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Loading ticket subtypes for ticket type: $ticketTypeId');
      final subtypes = await _ticketSubtypeService.getTicketSubtypesByType(ticketTypeId);
      print('Received subtypes: ${subtypes.length}');
      print('Subtypes data: ${subtypes.map((s) => '${s.ticketSubtypeId}: ${s.ticketSubtypeName}').join(', ')}');
      
      _ticketSubtypes = subtypes;
      _selectedTicketSubtype = null;
    } catch (e) {
      print('Error loading ticket subtypes: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTicketSubtype(TicketSubtype subtype) {
    _selectedTicketSubtype = subtype;
    notifyListeners();
  }

  void clearSelection() {
   _selectedTicketSubtype = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 