import 'package:flutter/material.dart';
import 'package:tickteting_tool/Model/TicketTypeModel.dart';
import 'package:tickteting_tool/Service/TicketTypeService.dart';

class TicketTypeController extends ChangeNotifier {
  final TicketTypeService _ticketTypeService = TicketTypeService();
  List<TicketType> _ticketTypes = [];
  TicketType? _selectedTicketType;
  bool _isLoading = false;
  String _error = '';

  List<TicketType> get ticketTypes => _ticketTypes;
  TicketType? get selectedTicketType => _selectedTicketType;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadTicketTypesByDepartment(int departmentId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Loading ticket types for department ID: $departmentId');
      final types = await _ticketTypeService.getTicketTypesByDepartment(departmentId);
      print('Received ticket types: ${types.length}');
      print('Ticket types data: ${types.map((t) => '${t.ticketTypeId}: ${t.ticketTypeName}').join(', ')}');
      
      _ticketTypes = types;
      _selectedTicketType = null;
    } catch (e) {
      print('Error loading ticket types: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTicketType(TicketType type) {
    _selectedTicketType = type;
    notifyListeners();
  }

  void clearSelection() {
    _ticketTypes = [];
    _selectedTicketType = null;
    _error = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 