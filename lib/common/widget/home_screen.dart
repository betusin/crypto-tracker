import 'package:crypto_tracker/auth/service/auth_service.dart';
import 'package:crypto_tracker/common/widget/page_wrapper.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/transaction/widget/add_or_update_transaction_screen.dart';
import 'package:crypto_tracker/portfolio/widget/dashboard_screen.dart';
import 'package:crypto_tracker/transaction/widget/transaction_list.dart';
import 'package:crypto_tracker/transaction_import/widget/transaction_import_button.dart';
import 'package:crypto_tracker/expense/widget/expenses_screen.dart';
import 'package:crypto_tracker/expense/widget/add_or_update_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = getIt<AuthService>();

  int _selectedIndex = 0;

  final List<Widget> _screens = [DashboardScreen(), TransactionList(), const ExpensesScreen()];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Crypto Tracker',
      actions: _buildActions(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 2) {
            _onAddExpense(context);
          } else {
            _onAddTransaction(context);
          }
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      child: _screens[_selectedIndex],
    );
  }

  List<Widget>? _buildActions() {
    return switch (_selectedIndex) {
      0 => [IconButton(onPressed: _authService.signOut, icon: const Icon(Icons.logout))],
      1 => [const TransactionImportButton()],
      _ => null,
    };
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Expenses'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  Future<dynamic> _onAddTransaction(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddOrUpdateTransactionScreen()));

  Future<dynamic> _onAddExpense(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (context) => const AddOrUpdateExpenseScreen()));
}
