import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/models.dart';

class MachineDetailScreen extends StatefulWidget {
  const MachineDetailScreen({super.key});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final machineId = ModalRoute.of(context)!.settings.arguments as String;
    final dataProvider = Provider.of<DataProvider>(context);
    final machine = dataProvider.getMachineById(machineId);

    if (machine == null) {
      return const Scaffold(
        body: Center(child: Text('Machine not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(machine.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Spares'),
            Tab(text: 'History'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(machine),
          _buildSparesTab(dataProvider, machineId),
          _buildHistoryTab(dataProvider, machineId),
          _buildReportsTab(dataProvider, machineId),
        ],
      ),
    );
  }

  Widget _buildInfoTab(Machine machine) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Machine Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('Machine ID', machine.id),
                  _buildInfoRow('Name', machine.name),
                  _buildInfoRow('Location', machine.location),
                  _buildInfoRow('Installation Date',
                      '${machine.installationDate.day}/${machine.installationDate.month}/${machine.installationDate.year}'),
                  _buildInfoRow('Status', machine.status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparesTab(DataProvider dataProvider, String machineId) {
    final spares = dataProvider.getCompatibleSpareParts(machineId);
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: spares.length,
      itemBuilder: (context, index) {
        final spare = spares[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(spare.name),
            subtitle: Text('${spare.specification} - Stock: ${spare.currentStock}'),
            trailing: spare.isLowStock
                ? const Icon(Icons.warning, color: Colors.orange)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(DataProvider dataProvider, String machineId) {
    final replacements = dataProvider.getReplacementsForMachine(machineId);
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: replacements.length,
      itemBuilder: (context, index) {
        final replacement = replacements[index];
        final sparePart = dataProvider.getSparePartById(replacement.sparePartId);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(sparePart?.name ?? 'Unknown Part'),
            subtitle: Text(
              'Date: ${replacement.dateReplaced.day}/${replacement.dateReplaced.month}/${replacement.dateReplaced.year} | Cost: ${replacement.costIncurred} ${sparePart?.currency ?? ''}',
            ),
            trailing: Text('Qty: ${replacement.quantityUsed}'),
          ),
        );
      },
    );
  }

  Widget _buildReportsTab(DataProvider dataProvider, String machineId) {
    // TODO: Implement machine-specific reports with charts
    return const Center(
      child: Text('Machine-specific reports coming soon'),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
