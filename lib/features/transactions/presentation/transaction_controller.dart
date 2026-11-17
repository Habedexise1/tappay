import 'package:flutter/foundation.dart';
import '../../../core/utils/view_state.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  final TransactionRepository repository;

  TransactionController({required this.repository}) {
    loadTransactions();
  }

  ViewState<List<TransactionModel>> _transactionsState = const Initial();
  ViewState<List<TransactionModel>> get transactionsState => _transactionsState;

  List<TransactionModel> _allTransactions = [];
  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  TransactionModel? _selectedTransaction;
  TransactionModel? get selectedTransaction => _selectedTransaction;

  List<String> get filterCategories => ['All', 'Income', 'Expense', 'Transfer'];

  List<TransactionModel> get filteredTransactions {
    if (_selectedCategory == 'All') return _allTransactions;
    if (_selectedCategory == 'Income') {
      return _allTransactions
          .where((t) => t.type == TransactionType.inflow)
          .toList();
    }
    if (_selectedCategory == 'Expense') {
      return _allTransactions
          .where((t) => t.type == TransactionType.outflow)
          .toList();
    }
    if (_selectedCategory == 'Transfer') {
      return _allTransactions.where((t) => t.category == 'Transfer').toList();
    }
    return _allTransactions;
  }

  Future<void> loadTransactions() async {
    _transactionsState = const Loading('Loading transactions...');
    notifyListeners();

    try {
      final list = await repository.getTransactions();
      _allTransactions = List<TransactionModel>.from(list);
      if (list.isEmpty) {
        _transactionsState = const Empty('No transactions found yet');
      } else {
        _transactionsState = Success(list);
      }
      notifyListeners();
    } catch (e) {
      _transactionsState = Failure('Could not load transactions: $e');
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void selectTransaction(TransactionModel transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void addTransaction(TransactionModel tx) {
    _allTransactions = [tx, ..._allTransactions];
    _transactionsState = Success(_allTransactions);
    notifyListeners();
  }
}
