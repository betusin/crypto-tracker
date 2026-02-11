import 'package:crypto_tracker/common/widget/page_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/transaction/widget/add_or_update_transaction_screen.dart';
import 'package:crypto_tracker/common/widget/dashboard_screen.dart';
import 'package:crypto_tracker/transaction/widget/transaction_list.dart';
import 'package:crypto_tracker/transaction_import/widget/transaction_import_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [DashboardScreen(), TransactionList()];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Crypto Tracker',
      actions: _selectedIndex == 1 ? [const TransactionImportButton()] : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onAddTransaction(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      child: _screens[_selectedIndex],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  Future<dynamic> _onAddTransaction(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddOrUpdateTransactionScreen()));
}
