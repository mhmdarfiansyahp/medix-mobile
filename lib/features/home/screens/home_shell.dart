import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../dashboard/screens/dashboard_tab.dart';
import '../../cashier/screens/cashier_tab.dart';
import '../../inventory/screens/inventory_tab.dart';
import '../../profile/screens/profile_screen.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final role = Storage.getUserRole();
    // Kasir defaults to Kasir tab (index 1), Admin/Owner defaults to Dashboard (index 0)
    _currentIndex = (role == 'kasir') ? 1 : 0;
  }

  final List<Widget> _pages = [
    const DashboardTab(),
    const CashierTab(),
    const InventoryTab(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Kasir'),
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Obat'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
