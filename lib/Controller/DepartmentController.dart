import 'package:flutter/material.dart';
import 'package:tickteting_tool/Model/DepartmentModel.dart';
import 'package:tickteting_tool/Service/DepartmentService.dart';

class DepartmentController extends ChangeNotifier {
  final DepartmentService _departmentService = DepartmentService();
  List<Department> _departments = [];
  Department? _selectedDepartment;
  bool _isLoading = false;
  String _error = '';

  List<Department> get departments => _departments;
  Department? get selectedDepartment => _selectedDepartment;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadDepartments() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print('Loading departments');
      final departments = await _departmentService.getDepartments();
      print('Received departments: ${departments.length}');
      print('Departments data: ${departments.map((d) => '${d.departmentId}: ${d.departmentName}').join(', ')}');
      
      _departments = departments;
      _selectedDepartment = null;
    } catch (e) {
      print('Error loading departments: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDepartment(Department department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void clearSelection() {
    _departments = [];
    _selectedDepartment = null;
    _error = '';
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
} 