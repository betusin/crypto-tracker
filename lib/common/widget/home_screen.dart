import 'package:crypto_tracker/auth/service/auth_service.dart';
import 'package:crypto_tracker/common/constants/shared_ui_constants.dart';
import 'package:crypto_tracker/common/widget/page_wrapper.dart';
import 'package:crypto_tracker/ioc/ioc_container.dart';
import 'package:flutter/material.dart';
import 'package:crypto_tracker/transaction/widget/add_or_update_transaction_screen.dart';
import 'package:crypto_tracker/portfolio/widget/dashboard_screen.dart';
import 'package:crypto_tracker/transaction/widget/transaction_list.dart';
import 'package:crypto_tracker/transaction_import/widget/transaction_import_button.dart';
import 'package:crypto_tracker/expense/widget/expenses_screen.dart';
import 'package:crypto_tracker/expense/widget/add_or_update_expense_screen.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = getIt<AuthService>();

  int _selectedIndex = 0;
  final _key = GlobalKey<ExpandableFabState>();

  final List<Widget> _screens = [DashboardScreen(), TransactionList(), const ExpensesScreen()];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: 'Crypto Tracker',
      actions: _buildActions(),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.fan,
        openButtonBuilder: RotateFloatingActionButtonBuilder(child: const Icon(Icons.add)),
        children: [
          FloatingActionButton.large(
            heroTag: null,
            child: const Icon(Icons.currency_exchange),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              _onAddTransaction(context);
            },
          ),
          FloatingActionButton.large(
            heroTag: null,
            child: const Icon(Icons.receipt),
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
              _onAddExpense(context);
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: STANDARD_GAP_SIZE * 4),
        child: _screens[_selectedIndex],
      ),
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
