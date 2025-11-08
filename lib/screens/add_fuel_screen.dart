import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';

class AddFuelScreen extends StatefulWidget {
  const AddFuelScreen({super.key});

  @override
  State<AddFuelScreen> createState() => _AddFuelScreenState();
}

class _AddFuelScreenState extends State<AddFuelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _odometerController = TextEditingController();
  final _quantityController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _totalCostController = TextEditingController();
  final _stationNameController = TextEditingController();
  final _notesController = TextEditingController();

  String _fuelType = 'gasoline';

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _quantityController.addListener(_calculateTotalCost);
    _pricePerLiterController.addListener(_calculateTotalCost);
  }

  void _calculateTotalCost() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final pricePerLiter = double.tryParse(_pricePerLiterController.text) ?? 0;
    final totalCost = quantity * pricePerLiter;
    _totalCostController.text = totalCost.toStringAsFixed(2);
  }

  Future<void> _saveFuelEntry() async {
    final dbHelper = DatabaseHelper();
    final fuelEntry = {
      'date': _dateController.text,
      'odometer': int.parse(_odometerController.text),
      'fuelType': _fuelType,
      'quantity': double.parse(_quantityController.text),
      'pricePerLiter': double.parse(_pricePerLiterController.text),
      'totalCost': double.parse(_totalCostController.text),
      'stationName': _stationNameController.text,
      'notes': _notesController.text,
    };
    await dbHelper.insertFuelEntry(fuelEntry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Fuel'),
      ),
      body: Padding(
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
                      _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
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
                value: _fuelType,
                decoration: const InputDecoration(labelText: 'Fuel Type'),
                items: ['gasoline', 'diesel', 'lpg'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _fuelType = newValue!;
                  });
                },
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity (liters)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pricePerLiterController,
                decoration: const InputDecoration(labelText: 'Price per liter'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price per liter';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _totalCostController,
                decoration: const InputDecoration(labelText: 'Total Cost'),
                readOnly: true,
              ),
              TextFormField(
                controller: _stationNameController,
                decoration: const InputDecoration(labelText: 'Station Name (optional)'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveFuelEntry();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fuel entry saved successfully')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
