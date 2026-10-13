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

  List<PlutoColumn> _buildColumns() {
    return [
      PlutoColumn(
        title: 'Team Member',
        field: 'user_name',
        type: PlutoColumnType.text(),
        enableRowChecked: true,
        width: 180,
      ),
      PlutoColumn(
        title: 'Email',
        field: 'user_email',
        type: PlutoColumnType.text(),
        width: 220,
      ),
      PlutoColumn(
        title: 'Meter Metric',
        field: 'meter_name',
        type: PlutoColumnType.text(),
        width: 200,
      ),
      PlutoColumn(
        title: 'Aggregated Usage',
        field: 'total_quantity',
        type: PlutoColumnType.number(format: '#,###.##'),
        textAlign: PlutoColumnTextAlign.right,
        width: 160,
      ),
      PlutoColumn(
        title: 'Unit',
        field: 'unit',
        type: PlutoColumnType.text(),
        width: 110,
      ),
      PlutoColumn(
        title: 'Last Activity',
        field: 'last_activity',
        type: PlutoColumnType.text(),
        width: 180,
      ),
      PlutoColumn(
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        width: 120,
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

  void _exportGridToCsv(List<CustomerUsage> records) {
    final List<List<dynamic>> rows = [
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

    CsvExporter.exportToCsv(
      filename: 'tenant_customer_usage_${DateTime.now().millisecondsSinceEpoch}',
      rows: rows,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customer usage telemetry CSV downloaded successfully.'),
        backgroundColor: AppColors.success,
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
            children: [
              Column(
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
              usageAsync.maybeWhen(
                data: (records) => ElevatedButton.icon(
                  onPressed: () => _exportGridToCsv(records),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export to CSV'),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // PlutoGrid Card Container
          Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: usageAsync.when(
                data: (records) {
                  return PlutoGrid(
                    columns: _buildColumns(),
                    rows: _buildRows(records),
                    onLoaded: (PlutoGridOnLoadedEvent event) {
                      _stateManager = event.stateManager;
                      _stateManager?.setShowColumnFilter(true);
                    },
                    configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(
                        gridBackgroundColor: AppColors.card,
                        rowColor: AppColors.card,
                        cellTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        columnTextStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        gridBorderColor: AppColors.cardBorder,
                        borderColor: AppColors.cardBorder,
                        activatedColor: AppColors.primary.withValues(alpha: 0.12),
                        menuBackgroundColor: AppColors.surfaceElevated,
                      ),
                    ),
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
