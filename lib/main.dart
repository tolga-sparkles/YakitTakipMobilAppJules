import 'package:flutter/material.dart';
import 'package:fuel_tracker_app/screens/add_fuel_screen.dart';
import 'package:fuel_tracker_app/screens/add_maintenance_screen.dart';
import 'package:fuel_tracker_app/screens/my_statistics_screen.dart';
import 'package:fuel_tracker_app/screens/prices_screen.dart';
import 'package:fuel_tracker_app/screens/profile_screen.dart';

void main() {
  runApp(const FuelTrackerApp());
}

class FuelTrackerApp extends StatelessWidget {
  const FuelTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ).copyWith(
          secondary: Colors.orange,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MyStatisticsScreen(),
    PricesScreen(),
    AddFuelScreen(),
    AddMaintenanceScreen(),
    ProfileScreen(),
  ];

  static const List<String> _widgetTitles = <String>[
    'My Statistics',
    'Fuel Prices',
    'Add Fuel',
    'Add Maintenance',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'My Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.price_change),
            label: 'Prices',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Fuel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
