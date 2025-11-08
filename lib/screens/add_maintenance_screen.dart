import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class AddMaintenanceScreen extends StatefulWidget {
  const AddMaintenanceScreen({super.key});

  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _costController = TextEditingController();
  final _serviceLocationController = TextEditingController();
  final _notesController = TextEditingController();

  String _maintenanceType = 'oil_change';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _odometerController.clear();
    _costController.clear();
    _serviceLocationController.clear();
    _notesController.clear();
    setState(() {
      _maintenanceType = 'oil_change';
    });
  }

  Future<void> _saveMaintenanceLog() async {
    final dbHelper = DatabaseHelper();
    final maintenanceLog = {
      'date': _dateController.text,
      'odometer': int.parse(_odometerController.text),
      'maintenanceType': _maintenanceType,
      'cost': double.parse(_costController.text),
      'serviceLocation': _serviceLocationController.text,
      'notes': _notesController.text,
    };
    await dbHelper.insertMaintenanceLog(maintenanceLog);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Date'),
              readOnly: true,
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text =
                        DateFormat('yyyy-MM-dd').format(pickedDate);
                  });
                }
              },
            ),
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(labelText: 'Odometer (km)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the odometer reading';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _maintenanceType,
              decoration: const InputDecoration(labelText: 'Maintenance Type'),
              items: [
                'oil_change',
                'tire_replacement',
                'brake_check',
                'battery_replacement',
                'general_service'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _maintenanceType = newValue!;
                });
              },
            ),
            TextFormField(
              controller: _costController,
              decoration: const InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the cost';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _serviceLocationController,
              decoration: const InputDecoration(
                  labelText: 'Service Location (optional)'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _saveMaintenanceLog();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Maintenance log saved successfully')),
                  );
                  _clearForm();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
