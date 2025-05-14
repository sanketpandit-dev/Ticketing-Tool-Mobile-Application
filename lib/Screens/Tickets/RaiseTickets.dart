import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tickteting_tool/Controller/DepartmentController.dart';
import 'package:tickteting_tool/Controller/TicketTypeController.dart';
import 'package:tickteting_tool/Controller/TicketSubtypeController.dart';
import 'package:tickteting_tool/Controller/PriorityController.dart';
import 'package:tickteting_tool/Controller/TicketSubmissionController.dart';
import 'package:tickteting_tool/Model/DepartmentModel.dart';
import 'package:tickteting_tool/Model/TicketTypeModel.dart';
import 'package:tickteting_tool/Model/TicketSubtypeModel.dart';
import 'package:tickteting_tool/Model/PriorityModel.dart';
import 'package:file_picker/file_picker.dart';

class RaiseTickets extends StatefulWidget {
  const RaiseTickets({super.key});

  @override
  State<RaiseTickets> createState() => _RaiseTicketsState();
}

class _RaiseTicketsState extends State<RaiseTickets> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<PlatformFile> _selectedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadPriorities();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DepartmentController>().loadDepartments();
    });
  }

  Future<void> _loadPriorities() async {
    final priorityController = Provider.of<PriorityController>(context, listen: false);
    await priorityController.loadPriorities();
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'csv', 'jpg'],
    );
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.files.where((file) => !_selectedFiles.any((f) => f.name == file.name)));
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }
  void _clearForm() {
    // Clear text controllers
    _subjectController.clear();
    _descriptionController.clear();

    // Clear selected files
    setState(() {
      _selectedFiles.clear();
    });

    // Clear selections in controllers
    Provider.of<DepartmentController>(context, listen: false).clearSelection();
    Provider.of<TicketTypeController>(context, listen: false).clearSelection();
    Provider.of<TicketSubtypeController>(context, listen: false).clearSelection();
    Provider.of<PriorityController>(context, listen: false).clearSelection();

    // Reload initial data
    Provider.of<DepartmentController>(context, listen: false).loadDepartments();
    Provider.of<PriorityController>(context, listen: false).loadPriorities();

    // Reset the form validation
    _formKey.currentState?.reset();

    // Clear any error messages
    setState(() {
      _error = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    final departmentController = Provider.of<DepartmentController>(context);
    final ticketTypeController = Provider.of<TicketTypeController>(context);
    final ticketSubtypeController = Provider.of<TicketSubtypeController>(context);
    final priorityController = Provider.of<PriorityController>(context);
    final ticketController = Provider.of<TicketSubmissionController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF3B82F6),
        title: const Text('Raise Ticket',style: TextStyle(color: Colors.white),),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Department Dropdown
              Consumer<DepartmentController>(
                builder: (context, departmentController, child) {
                  if (departmentController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (departmentController.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        departmentController.error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return DropdownButtonFormField<Department>(
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    value: departmentController.selectedDepartment,
                    items: departmentController.departments.map((department) {
                      return DropdownMenuItem<Department>(
                        value: department,
                        child: Text(department.departmentName),
                      );
                    }).toList(),
                    onChanged: (Department? newValue) {
                      if (newValue != null) {
                        departmentController.selectDepartment(newValue);
                        ticketTypeController.loadTicketTypesByDepartment(newValue.departmentId);
                        ticketSubtypeController.clearSelection();
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a department';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Ticket Type Dropdown
              Consumer<TicketTypeController>(
                builder: (context, ticketTypeController, child) {
                  if (ticketTypeController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (ticketTypeController.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        ticketTypeController.error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return DropdownButtonFormField<TicketType>(
                    decoration: const InputDecoration(
                      labelText: 'Ticket Type',
                      border: OutlineInputBorder(),
                    ),
                    value: ticketTypeController.selectedTicketType,
                    items: ticketTypeController.ticketTypes.map((ticketType) {
                      return DropdownMenuItem<TicketType>(
                        value: ticketType,
                        child: Text(ticketType.ticketTypeName),
                      );
                    }).toList(),
                    onChanged: (TicketType? newValue) {
                      if (newValue != null) {
                        ticketTypeController.selectTicketType(newValue);
                        ticketSubtypeController.loadTicketSubtypes(newValue.ticketTypeId);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a ticket type';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Ticket Subtype Dropdown
              Consumer<TicketSubtypeController>(
                builder: (context, ticketSubtypeController, child) {
                  if (ticketSubtypeController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (ticketSubtypeController.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        ticketSubtypeController.error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return DropdownButtonFormField<TicketSubtype>(
                    decoration: const InputDecoration(
                      labelText: 'Ticket Subtype',
                      border: OutlineInputBorder(),
                    ),
                    value: ticketSubtypeController.selectedTicketSubtype,
                    items: ticketSubtypeController.ticketSubtypes.map((ticketSubtype) {
                      return DropdownMenuItem<TicketSubtype>(
                        value: ticketSubtype,
                        child: Text(ticketSubtype.ticketSubtypeName),
                      );
                    }).toList(),
                    onChanged: (TicketSubtype? newValue) {
                      if (newValue != null) {
                        ticketSubtypeController.selectTicketSubtype(newValue);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a ticket subtype';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Priority Dropdown
              Consumer<PriorityController>(
                builder: (context, priorityController, child) {
                  if (priorityController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (priorityController.error.isNotEmpty) {
                    return Center(
                      child: Text(
                        priorityController.error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return DropdownButtonFormField<Priority>(
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    value: priorityController.selectedPriority,
                    items: priorityController.priorities.map((priority) {
                      return DropdownMenuItem<Priority>(
                        value: priority,
                        child: Text(priority.priorityName),
                      );
                    }).toList(),
                    onChanged: (Priority? newValue) {
                      if (newValue != null) {
                        priorityController.selectPriority(newValue);
                      }
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a priority';
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),

              // Subject TextField
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Upload Attachments
              Text('Upload Attachments:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedFiles.isEmpty
                          ? 'No file chosen'
                          : '${_selectedFiles.length} file(s) selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickFiles,
                    child: Text('Choose Files',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
              Text(
                'PDF, DOCX, CSV, JPG allowed. Max size 5MB.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8.0),

              // Uploaded Documents
              Text('Uploaded Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedFiles.isEmpty
                    ? Text('No Files Uploaded')
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _selectedFiles.asMap().entries.map((entry) {
                    int idx = entry.key;
                    PlatformFile file = entry.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(file.name)),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () => _removeFile(idx),
                          tooltip: 'Remove',
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.0),

              // Description TextField
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: ticketController.isLoading ? null : _submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B82F6),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: ticketController.isLoading
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm, // Use the new _clearForm method
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Color(0xFF3B82F6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (ticketController.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    ticketController.error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      // if (_selectedFiles.isEmpty) {
      //   setState(() {
      //     _error = 'Please select at least one file attachment';
      //   });
      //   return;
      // }

      final departmentController = Provider.of<DepartmentController>(context, listen: false);
      final ticketTypeController = Provider.of<TicketTypeController>(context, listen: false);
      final ticketSubtypeController = Provider.of<TicketSubtypeController>(context, listen: false);
      final priorityController = Provider.of<PriorityController>(context, listen: false);
      final ticketController = Provider.of<TicketSubmissionController>(context, listen: false);

      // Validate all required selections
      if (departmentController.selectedDepartment == null) {
        setState(() {
          _error = 'Please select a department';
        });
        return;
      }

      if (ticketTypeController.selectedTicketType == null) {
        setState(() {
          _error = 'Please select a ticket type';
        });
        return;
      }

      if (ticketSubtypeController.selectedTicketSubtype == null) {
        setState(() {
          _error = 'Please select a ticket subtype';
        });
        return;
      }

      if (priorityController.selectedPriority == null) {
        setState(() {
          _error = 'Please select a priority';
        });
        return;
      }

      // Submit ticket
      final success = await ticketController.submitTicket(
        subject: _subjectController.text,
        description: _descriptionController.text,
        departmentId: departmentController.selectedDepartment!.departmentId,
        ticketTypeId: ticketTypeController.selectedTicketType!.ticketTypeId,
        ticketSubTypeId: ticketSubtypeController.selectedTicketSubtype!.ticketSubtypeId,
        priorityId: priorityController.selectedPriority!.priorityId,
        files: _selectedFiles,
      );

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Ticket submitted successfully. ${ticketController.ticketResponse?.ticketNo}'),
            duration: Duration(seconds: 5),
          ),
        );

        // Clear form
        _subjectController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedFiles.clear();
        });
        departmentController.clearSelection();
        ticketTypeController.clearSelection();
        ticketSubtypeController.clearSelection();
        priorityController.clearSelection();
      } else {
        // Show error message - handled by the controller
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Failed to submit ticket: ${ticketController.error}'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}