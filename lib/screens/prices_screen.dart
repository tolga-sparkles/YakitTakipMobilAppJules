import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/services/database_helper.dart';
import 'package:intl/intl.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  List<Map<String, dynamic>> _fuelPrices = [];

  @override
  void initState() {
    super.initState();
    _loadFuelPrices();
  }

  Future<void> _loadFuelPrices() async {
    final dbHelper = DatabaseHelper();
    final fuelPrices = await dbHelper.getFuelPrices();
    setState(() {
      _fuelPrices = fuelPrices;
    });
  }

  Future<void> _saveFuelPrice(String stationName, double? gasolinePrice,
      double? dieselPrice, double? lpgPrice) async {
    final dbHelper = DatabaseHelper();
    final fuelPrice = {
      'stationName': stationName,
      'gasolinePrice': gasolinePrice,
      'dieselPrice': dieselPrice,
      'lpgPrice': lpgPrice,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
    await dbHelper.insertFuelPrice(fuelPrice);
    _loadFuelPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _fuelPrices.length,
        itemBuilder: (context, index) {
          final price = _fuelPrices[index];
          return ListTile(
            title: Text(price['stationName']),
            subtitle: Text(
                'Gasoline: \$${price['gasolinePrice']}, Diesel: \$${price['dieselPrice']}'),
            trailing: Text(
                'Last updated: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(price['lastUpdated']))}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPriceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddPriceDialog() {
    final _stationNameController = TextEditingController();
    final _gasolinePriceController = TextEditingController();
    final _dieselPriceController = TextEditingController();
    final _lpgPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Fuel Price'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _stationNameController,
                decoration: const InputDecoration(labelText: 'Station Name'),
              ),
              TextField(
                controller: _gasolinePriceController,
                decoration: const InputDecoration(labelText: 'Gasoline Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _dieselPriceController,
                decoration: const InputDecoration(labelText: 'Diesel Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _lpgPriceController,
                decoration: const InputDecoration(labelText: 'LPG Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _saveFuelPrice(
                  _stationNameController.text,
                  double.tryParse(_gasolinePriceController.text),
                  double.tryParse(_dieselPriceController.text),
                  double.tryParse(_lpgPriceController.text),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
