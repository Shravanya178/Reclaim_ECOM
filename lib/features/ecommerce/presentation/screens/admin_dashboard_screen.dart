import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin Dashboard Screen - Overview of sales, orders, inventory
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey.shade100 : Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              // Refresh all data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24 : 16),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCards(isDesktop),
                SizedBox(height: 24),
                _buildRevenueChart(context),
                SizedBox(height: 24),
                _buildRecentOrders(),
                SizedBox(height: 24),
                _buildTopProducts(),
                SizedBox(height: 24),
                _buildLowStockAlert(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCards(bool isDesktop) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('Total Sales', '₹1,24,500', Icons.trending_up, Colors.green, '+12.5%')),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Orders', '156', Icons.shopping_bag, Colors.blue, '+8.3%')),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Products', '89', Icons.inventory, Colors.orange, '+5')),
          SizedBox(width: 12),
          Expanded(child: _buildStatCard('Users', '1,234', Icons.people, Colors.purple, '+23')),
        ],
      );
    }
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Sales',
                '₹1,24,500',
                Icons.trending_up,
                Colors.green,
                '+12.5%',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Orders',
                '156',
                Icons.shopping_bag,
                Colors.blue,
                '+8.3%',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Products',
                '89',
                Icons.inventory,
                Colors.orange,
                '+5',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Users',
                '1,234',
                Icons.people,
                Colors.purple,
                '+23',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String change) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    // Simple bar chart without fl_chart dependency
    final data = [15.0, 18.0, 20.0, 17.0, 22.0, 25.0, 28.0];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Revenue (Last 7 Days)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (i) => _buildChartBar(days[i], data[i] / maxVal, Colors.blue, context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartBar(String label, double heightFactor, Color color, BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 140 * heightFactor,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(height: 16),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.shopping_bag, color: Colors.blue[700]),
                  ),
                  title: Text('Order #ORD${1000 + index}', style: TextStyle(fontSize: 14)),
                  subtitle: Text('2 items • ₹2,499', style: TextStyle(fontSize: 12)),
                  trailing: _buildOrderStatusChip('Processing'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'processing':
        color = Colors.orange;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      padding: EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildTopProducts() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Selling Products',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => Divider(height: 16),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.inventory_2, color: Colors.grey[400]),
                  ),
                  title: Text('Product Name ${index + 1}', style: TextStyle(fontSize: 14)),
                  subtitle: Text('₹1,299 • 24 sold', style: TextStyle(fontSize: 12)),
                  trailing: Icon(Icons.trending_up, color: Colors.green, size: 20),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLowStockAlert() {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                SizedBox(width: 8),
                Text(
                  'Low Stock Alert',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              '3 products are running low on stock',
              style: TextStyle(fontSize: 13, color: Colors.orange[800]),
            ),
            SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange[900],
                padding: EdgeInsets.zero,
              ),
              child: const Text('View Details →'),
            ),
          ],
        ),
      ),
    );
  }
}
