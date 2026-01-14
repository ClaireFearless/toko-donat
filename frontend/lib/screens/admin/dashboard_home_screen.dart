import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DashboardHomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const DashboardHomeScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  Map<String, dynamic>? stats;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);

    // Load products and orders
    final productsResult = await ApiService.getProducts();
    final ordersResult = await ApiService.getOrders();

    if (!mounted) return;

    if (productsResult['success'] == true && ordersResult['success'] == true) {
      final products = productsResult['data'] as List? ?? [];
      final orders = ordersResult['data'] as List? ?? [];

      // Calculate stats
      final totalProducts = products.length;
      final totalOrders = orders.length;
      final pendingOrders =
          orders.where((o) => o['status'] == 'pending').length;
      final completedOrders =
          orders.where((o) => o['status'] == 'completed').length;

      setState(() {
        stats = {
          'totalProducts': totalProducts,
          'totalOrders': totalOrders,
          'pendingOrders': pendingOrders,
          'completedOrders': completedOrders,
        };
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ApiService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Card(
                      color: Colors.brown[700],
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.admin_panel_settings,
                                size: 35,
                                color: Colors.brown[700],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.name ?? 'Admin',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Statistics
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _StatCard(
                          title: 'Total Products',
                          value: stats?['totalProducts']?.toString() ?? '0',
                          icon: Icons.donut_large,
                          color: Colors.blue,
                        ),
                        _StatCard(
                          title: 'Total Orders',
                          value: stats?['totalOrders']?.toString() ?? '0',
                          icon: Icons.shopping_cart,
                          color: Colors.green,
                        ),
                        _StatCard(
                          title: 'Pending Orders',
                          value: stats?['pendingOrders']?.toString() ?? '0',
                          icon: Icons.pending,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: 'Completed Orders',
                          value: stats?['completedOrders']?.toString() ?? '0',
                          icon: Icons.check_circle,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _QuickActionButton(
                      icon: Icons.add_circle,
                      label: 'Add New Product',
                      color: Colors.brown[700]!,
                      onTap: () {
                        // Navigate to Products tab
                        widget.onNavigateToTab?.call(1);
                      },
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      icon: Icons.list_alt,
                      label: 'View All Products',
                      color: Colors.blue,
                      onTap: () {
                        // Navigate to Products tab
                        widget.onNavigateToTab?.call(1);
                      },
                    ),
                    const SizedBox(height: 8),
                    _QuickActionButton(
                      icon: Icons.receipt_long,
                      label: 'Manage Orders',
                      color: Colors.green,
                      onTap: () {
                        // Navigate to Orders tab
                        widget.onNavigateToTab?.call(2);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}