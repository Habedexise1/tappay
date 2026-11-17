import 'package:flutter/foundation.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/security/biometrics_service.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/view_state.dart';
import '../../widgets_bridge/home_widget_service.dart';
import '../data/mock_dashboard_repository.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  final BiometricsService biometrics;
  final HomeWidgetSync widgetSync;
  final DashboardRepository repository;

  DashboardController({
    required PreferencesService prefs,
    required this.biometrics,
    this.widgetSync = const HomeWidgetService(),
    DashboardRepository? repository,
  }) : repository = repository ?? MockDashboardRepository(prefs: prefs) {
    _loadDashboardData();
  }

  ViewState<double> _balanceState = const Initial();
  ViewState<double> get balanceState => _balanceState;

  double _balance = 6000000.00;
  double get balance => _balance;

  WalletCurrency _selectedCurrency = WalletCurrency.ngn;
  WalletCurrency get selectedCurrency => _selectedCurrency;

  double get convertedBalance => _balance * _selectedCurrency.rateFromNgn;

  String get formattedActiveBalance => CurrencyFormatter.format(
    convertedBalance,
    symbol: _selectedCurrency.symbol,
  );

  bool _isBalanceMasked = false;
  bool get isBalanceMasked => _isBalanceMasked;

  List<Beneficiary> _beneficiaries = [];
  List<Beneficiary> get beneficiaries => _beneficiaries;

  List<DashboardNotification> _notifications = [];
  List<DashboardNotification> get notifications => _notifications;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  final List<PaymentCard> _savedCards = [];
  List<PaymentCard> get savedCards => List.unmodifiable(_savedCards);

  PaymentCard? _selectedCard;
  PaymentCard? get selectedCard => _selectedCard;

  void addCard(PaymentCard card) {
    _savedCards.add(card);
    _selectedCard = card;
    notifyListeners();
  }

  void selectCard(PaymentCard? card) {
    _selectedCard = card;
    notifyListeners();
  }

  void removeCard(String cardId) {
    _savedCards.removeWhere((c) => c.id == cardId);
    if (_selectedCard?.id == cardId) {
      _selectedCard = _savedCards.isNotEmpty ? _savedCards.first : null;
    }
    notifyListeners();
  }

  Future<void> _loadDashboardData() async {
    _balanceState = const Loading();
    notifyListeners();

    try {
      final snapshot = await repository.loadDashboard();
      _balance = snapshot.balance;
      _isBalanceMasked = snapshot.isBalanceMasked;
      _beneficiaries = snapshot.beneficiaries;
      _notifications = snapshot.notifications;
    } catch (error) {
      _balanceState = Failure(ErrorMapper.toFailure(error).message);
      notifyListeners();
      return;
    }

    _balanceState = Success(_balance);
    notifyListeners();

    await _syncWidgetBalance();
  }

  void selectCurrency(WalletCurrency currency) {
    if (_selectedCurrency == currency) return;
    _selectedCurrency = currency;
    notifyListeners();
    _syncWidgetBalance();
  }

  void addBeneficiary({required String name, required String handle}) {
    final normalizedHandle = handle.startsWith('@') ? handle : '@$handle';
    final alreadyExists = _beneficiaries.any(
      (b) => b.handle.toLowerCase() == normalizedHandle.toLowerCase(),
    );
    if (alreadyExists) return;

    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name
              .trim()
              .substring(0, name.trim().length >= 2 ? 2 : 1)
              .toUpperCase();

    _beneficiaries = [
      Beneficiary(
        id: 'b_${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        handle: normalizedHandle,
        initials: initials,
      ),
      ..._beneficiaries,
    ];
    notifyListeners();
  }

  Future<bool> toggleBalanceMask() async {
    if (_isBalanceMasked) {
      final authenticated = await biometrics.authenticate(
        reason: 'Authenticate to view account balance',
      );
      if (!authenticated) {
        return false;
      }
    }

    _isBalanceMasked = !_isBalanceMasked;
    await repository.setBalanceMasked(_isBalanceMasked);
    notifyListeners();
    await _syncWidgetBalance();
    return true;
  }

  Future<void> deductBalance(double amount, {required String recipient}) async {
    _balance = (_balance - amount).clamp(0.0, double.infinity);
    await repository.saveBalance(_balance);
    _balanceState = Success(_balance);
    notifyListeners();

    await _syncWidgetTransaction(signedAmountNgn: -amount, merchant: recipient);
  }

  Future<void> creditBalance(double amount, {required String sender}) async {
    _balance += amount;
    await repository.saveBalance(_balance);
    _balanceState = Success(_balance);
    notifyListeners();

    await _syncWidgetTransaction(signedAmountNgn: amount, merchant: sender);
  }

  String get widgetBalanceLabel => _isBalanceMasked
      ? '${_selectedCurrency.symbol}••••••'
      : formattedActiveBalance;

  Future<void> _syncWidgetBalance() =>
      widgetSync.syncBalance(widgetBalanceLabel);

  Future<void> _syncWidgetTransaction({
    required double signedAmountNgn,
    required String merchant,
  }) {
    final converted = signedAmountNgn.abs() * _selectedCurrency.rateFromNgn;
    final sign = signedAmountNgn < 0 ? '-' : '+';
    return widgetSync.syncLastTransaction(
      formattedBalance: widgetBalanceLabel,
      formattedAmount:
          '$sign${CurrencyFormatter.format(converted, symbol: _selectedCurrency.symbol)}',
      merchant: merchant,
      date: DateFormatter.formatShort(DateTime.now()),
    );
  }

  void markNotificationsAsRead() {
    _notifications = _notifications
        .map(
          (n) => DashboardNotification(
            id: n.id,
            title: n.title,
            subtitle: n.subtitle,
            date: n.date,
            isRead: true,
          ),
        )
        .toList();
    notifyListeners();
  }
}
