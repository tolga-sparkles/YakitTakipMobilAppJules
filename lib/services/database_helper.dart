import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fuel_tracker.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createFuelPricesTable(db);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE FuelEntries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        odometer INTEGER NOT NULL,
        fuelType TEXT NOT NULL,
        quantity REAL NOT NULL,
        pricePerLiter REAL NOT NULL,
        totalCost REAL NOT NULL,
        stationName TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE MaintenanceLogs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        odometer INTEGER NOT NULL,
        maintenanceType TEXT NOT NULL,
        cost REAL NOT NULL,
        serviceLocation TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE Vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        licensePlate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE AppSettings(
        id INTEGER PRIMARY KEY,
        theme TEXT NOT NULL,
        units TEXT NOT NULL
      )
    ''');
    await _createFuelPricesTable(db);
  }

  Future<void> insertVehicle(Map<String, dynamic> vehicle) async {
    final db = await database;
    await db.insert('Vehicles', vehicle, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getVehicle() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Vehicles');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> updateAppSettings(Map<String, dynamic> appSettings) async {
    final db = await database;
    appSettings['id'] = 1;
    await db.insert('AppSettings', appSettings, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getAppSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('AppSettings');
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<void> insertFuelEntry(Map<String, dynamic> fuelEntry) async {
    final db = await database;
    await db.insert('FuelEntries', fuelEntry, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertMaintenanceLog(Map<String, dynamic> maintenanceLog) async {
    final db = await database;
    await db.insert('MaintenanceLogs', maintenanceLog, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFuelEntries() async {
    final db = await database;
    return await db.query('FuelEntries', orderBy: 'date DESC');
  }

  Future<void> _createFuelPricesTable(Database db) async {
    await db.execute('''
      CREATE TABLE FuelPrices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stationName TEXT NOT NULL,
        gasolinePrice REAL,
        dieselPrice REAL,
        lpgPrice REAL,
        lastUpdated TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertFuelPrice(Map<String, dynamic> fuelPrice) async {
    final db = await database;
    await db.insert('FuelPrices', fuelPrice, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getFuelPrices() async {
    final db = await database;
    return await db.query('FuelPrices', orderBy: 'lastUpdated DESC');
  }
}
