import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAdminPage extends StatefulWidget {
  const SupabaseAdminPage({super.key});

  @override
  State<SupabaseAdminPage> createState() => _SupabaseAdminPageState();
}

class _SupabaseAdminPageState extends State<SupabaseAdminPage> {
  late final SupabaseClient supabase;
  List<String> tables = [];
  String? selectedTable;
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> tableStructure = [];
  bool isLoading = true;
  String error = '';
  
  @override
  void initState() {
    super.initState();
    supabase = Supabase.instance.client;
    _fetchTables();
  }

  Future<void> _fetchTables() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    
    try {
      final response = await supabase
          .from('information_schema.tables')
          .select('table_name')
          .eq('table_schema', 'public');

      final List<dynamic> data = response as List<dynamic>;
      setState(() {
        tables = data.map((item) => item['table_name'].toString()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching tables: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTableStructure(String tableName) async {
    setState(() {
      isLoading = true;
      error = '';
    });
    
    try {
      final response = await supabase
          .from('information_schema.columns')
          .select()
          .eq('table_schema', 'public')
          .eq('table_name', tableName);

      setState(() {
        tableStructure = List<Map<String, dynamic>>.from(response as List);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching table structure: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchTableData(String tableName) async {
    setState(() {
      isLoading = true;
      error = '';
    });
    
    try {
      final response = await supabase
          .from(tableName)
          .select();

      setState(() {
        tableData = List<Map<String, dynamic>>.from(response as List);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error fetching table data: $e';
        isLoading = false;
      });
    }
  }

  void _selectTable(String tableName) {
    setState(() {
      selectedTable = tableName;
    });
    _fetchTableStructure(tableName);
    _fetchTableData(tableName);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (selectedTable != null) {
                _fetchTableData(selectedTable!);
              } else {
                _fetchTables();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text('Error: $error'))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust for mobile or tablet/desktop views
                      bool isNarrow = constraints.maxWidth < 600;
                      
                      if (isNarrow) {
                        // Mobile layout (stacked)
                        return Column(
                          children: [
                            // Tables dropdown
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Table',
                                  border: OutlineInputBorder(),
                                ),
                                value: selectedTable,
                                items: tables.map((table) => DropdownMenuItem(
                                  value: table,
                                  child: Text(
                                    table,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    _selectTable(value);
                                  }
                                },
                                isExpanded: true,
                              ),
                            ),
                            
                            // Table data
                            if (selectedTable != null) Expanded(
                              child: tableData.isEmpty
                                  ? const Center(child: Text('No data in this table'))
                                  : _buildTableDataView(),
                            ),
                          ],
                        );
                      } else {
                        // Tablet/Desktop layout (side by side)
                        return Row(
                          children: [
                            // Tables list
                            Container(
                              width: 200,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: ListView(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text(
                                      'Tables',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ...tables.map((table) => ListTile(
                                    title: Text(
                                      table,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    selected: selectedTable == table,
                                    onTap: () => _selectTable(table),
                                  )),
                                ],
                              ),
                            ),
                            
                            // Table data view
                            Expanded(
                              child: selectedTable == null
                                  ? const Center(child: Text('Select a table'))
                                  : tableData.isEmpty
                                      ? const Center(child: Text('No data in this table'))
                                      : _buildTableDataView(),
                            ),
                          ],
                        );
                      }
                    },
                  ),
      ),
    );
  }
  
  Widget _buildTableDataView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table name header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              'Table: $selectedTable',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Data table with scrolling
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: tableStructure.isEmpty 
                    ? const Center(child: Text('Loading table structure...'))
                    : DataTable(
                        columnSpacing: 12,
                        horizontalMargin: 12,
                        columns: tableStructure.map((column) => DataColumn(
                          label: Tooltip(
                            message: '${column['data_type']} ${column['is_nullable'] == 'YES' ? '(nullable)' : '(not null)'}',
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                column['column_name'] as String,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )).toList(),
                        rows: tableData.map((row) => DataRow(
                          cells: tableStructure.map((column) {
                            final columnName = column['column_name'] as String;
                            return DataCell(
                              Container(
                                constraints: const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  row[columnName]?.toString() ?? 'null',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onTap: () {
                                // Show full value in a dialog when cell is tapped
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(columnName),
                                    content: SingleChildScrollView(
                                      child: Text(row[columnName]?.toString() ?? 'null'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        )).toList(),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 