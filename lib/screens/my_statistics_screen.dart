import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class MyStatisticsScreen extends StatefulWidget {
  const MyStatisticsScreen({super.key});

  @override
  State<MyStatisticsScreen> createState() => _MyStatisticsScreenState();
}

class _MyStatisticsScreenState extends State<MyStatisticsScreen> {
  double _avgConsumption = 0.0;
  double _monthlySpending = 0.0;
  double _avgPrice = 0.0;
  int _distanceLast30Days = 0;

  @override
  void initState() {
    super.initState();
    _calculateStatistics();
  }

  Future<void> _calculateStatistics() async {
    final dbHelper = DatabaseHelper();
    final fuelEntries = await dbHelper.getFuelEntries();

    if (fuelEntries.length < 2) {
      return;
    }

    // Average Fuel Consumption
    double totalConsumption = 0;
    int consumptionCount = 0;
    for (int i = 0; i < fuelEntries.length - 1; i++) {
      final currentEntry = fuelEntries[i];
      final previousEntry = fuelEntries[i + 1];
      final distance = currentEntry['odometer'] - previousEntry['odometer'];
      if (distance > 0) {
        final consumption = (currentEntry['quantity'] / distance) * 100;
        totalConsumption += consumption;
        consumptionCount++;
      }
    }
    _avgConsumption = consumptionCount > 0 ? totalConsumption / consumptionCount : 0;

    // Total Monthly Spending
    final now = DateTime.now();
    _monthlySpending = fuelEntries
        .where((entry) => DateTime.parse(entry['date']).month == now.month && DateTime.parse(entry['date']).year == now.year)
        .fold(0.0, (sum, entry) => sum + entry['totalCost']);

    // Average Price Per Liter
    _avgPrice = fuelEntries.fold(0.0, (sum, entry) => sum + entry['pricePerLiter']) / fuelEntries.length;

    // Distance Driven in Last 30 Days
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentEntries = fuelEntries.where((entry) => DateTime.parse(entry['date']).isAfter(thirtyDaysAgo)).toList();
    if (recentEntries.length > 1) {
      final maxOdometer = recentEntries.map((e) => e['odometer']).reduce((a, b) => a > b ? a : b);
      final minOdometer = recentEntries.map((e) => e['odometer']).reduce((a, b) => a < b ? a : b);
      _distanceLast30Days = maxOdometer - minOdometer;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Statistics'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              title: Text('Average Fuel Consumption'),
              subtitle: Text('${_avgConsumption.toStringAsFixed(2)} L/100km'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Total Monthly Spending'),
              subtitle: Text('\$${_monthlySpending.toStringAsFixed(2)}'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Average Price Per Liter'),
              subtitle: Text('\$${_avgPrice.toStringAsFixed(2)}'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Distance Driven in Last 30 Days'),
              subtitle: Text('$_distanceLast30Days km'),
            ),
          ),
        ],
      ),
    );
  }
}
