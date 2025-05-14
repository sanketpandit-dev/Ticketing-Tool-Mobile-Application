import 'package:flutter/material.dart';
import 'package:tickteting_tool/Model/PriorityModel.dart';
import 'package:tickteting_tool/Service/PriorityService.dart';

class PriorityController extends ChangeNotifier {
  final PriorityService _priorityService = PriorityService();
  List<Priority> _priorities = [];
  Priority? _selectedPriority;
  bool _isLoading = false;
  String _error = '';

  List<Priority> get priorities => _priorities;
  Priority? get selectedPriority => _selectedPriority;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadPriorities() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Loading priorities');
      final priorities = await _priorityService.getPriorities();
      print('Received priorities: ${priorities.length}');
      print('Priorities data: ${priorities.map((p) => '${p.priorityId}: ${p.priorityName}').join(', ')}');
      
      _priorities = priorities;
      _selectedPriority = null;
    } catch (e) {
      print('Error loading priorities: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPriority(Priority priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPriority = null;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 