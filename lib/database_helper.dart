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
    String path = join(await getDatabasesPath(), 'railway_app.db');
    return await openDatabase(
      path,
      version: 4, // Incremented version to add 'via' column to bookings
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Recent Searches Table
    await db.execute('''
    CREATE TABLE recent_searches(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      from_name TEXT,
      from_code TEXT,
      to_name TEXT,
      to_code TEXT,
      timestamp TEXT
    )
    ''');

    // Bookings Table
    await db.execute('''
    CREATE TABLE bookings(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      source_name TEXT,
      dest_name TEXT,
      adult_count INTEGER,
      child_count INTEGER,
      booking_time TEXT,
      fare REAL,
      distance REAL,
      status TEXT,
      train_type TEXT,
      class_type TEXT,
      ticket_type TEXT,
      ir_number TEXT,
      terminal_id TEXT,
      gsin_no TEXT,
      journey_id TEXT,
      via TEXT
    )
    ''');

    // NEW: User Profile Table
    await db.execute('''
    CREATE TABLE user_profile(
      id INTEGER PRIMARY KEY CHECK (id = 1),
      name TEXT,
      phone TEXT
    )
    ''');
  }

  // Handle updates when changing schema from an older version
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS bookings');
      await db.execute('''
      CREATE TABLE bookings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_name TEXT,
        dest_name TEXT,
        adult_count INTEGER,
        child_count INTEGER,
        booking_time TEXT,
        fare REAL,
        distance REAL,
        status TEXT,
        train_type TEXT,
        class_type TEXT,
        ticket_type TEXT,
        ir_number TEXT,
        terminal_id TEXT,
        gsin_no TEXT,
        journey_id TEXT,
        via TEXT
      )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profile(
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT,
        phone TEXT
      )
      ''');
    }
    if (oldVersion < 4) {
      // Add 'via' column for anyone upgrading from a DB that doesn't have it yet.
      try {
        await db.execute('ALTER TABLE bookings ADD COLUMN via TEXT');
      } catch (e) {
        // Column may already exist (e.g. table was just recreated above) - safe to ignore.
      }
    }
  }

  // Insert a new recent search
  Future<int> insertRecentSearch(Map<String, String> from, Map<String, String> to) async {
    Database db = await database;
    return await db.insert('recent_searches', {
      'from_name': from['name'],
      'from_code': from['code'],
      'to_name': to['name'],
      'to_code': to['code'],
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Retrieve recent searches (limit to latest 5)
  Future<List<Map<String, dynamic>>> getRecentSearches() async {
    Database db = await database;
    return await db.query('recent_searches', orderBy: 'id DESC', limit: 5);
  }

  // Insert a new booking
  Future<int> insertBooking(Map<String, dynamic> bookingData) async {
    Database db = await database;
    return await db.insert('bookings', bookingData);
  }

  // Fetch bookings by status
  Future<List<Map<String, dynamic>>> getBookingsByStatus(String status) async {
    Database db = await database;
    if (status.toLowerCase() == 'all') {
      return await db.query('bookings', orderBy: 'id DESC');
    }
    return await db.query('bookings',
                          where: 'status = ?',
                          whereArgs: [status.toLowerCase()],
                          orderBy: 'id DESC');
  }

  // Unreserved local-train tickets are valid only for the day of travel,
  // so validity is capped at a maximum of 24 hours regardless of distance.
  static const int maxTicketValidityMinutes = 24 * 60;

  Future<void> silentUpdateBookingStatuses() async {
    Database db = await database;
    List<Map<String, dynamic>> allBookings = await db.query('bookings');

    Batch batch = db.batch();
    DateTime now = DateTime.now();
    bool changesNeeded = false;

    for (var booking in allBookings) {
      String currentStatus = booking['status']?.toString().toLowerCase() ?? '';
      if (currentStatus == 'cancelled') continue;

      try {
        DateTime bookingTime = DateTime.parse(booking['booking_time']);
        double distance = (booking['distance'] as num?)?.toDouble() ?? 0.0;
        int durationMinutes = (distance * 20).toInt();
        if (durationMinutes > maxTicketValidityMinutes) {
          durationMinutes = maxTicketValidityMinutes;
        }
        DateTime expectedCompletionTime = bookingTime.add(Duration(minutes: durationMinutes));

        if (expectedCompletionTime.isBefore(now)) {
          // Validity is over - the ticket is no longer usable, so remove it
          // entirely instead of just marking it 'completed'.
          batch.delete('bookings', where: 'id = ?', whereArgs: [booking['id']]);
          changesNeeded = true;
        } else if (currentStatus != 'upcoming') {
          batch.update(
            'bookings',
            {'status': 'upcoming'},
            where: 'id = ?',
            whereArgs: [booking['id']],
          );
          changesNeeded = true;
        }
      } catch (e) {
        // Skip on error
      }
    }

    if (changesNeeded) {
      await batch.commit(noResult: true);
    }
  }

  // --- NEW: PROFILE METHODS ---

  // Get the single user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  // Save or update user profile (Uses UPSERT approach)
  Future<void> saveUserProfile(String name, String phone) async {
    Database db = await database;
    await db.execute('''
    INSERT OR REPLACE INTO user_profile (id, name, phone)
    VALUES (1, ?, ?)
    ''', [name, phone]);
  }
}
