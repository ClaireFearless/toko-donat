import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  List<dynamic> orders = [];
  bool isLoading = true;
  String selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => isLoading = true);

    final result = await ApiService.getOrders();

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        orders = result['data'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get filteredOrders {
    if (selectedFilter == 'all') return orders;
    return orders.where((order) => order['status'] == selectedFilter).toList();
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final result = await ApiService.updateOrderStatus(orderId, newStatus);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to update status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${orders.length})',
                  isSelected: selectedFilter == 'all',
                  onSelected: () => setState(() => selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  isSelected: selectedFilter == 'pending',
                  onSelected: () => setState(() => selectedFilter = 'pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Paid',
                  isSelected: selectedFilter == 'paid',
                  onSelected: () => setState(() => selectedFilter = 'paid'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Processing',
                  isSelected: selectedFilter == 'processing',
                  onSelected: () =>
                      setState(() => selectedFilter = 'processing'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  isSelected: selectedFilter == 'completed',
                  onSelected: () =>
                      setState(() => selectedFilter = 'completed'),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedFilter == 'all'
                                  ? 'No orders yet'
                                  : 'No $selectedFilter orders',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _OrderCard(
                              order: order,
                              statusColor: _getStatusColor(order['status']),
                              onUpdateStatus: (newStatus) =>
                                  _updateOrderStatus(order['id'], newStatus),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.brown[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;
  final Function(String) onUpdateStatus;

  const _OrderCard({
    required this.order,
    required this.statusColor,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final orderNumber = order['order_number'] ?? 'N/A';
    final status = order['status'] ?? 'pending';
    final totalPrice = double.tryParse(order['total_price'].toString()) ?? 0;
    final createdAt = order['created_at'] ?? '';
    final items = order['order_items'] as List<dynamic>? ?? [];
    final user = order['user'];
    final customerName = user?['name'] ?? 'Customer';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(Icons.receipt, color: statusColor),
        ),
        title: Text(
          orderNumber,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Customer: $customerName'),
            Text('Date: $createdAt'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Rp ${totalPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Items
                const Text(
                  'Items:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final product = item['product'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${product['name']} x${item['quantity']}'),
                        Text('Rp ${item['subtotal']}'),
                      ],
                    ),
                  );
                }).toList(),
                const Divider(),

                // Shipping Info
                const Text(
                  'Shipping Address:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(order['shipping_address'] ?? 'N/A'),
                const SizedBox(height: 8),

                const Text(
                  'Phone:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(order['phone'] ?? 'N/A'),
                const SizedBox(height: 8),

                const Text(
                  'Payment Method:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text((order['payment_method'] ?? 'N/A').toUpperCase()),
                const SizedBox(height: 16),

                // Update Status Button
                const Text(
                  'Update Status:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    if (status != 'paid')
                      _StatusButton(
                        label: 'Paid',
                        color: Colors.blue,
                        onPressed: () => onUpdateStatus('paid'),
                      ),
                    if (status != 'processing')
                      _StatusButton(
                        label: 'Processing',
                        color: Colors.purple,
                        onPressed: () => onUpdateStatus('processing'),
                      ),
                    if (status != 'completed')
                      _StatusButton(
                        label: 'Completed',
                        color: Colors.green,
                        onPressed: () => onUpdateStatus('completed'),
                      ),
                    if (status != 'cancelled')
                      _StatusButton(
                        label: 'Cancelled',
                        color: Colors.red,
                        onPressed: () => onUpdateStatus('cancelled'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _StatusButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}