
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_view/riverpod/table_riverpod.dart';

class FlexibleColumn<T> {
  final String id;
  final String title;
  double width;
  final double minWidth;
  final double maxWidth;
  final Color backgroundColor;
  final Widget Function(T)? cellBuilder;

  FlexibleColumn({
    required this.id,
    required this.title,
    this.width = 150,
    this.minWidth = 100,
    this.maxWidth = 400,
    this.backgroundColor = Colors.white,
    this.cellBuilder,
  });

  FlexibleColumn<T> copyWith({
    String? id,
    String? title,
    double? width,
    double? minWidth,
    double? maxWidth,
    Color? backgroundColor,
    Widget Function(T)? cellBuilder,
  }) {
    return FlexibleColumn<T>(
      id: id ?? this.id,
      title: title ?? this.title,
      width: width ?? this.width,
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      cellBuilder: cellBuilder ?? this.cellBuilder,
    );
  }
}

class _TableCell extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final EdgeInsets? padding;

  const _TableCell({
    required this.child,
    required this.width,
    required this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

class _ResizeHandle extends StatelessWidget {
  final double height;
  final Function(double) onResize;

  const _ResizeHandle({
    required this.height,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) => onResize(details.primaryDelta!),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: 8,
          height: height,
          color: Colors.grey[300],
          child: Center(
            child: Container(
              width: 1,
              height: 20,
              color: Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderRow<T> extends ConsumerWidget {
  final FlexibleTableState<T> state;
  final StateNotifierProvider<FlexibleTableController<T>, FlexibleTableState<T>> controller;
  final TextStyle? headerStyle;

  const _HeaderRow({
    required this.state,
    required this.controller,
    this.headerStyle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        for (int i = 0; i < state.columns.length; i++) ...[
          _TableCell(
            width: state.columns[i].width,
            height: 50,
            child: Text(
              state.columns[i].title,
              style: headerStyle ?? const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (i < state.columns.length - 1)
            _ResizeHandle(
              height: 50,
              onResize: (delta) {
                ref.read(controller.notifier).updateColumnWidth(
                  state.columns[i].id,
                  delta,
                );
              },
            ),
        ],
      ],
    );
  }
}

class _DataRow<T> extends StatelessWidget {
  final T row;
  final List<FlexibleColumn<T>> columns;
  final double rowHeight;
  final VoidCallback? onTap;

  const _DataRow({
    required this.row,
    required this.columns,
    required this.rowHeight,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          for (int i = 0; i < columns.length; i++) ...[
            _TableCell(
              width: columns[i].width,
              height: rowHeight,
              child: columns[i].id == 'actions'
                  ? ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: columns[i].width - 16, // Account for padding
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Handle edit action
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Handle delete action
                      },
                    ),
                  ],
                ),
              )
                  : columns[i].cellBuilder?.call(row) ?? Text(row.toString()),
            ),
            if (i < columns.length - 1)
              Container(
                width: 8,
                height: rowHeight,
                color: Colors.white,
              ),
          ],
        ],
      ),
    );
  }
}

class _FlexibleTableState<T> extends ConsumerState<FlexibleTable<T>> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _dataScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _dataScrollController.addListener(() {
      if (_headerScrollController.position.pixels != _dataScrollController.position.pixels) {
        _headerScrollController.jumpTo(_dataScrollController.position.pixels);
      }
    });

    _headerScrollController.addListener(() {
      if (_dataScrollController.position.pixels != _headerScrollController.position.pixels) {
        _dataScrollController.jumpTo(_headerScrollController.position.pixels);
      }
    });
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _dataScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.controller);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!, style: TextStyle(color: Colors.red)));
    }

    final totalWidth = state.columns.fold<double>
      (0, (sum, col) => sum + col.width,) + (state.columns.length - 1) * 8;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            controller: _headerScrollController,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
              width: totalWidth,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: _HeaderRow<T>(
                state: state,
                controller: widget.controller,
                headerStyle: widget.headerStyle,
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _dataScrollController,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              width: totalWidth,
              child: ListView.builder(
                itemCount: state.rows.length,
                itemBuilder: (context, index) => _DataRow<T>(
                  row: state.rows[index],
                  columns: state.columns,
                  rowHeight: widget.rowHeight,
                  onTap: widget.onRowTap != null
                      ? () => widget.onRowTap!(state.rows[index])
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (widget.showPagination)
          _Pagination(
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            totalItems: state.totalItems,
            onPageChange: (page) => ref.read(widget.controller.notifier).fetchData(page),
          ),
      ],
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final Function(int) onPageChange;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Items: $totalItems | Page $currentPage of $totalPages',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1
                    ? () => onPageChange(currentPage - 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => onPageChange(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FlexibleTable<T> extends ConsumerStatefulWidget {
  final StateNotifierProvider<FlexibleTableController<T>, FlexibleTableState<T>> controller;
  final void Function(T)? onRowTap;
  final double rowHeight;
  final TextStyle? headerStyle;
  final bool showPagination;

  const FlexibleTable({
    Key? key,
    required this.controller,
    this.onRowTap,
    this.rowHeight = 50,
    this.headerStyle,
    this.showPagination = true,
  }) : super(key: key);

  @override
  ConsumerState<FlexibleTable<T>> createState() => _FlexibleTableState<T>();
}