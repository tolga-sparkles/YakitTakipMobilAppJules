import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _licensePlateController = TextEditingController();

  String _theme = 'system';
  String _units = 'km/L';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DatabaseHelper();
    final vehicle = await dbHelper.getVehicle();
    if (vehicle != null) {
      _brandController.text = vehicle['brand'];
      _modelController.text = vehicle['model'];
      _yearController.text = vehicle['year'].toString();
      _licensePlateController.text = vehicle['licensePlate'];
    }
    final settings = await dbHelper.getAppSettings();
    if (settings != null) {
      setState(() {
        _theme = settings['theme'];
        _units = settings['units'];
      });
    }
  }

  Future<void> _saveData() async {
    final dbHelper = DatabaseHelper();
    final vehicle = {
      'brand': _brandController.text,
      'model': _modelController.text,
      'year': int.parse(_yearController.text),
      'licensePlate': _licensePlateController.text,
    };
    await dbHelper.insertVehicle(vehicle);
    final settings = {
      'theme': _theme,
      'units': _units,
    };
    await dbHelper.updateAppSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('Vehicle Details', style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle brand';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(labelText: 'Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle model';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the vehicle year';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(labelText: 'License Plate'),
              ),
              const SizedBox(height: 20),
              Text('App Settings', style: Theme.of(context).textTheme.titleLarge),
              DropdownButtonFormField<String>(
                value: _theme,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: ['system', 'light', 'dark'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _theme = newValue!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _units,
                decoration: const InputDecoration(labelText: 'Units'),
                items: ['km/L', 'L/100km', 'mpg'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _units = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile saved successfully')),
                    );
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
