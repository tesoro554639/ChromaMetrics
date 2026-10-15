import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../tenant/presentation/tenant_controller.dart';
import '../domain/customer_usage.dart';
import 'usage_grid_controller.dart';

class CustomerUsageGridScreen extends ConsumerStatefulWidget {
  const CustomerUsageGridScreen({super.key});

  @override
  ConsumerState<CustomerUsageGridScreen> createState() => _CustomerUsageGridScreenState();
}

class _CustomerUsageGridScreenState extends ConsumerState<CustomerUsageGridScreen> {
  PlutoGridStateManager? _stateManager;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'ALL';
  bool _showColumnFilters = false;
  int _checkedRowCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Team Member',
        field: 'user_name',
        type: PlutoColumnType.text(),
        enableRowChecked: true,
        width: 200,
        minWidth: 160,
      ),
      PlutoColumn(
        title: 'Email',
        field: 'user_email',
        type: PlutoColumnType.text(),
        width: 240,
        minWidth: 180,
      ),
      PlutoColumn(
        title: 'Meter Metric',
        field: 'meter_name',
        type: PlutoColumnType.text(),
        width: 220,
        minWidth: 170,
      ),
      PlutoColumn(
        title: 'Aggregated Usage',
        field: 'total_quantity',
        type: PlutoColumnType.number(format: '#,###.##'),
        textAlign: PlutoColumnTextAlign.right,
        width: 170,
        minWidth: 140,
      ),
      PlutoColumn(
        title: 'Unit',
        field: 'unit',
        type: PlutoColumnType.text(),
        width: 150,
        minWidth: 130,
      ),
      PlutoColumn(
        title: 'Last Activity',
        field: 'last_activity',
        type: PlutoColumnType.text(),
        width: 200,
        minWidth: 160,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        width: 130,
        minWidth: 110,
        renderer: (rendererContext) {
          final isAct = rendererContext.cell.value == 'ACTIVE';
          return Center(
            child: StatusBadge(
              status: isAct ? BadgeStatus.active : BadgeStatus.canceled,
              label: rendererContext.cell.value as String,
            ),
          );
        },
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<CustomerUsage> records) {
    return records.map((r) {
      return PlutoRow(
        cells: {
          'user_name': PlutoCell(value: r.userName),
          'user_email': PlutoCell(value: r.userEmail),
          'meter_name': PlutoCell(value: r.meterName),
          'total_quantity': PlutoCell(value: r.totalQuantity),
          'unit': PlutoCell(value: r.unit),
          'last_activity': PlutoCell(value: DateFormatter.formatFull(r.lastActivity)),
          'status': PlutoCell(value: r.status),
        },
      );
    }).toList();
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty && _selectedStatus == 'ALL') {
      _stateManager?.setFilter(null);
      return;
    }

    _stateManager?.setFilter((PlutoRow row) {
      final name = row.cells['user_name']?.value?.toString().toLowerCase() ?? '';
      final email = row.cells['user_email']?.value?.toString().toLowerCase() ?? '';
      final meter = row.cells['meter_name']?.value?.toString().toLowerCase() ?? '';
      final unit = row.cells['unit']?.value?.toString().toLowerCase() ?? '';
      final status = row.cells['status']?.value?.toString().toUpperCase() ?? '';

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          email.contains(query) ||
          meter.contains(query) ||
          unit.contains(query);

      final matchesStatus = _selectedStatus == 'ALL' || status == _selectedStatus;

      return matchesQuery && matchesStatus;
    });
  }

  void _exportGridToCsv(List<CustomerUsage> records, {bool onlySelected = false}) {
    List<List<dynamic>> rows;

    if (onlySelected && _stateManager != null && _stateManager!.checkedRows.isNotEmpty) {
      final checked = _stateManager!.checkedRows;
      rows = [
        ['User Name', 'Email', 'Meter Name', 'Total Usage', 'Unit', 'Last Activity', 'Status'],
        ...checked.map((r) => [
              r.cells['user_name']?.value ?? '',
              r.cells['user_email']?.value ?? '',
              r.cells['meter_name']?.value ?? '',
              r.cells['total_quantity']?.value ?? 0,
              r.cells['unit']?.value ?? '',
              r.cells['last_activity']?.value ?? '',
              r.cells['status']?.value ?? '',
            ]),
      ];
    } else {
      rows = [
        ['User Name', 'Email', 'Meter Name', 'Total Usage', 'Unit', 'Last Activity', 'Status'],
        ...records.map((r) => [
              r.userName,
              r.userEmail,
              r.meterName,
              r.totalQuantity,
              r.unit,
              r.lastActivity.toIso8601String(),
              r.status,
            ]),
      ];
    }

    CsvExporter.exportToCsv(
      filename: onlySelected
          ? 'selected_customer_usage_${DateTime.now().millisecondsSinceEpoch}'
          : 'tenant_customer_usage_${DateTime.now().millisecondsSinceEpoch}',
      rows: rows,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(onlySelected
            ? 'Exported ${_stateManager?.checkedRows.length} selected usage records to CSV.'
            : 'Customer usage telemetry CSV downloaded successfully.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Widget _buildFilterChip(String status, String label, int count) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        _applyFilters();
      },
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.surfaceElevated.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTenant = ref.watch(activeTenantProvider);
    final usageAsync = ref.watch(customerUsageListProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer Usage Telemetry Grid',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High-performance telemetry and usage records for ${activeTenant?.name ?? "tenant"}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              usageAsync.maybeWhen(
                data: (records) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Refresh Telemetry',
                      icon: const Icon(Icons.refresh_rounded, size: 20, color: AppColors.textSecondary),
                      onPressed: () => ref.invalidate(customerUsageListProvider),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _exportGridToCsv(records),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Export to CSV'),
                    ),
                  ],
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Control Toolbar (Search, Status Filter, Column Filter Toggle)
          usageAsync.maybeWhen(
            data: (records) {
              final activeCount = records.where((r) => r.status == 'ACTIVE').length;
              final inactiveCount = records.where((r) => r.status != 'ACTIVE').length;

              return Column(
                children: [
                  Row(
                    children: [
                      // Search input
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _applyFilters(),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Search member, email, or meter metric...',
                              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondary),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
                                      onPressed: () {
                                        _searchController.clear();
                                        _applyFilters();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Status Tabs (All / Active / Inactive)
                      Container(
                        height: 40,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFilterChip('ALL', 'All', records.length),
                            _buildFilterChip('ACTIVE', 'Active', activeCount),
                            _buildFilterChip('INACTIVE', 'Inactive', inactiveCount),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Column Filters Toggle Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _showColumnFilters
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.card,
                          side: BorderSide(
                            color: _showColumnFilters ? AppColors.primary : AppColors.cardBorder,
                          ),
                          foregroundColor:
                              _showColumnFilters ? AppColors.primary : AppColors.textSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          setState(() {
                            _showColumnFilters = !_showColumnFilters;
                            _stateManager?.setShowColumnFilter(_showColumnFilters);
                          });
                        },
                        icon: Icon(
                          _showColumnFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
                          size: 16,
                        ),
                        label: Text(_showColumnFilters ? 'Filters On' : 'Filter Columns'),
                      ),
                    ],
                  ),

                  // Selection Action Bar (Appears when rows are checked)
                  if (_checkedRowCount > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            '$_checkedRowCount ${ _checkedRowCount == 1 ? "row" : "rows" } selected',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () => _exportGridToCsv(records, onlySelected: true),
                            icon: const Icon(Icons.file_download_outlined, size: 16),
                            label: const Text('Export Selected (CSV)', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () {
                              if (_stateManager != null) {
                                for (final row in _stateManager!.checkedRows.toList()) {
                                  _stateManager!.setRowChecked(row, false, notify: false);
                                }
                                _stateManager!.notifyListeners();
                              }
                              setState(() {
                                _checkedRowCount = 0;
                              });
                            },
                            child: const Text('Deselect All', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),

          // PlutoGrid Card Container
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: usageAsync.when(
                data: (records) {
                  return Column(
                    children: [
                      Expanded(
                        child: PlutoGrid(
                          columns: _buildColumns(),
                          rows: _buildRows(records),
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            _stateManager = event.stateManager;
                            _stateManager?.setShowColumnFilter(_showColumnFilters);
                          },
                          onRowChecked: (PlutoGridOnRowCheckedEvent event) {
                            setState(() {
                              _checkedRowCount = _stateManager?.checkedRows.length ?? 0;
                            });
                          },
                          configuration: PlutoGridConfiguration.dark(
                            columnSize: const PlutoGridColumnSizeConfig(
                              autoSizeMode: PlutoAutoSizeMode.scale,
                              resizeMode: PlutoResizeMode.normal,
                            ),
                            style: PlutoGridStyleConfig.dark(
                              gridBackgroundColor: AppColors.card,
                              rowColor: AppColors.card,
                              evenRowColor: AppColors.card,
                              oddRowColor: const Color(0xFF161F36),
                              activatedColor: AppColors.primary.withValues(alpha: 0.15),
                              checkedColor: AppColors.primary.withValues(alpha: 0.12),
                              gridBorderColor: Colors.transparent,
                              borderColor: AppColors.cardBorder.withValues(alpha: 0.5),
                              activatedBorderColor: AppColors.primary,
                              inactivatedBorderColor: AppColors.cardBorder,
                              cellColorInEditState: const Color(0xFF1E293B),
                              cellColorInReadOnlyState: const Color(0xFF161F36),
                              menuBackgroundColor: AppColors.surfaceElevated,
                              iconColor: AppColors.textSecondary,
                              disabledIconColor: AppColors.textMuted,
                              gridBorderRadius: BorderRadius.circular(12),
                              rowHeight: 52,
                              columnHeight: 46,
                              columnFilterHeight: 42,
                              columnTextStyle: const TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                letterSpacing: 0.4,
                              ),
                              cellTextStyle: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              defaultColumnFilterPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            ),
                          ),
                        ),
                      ),
                      // Telemetry Status Footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.card,
                          border: Border(
                            top: BorderSide(color: AppColors.cardBorder, width: 1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Telemetry Stream: Realtime Sync Active',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              'Showing ${records.length} usage records • 30-day aggregation window',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading usage data: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
