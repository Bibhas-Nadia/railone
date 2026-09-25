import 'package:flutter/material.dart';
import 'database_helper.dart';

class DatabaseViewerPage extends StatefulWidget {
  const DatabaseViewerPage({super.key});

  @override
  State<DatabaseViewerPage> createState() => _DatabaseViewerPageState();
}

class _DatabaseViewerPageState extends State<DatabaseViewerPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);

    // Access the database directly through the helper instance
    final db = await DatabaseHelper().database;

    // Fetch all records from both tables
    final bookingsData = await db.query('bookings');
    final searchesData = await db.query('recent_searches');

    if (mounted) {
      setState(() {
        _bookings = bookingsData;
        _recentSearches = searchesData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Database Viewer', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF0D6EFD),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.book_online), text: 'Bookings'),
              Tab(icon: Icon(Icons.history), text: 'Recent Searches'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _fetchAllData,
              tooltip: 'Refresh Data',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTableTab(_bookings),
                  _buildTableTab(_recentSearches),
                ],
              ),
      ),
    );
  }

  Widget _buildTableTab(List<Map<String, dynamic>> tableData) {
    if (tableData.isEmpty) {
      return const Center(
        child: Text(
          'No records found in this table.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Extract column names dynamically from the first map's keys
    List<DataColumn> columns = tableData.first.keys
        .map((key) => DataColumn(
              label: Text(
                key.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
        .toList();

    // Map the values into DataRows
    List<DataRow> rows = tableData.map((row) {
      return DataRow(
        cells: row.values
            .map((value) => DataCell(Text(value?.toString() ?? 'NULL')))
            .toList(),
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable(
            headingRowColor: MaterialStateProperty.resolveWith(
                (states) => Colors.grey.shade200),
            columns: columns,
            rows: rows,
          ),
        ),
      ),
    );
  }
}
