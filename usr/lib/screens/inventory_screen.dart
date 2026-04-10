import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final allSpareParts = dataProvider.spareParts;
    final lowStockParts = dataProvider.getLowStockSpareParts();

    // Filter spare parts based on search query
    final filteredParts = allSpareParts.where((part) {
      return part.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             part.specification.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spare Parts Inventory'),
      ),
      body: Column(
        children: [
          // Low Stock Alert Banner
          if (lowStockParts.isNotEmpty)
            Container(
              color: const Color(0xFFF97316).withOpacity(0.1),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Color(0xFFF97316)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${lowStockParts.length} items are below critical stock level',
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search spare parts',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Spare Parts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: filteredParts.length,
              itemBuilder: (context, index) {
                final part = filteredParts[index];
                final isLowStock = part.isLowStock;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isLowStock ? Colors.orange.withOpacity(0.05) : null,
                  child: ListTile(
                    title: Text(
                      part.name,
                      style: TextStyle(
                        color: isLowStock ? const Color(0xFFF97316) : null,
                        fontWeight: isLowStock ? FontWeight.bold : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spec: ${part.specification}'),
                        Text('Stock: ${part.currentStock} (Critical: ${part.criticalLevel})'),
                        Text('Cost: ${part.unitCost} ${part.currency}'),
                        if (part.supplierInfo != null)
                          Text('Supplier: ${part.supplierInfo}'),
                        Text('Compatible: ${part.compatibleMachines.map((id) => dataProvider.getMachineById(id)?.name ?? id).join(', ')}'),
                      ],
                    ),
                    trailing: isLowStock
                        ? const Icon(Icons.warning, color: Color(0xFFF97316))
                        : const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
