import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/data_provider.dart';
import '../models/models.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ?? DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 30)),
        end: DateTime.now(),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final replacements = dataProvider.replacements;
    final spareParts = dataProvider.spareParts;
    final machines = dataProvider.machines;

    // Filter replacements by date range if selected
    final filteredReplacements = _selectedDateRange != null
        ? replacements.where((r) => 
            r.dateReplaced.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            r.dateReplaced.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))
          ).toList()
        : replacements;

    // Monthly cost report data
    final monthlyCostData = _calculateMonthlyCosts(filteredReplacements);

    // Spare part usage frequency data
    final usageFrequencyData = _calculateUsageFrequency(filteredReplacements, spareParts);

    // Inventory status data
    final inventoryStatusData = _calculateInventoryStatus(spareParts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Range Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Date Range',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => _selectDateRange(context),
                      child: Text(
                        _selectedDateRange != null
                            ? '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}'
                            : 'Select Date Range',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Cost Report
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Monthly Cost Report per Machine',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(labelFormat: '{value} TZS'),
                        series: <CartesianSeries>[
                          ColumnSeries<ChartData, String>(
                            dataSource: monthlyCostData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Spare Part Usage Frequency
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spare Part Usage Frequency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(),
                        series: <CartesianSeries>[
                          BarSeries<ChartData, String>(
                            dataSource: usageFrequencyData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            color: const Color(0xFFF97316),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Inventory Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: inventoryStatusData,
                            xValueMapper: (ChartData data, _) => data.x,
                            yValueMapper: (ChartData data, _) => data.y,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Maintenance History
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Maintenance History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...filteredReplacements.map((replacement) {
                      final machine = dataProvider.getMachineById(replacement.machineId);
                      final sparePart = dataProvider.getSparePartById(replacement.sparePartId);
                      return ListTile(
                        title: Text('${machine?.name ?? 'Unknown'} - ${sparePart?.name ?? 'Unknown'}'),
                        subtitle: Text(
                          'Date: ${replacement.dateReplaced.day}/${replacement.dateReplaced.month}/${replacement.dateReplaced.year} | Cost: ${replacement.costIncurred} ${sparePart?.currency ?? ''}',
                        ),
                        trailing: Text('Qty: ${replacement.quantityUsed}'),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // TODO: Add PDF/Excel export functionality
            const Center(
              child: Text(
                'Export to PDF/Excel - Coming Soon',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _calculateMonthlyCosts(List<Replacement> replacements) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final machines = dataProvider.machines;
    final monthlyCosts = <String, double>{};

    for (final machine in machines) {
      final machineReplacements = replacements.where((r) => r.machineId == machine.id);
      final totalCost = machineReplacements.fold<double>(0, (sum, r) => sum + r.costIncurred);
      monthlyCosts[machine.name] = totalCost;
    }

    return monthlyCosts.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  List<ChartData> _calculateUsageFrequency(List<Replacement> replacements, List<SparePart> spareParts) {
    final usageCount = <String, int>{};

    for (final part in spareParts) {
      final count = replacements.where((r) => r.sparePartId == part.id).length;
      if (count > 0) {
        usageCount[part.name] = count;
      }
    }

    return usageCount.entries.map((e) => ChartData(e.key, e.value.toDouble())).toList();
  }

  List<ChartData> _calculateInventoryStatus(List<SparePart> spareParts) {
    final lowStock = spareParts.where((p) => p.isLowStock).length;
    final normalStock = spareParts.length - lowStock;

    return [
      ChartData('Low Stock', lowStock.toDouble()),
      ChartData('Normal Stock', normalStock.toDouble()),
    ];
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
