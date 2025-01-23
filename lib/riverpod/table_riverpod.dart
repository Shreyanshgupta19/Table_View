import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_view/custom_table/custom_table.dart';

class FlexibleTableState<T> {
  final List<FlexibleColumn<T>> columns;
  final List<T> rows;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int pageSize;

  FlexibleTableState({
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.pageSize = 10,
  });

  FlexibleTableState<T> copyWith({
    List<FlexibleColumn<T>>? columns,
    List<T>? rows,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    int? pageSize,
  }) {
    return FlexibleTableState<T>(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

class FlexibleTableController<T> extends StateNotifier<FlexibleTableState<T>> {
  final Future<Map<String, dynamic>> Function(int page, int pageSize)? onFetchData;
  final T Function(Map<String, dynamic>)? dataConverter;

  FlexibleTableController({
    required List<FlexibleColumn<T>> columns,
    this.onFetchData,
    this.dataConverter,
  }) : super(FlexibleTableState<T>(columns: columns, rows: [])) {
    if (onFetchData != null) {
      fetchData();
    }
  }

  // Dummy api calling
  Future<void> fetchData([int page = 1]) async {
    if (onFetchData == null || dataConverter == null) return;

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await onFetchData!(page, state.pageSize);

      final List<T> rows = (response['data'] as List)
          .map((item) => dataConverter!(item))
          .toList();

      state = state.copyWith(
        rows: rows,
        currentPage: response['page'] as int? ?? 1,
        totalPages: response['total_pages'] as int? ?? 1,
        totalItems: response['total_items'] as int? ?? rows.length,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error fetching data: $e',
      );
    }
  }

  void updateColumnWidth(String columnId, double delta) {
    state = state.copyWith(
      columns: state.columns.map((col) {
        if (col.id == columnId) {
          return col.copyWith(
            width: (col.width + delta).clamp(col.minWidth, col.maxWidth),
          );
        }
        return col;
      }).toList(),
    );
  }

  void refresh() => fetchData(state.currentPage);
}