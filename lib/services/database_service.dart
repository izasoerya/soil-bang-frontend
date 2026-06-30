import 'package:bang_soil/models/sensor.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  Database? _db;

  DatabaseService._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'soil_bang.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sensor_readings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            created_at TEXT NOT NULL,
            nm410 REAL, nm435 REAL, nm460 REAL, nm485 REAL,
            nm510 REAL, nm535 REAL, nm560 REAL, nm585 REAL,
            nm610 REAL, nm645 REAL, nm680 REAL, nm705 REAL,
            nm730 REAL, nm760 REAL, nm810 REAL, nm860 REAL,
            nm900 REAL, nm940 REAL,
            as72651_temp REAL, as72652_temp REAL, as72653_temp REAL
          )
        ''');
      },
    );
  }

  Future<void> insertSensor(Sensor sensor) async {
    final db = await database;
    await db.insert('sensor_readings', {
      'created_at': sensor.createdAt.toIso8601String(),
      'nm410': sensor.nm410,
      'nm435': sensor.nm435,
      'nm460': sensor.nm460,
      'nm485': sensor.nm485,
      'nm510': sensor.nm510,
      'nm535': sensor.nm535,
      'nm560': sensor.nm560,
      'nm585': sensor.nm585,
      'nm610': sensor.nm610,
      'nm645': sensor.nm645,
      'nm680': sensor.nm680,
      'nm705': sensor.nm705,
      'nm730': sensor.nm730,
      'nm760': sensor.nm760,
      'nm810': sensor.nm810,
      'nm860': sensor.nm860,
      'nm900': sensor.nm900,
      'nm940': sensor.nm940,
      'as72651_temp': sensor.as72651Temp,
      'as72652_temp': sensor.as72652Temp,
      'as72653_temp': sensor.as72653Temp,
    });
  }

  Future<List<Map<String, dynamic>>> getAllReadings() async {
    final db = await database;
    return db.query('sensor_readings', orderBy: 'created_at ASC');
  }

  Future<void> deleteAllReadings() async {
    final db = await database;
    await db.delete('sensor_readings');
  }

  Future<int> getReadingCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM sensor_readings');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
