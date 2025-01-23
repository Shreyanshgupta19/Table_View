import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_view/data/dummy_response.dart';


// Data Models
class TableColumn {
  final String id;
  final String title;
  double width;

  TableColumn({
    required this.id,
    required this.title,
    this.width = 150,
  });

  factory TableColumn.fromJson(Map<String, dynamic> json) {
    return TableColumn(
      id: json['id'],
      title: json['title'],
      width: (json['width'] ?? 150).toDouble(),
    );
  }
}

class TableRow {
  final String id;
  final Map<String, String> cells;

  TableRow({required this.id, required this.cells});

  factory TableRow.fromJson(Map<String, dynamic> json) {
    return TableRow(
      id: json['id'].toString(),
      cells: Map.fromEntries(
          json.entries.map((e) => MapEntry(e.key, e.value.toString()))),
    );
  }
}

class TableState {
  final List<TableColumn> columns;
  final List<TableRow> rows;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  TableState({
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
  });

  TableState copyWith({
    List<TableColumn>? columns,
    List<TableRow>? rows,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
  }) {
    return TableState(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}


final tableStateProvider = StateNotifierProvider<TableStateNotifier, TableState>((ref) {
  return TableStateNotifier();
});



class TableStateNotifier extends StateNotifier<TableState> {
  static const double minWidth = 100;
  static const double maxWidth = 400;

  TableStateNotifier() : super(TableState(columns: [], rows: [])) {
    initializeTable();
  }

  Future<void> initializeTable() async {
    await Future.wait([fetchColumns(), fetchTableData()]);
  }

  Future<void> fetchColumns() async {
    state = state.copyWith(isLoading: true, error: null);

    List<TableColumn> columns = [
      TableColumn(id: 'id', title: 'ID', width: 150),
      TableColumn(id: 'user_id', title: 'User ID', width: 150),
      TableColumn(id: 'room_id', title: 'Room ID', width: 150),
      TableColumn(id: 'content', title: 'Content', width: 300),
      TableColumn(id: 'time', title: 'Time', width: 150),
      TableColumn(id: 'chat_type', title: 'Response by', width: 150),
      TableColumn(id: 'actions', title: 'Actions', width: 150),
    ];

    state = state.copyWith(columns: columns, isLoading: false);
  }

  Future<void> fetchTableData([int page = 1]) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      await Future.delayed(Duration(seconds: 1));
      final apiResponse = dataResponse;

      List<TableRow> rows = (apiResponse['data'] as List)
          .map((row) => TableRow.fromJson(row))
          .toList();

      state = state.copyWith(
        rows: rows,
        currentPage: apiResponse['page'] as int?,
        totalPages: apiResponse['total_pages'] as int?,
        totalItems: apiResponse['total_items'] as int?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error fetching data: $e');
    }
  }

  void updateColumnWidth(String columnId, double delta) {
    state = state.copyWith(
      columns: state.columns.map((col) {
        if (col.id == columnId) {
          return TableColumn(
            id: col.id,
            title: col.title,
            width: max(minWidth, min(maxWidth, col.width + delta)),
          );
        }
        return col;
      }).toList(),
    );
  }
}



class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}

class ErrorMessage extends StatelessWidget {
  final String error;
  const ErrorMessage({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(error, style: TextStyle(color: Colors.red)));
  }
}

class Pagination extends StatelessWidget {
  final int totalItems;
  final int currentPage;
  final int totalPages;
  const Pagination({Key? key, required this.totalItems, required this.currentPage, required this.totalPages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        'Total Items: $totalItems | Page $currentPage of $totalPages',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}


class ResizableTableScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableState = ref.watch(tableStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Table'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => ref.read(tableStateProvider.notifier).initializeTable(),
          ),
        ],
      ),
      body: tableState.isLoading
          ? LoadingIndicator()
          : tableState.error != null
          ? ErrorMessage(error: tableState.error!)
          : ResizableTableView(state: tableState),
    );
  }
}

class ResizableTableView extends StatelessWidget {
  final TableState state;

  const ResizableTableView({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state.columns.isEmpty) {
      return Center(child: Text('No columns defined'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TableHeader(columns: state.columns),
                  ...state.rows.map((row) => TableRowWidget(
                    row: row,
                    columns: state.columns,
                  )),
                ],
              ),
            ),
          ),
        ),
        Pagination(totalItems: state.totalItems, currentPage: state.currentPage, totalPages: state.totalPages),
      ],
    );
  }
}



class TableHeader extends ConsumerWidget {
  final List<TableColumn> columns;

  const TableHeader({Key? key, required this.columns}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        for (int i = 0; i < columns.length; i++) ...[
          HeaderCell(column: columns[i]),
          if (i < columns.length - 1)
            ResizeHandle(columnId: columns[i].id),
        ],
      ],
    );
  }
}

class HeaderCell extends StatelessWidget {
  final TableColumn column;

  const HeaderCell({Key? key, required this.column}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: column.width,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey[400]!),
      ),
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        column.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TableRowWidget extends StatelessWidget {
  final TableRow row;
  final List<TableColumn> columns;

  const TableRowWidget({Key? key, required this.row, required this.columns})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < columns.length; i++) ...[
          DataCell(
            content: columns[i].id == 'actions'
                ? Row(
              children: [
                IconButton(onPressed: () {}, icon: Icon(Icons.edit, color: Colors.black,) ),
                IconButton(onPressed: () {}, icon: Icon(Icons.delete, color: Colors.red,) ),
              ],
            )
                : Text(
              row.cells[columns[i].id] ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            width: columns[i].width,
          ),
          if (i < columns.length - 1)
            ResizeHandle(columnId: columns[i].id),
        ],
      ],
    );
  }
}

class DataCell<T extends Widget> extends StatelessWidget {
  final T content;
  final double width;

  const DataCell({Key? key, required this.content, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 50,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
      ),
      alignment: Alignment.centerLeft,
      child: content,
    );
  }
}

class ResizeHandle extends ConsumerWidget {
  final String columnId;

  const ResizeHandle({Key? key, required this.columnId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          ref.read(tableStateProvider.notifier).updateColumnWidth(
            columnId,
            details.primaryDelta!,
          );
        },
        child: Container(
          width: 8,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[350],
            border: Border(
              left: BorderSide(color: Colors.grey[400]!, width: 1),
              right: BorderSide(color: Colors.grey[400]!, width: 1),
            ),
          ),
          child: Center(
            child: VerticalDivider(
              color: Colors.grey[600],
              thickness: 1,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// void main() {
//   runApp(ProviderScope(
//     child: MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: ResizableTableScreen(),
//     ),
//   ));
// }