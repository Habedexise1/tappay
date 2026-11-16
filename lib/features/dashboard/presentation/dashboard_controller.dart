import 'package:flutter/foundation.dart';
import '../../../core/security/biometrics_service.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/view_state.dart';
import '../../widgets_bridge/home_widget_service.dart';
import '../domain/dashboard_models.dart';

class DashboardController extends ChangeNotifier {
  final PreferencesService prefs;
  final BiometricsService biometrics;

  DashboardController({required this.prefs, required this.biometrics}) {
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

    final stored = prefs.getPrimaryBalance();
    _balance = stored == 24580.50 ? 6000000.00 : stored;
    _isBalanceMasked = prefs.isBalanceMasked();

    _beneficiaries = [];

    _notifications = [
      DashboardNotification(
        id: 'n1',
        title: 'Salary Credited',
        subtitle: '\$4,500.00 has been deposited from Stripe Corp',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
      ),
      DashboardNotification(
        id: 'n2',
        title: 'Security Alert: New Sign-in',
        subtitle: 'Sign-in detected from iPhone 15 Pro in London, UK',
        date: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: false,
      ),
      DashboardNotification(
        id: 'n3',
        title: 'Monthly Statement Ready',
        subtitle: 'Your statement for the previous month is ready for download',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
      ),
    ];

    _balanceState = Success(_balance);
    notifyListeners();

    _syncNativeWidget();
  }

  void selectCurrency(WalletCurrency currency) {
    if (_selectedCurrency == currency) return;
    _selectedCurrency = currency;
    notifyListeners();
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
    await prefs.setBalanceMasked(_isBalanceMasked);
    notifyListeners();
    return true;
  }

  Future<void> deductBalance(double amount, {required String recipient}) async {
    _balance = (_balance - amount).clamp(0.0, double.infinity);
    await prefs.setPrimaryBalance(_balance);
    _balanceState = Success(_balance);
    notifyListeners();

    await _syncNativeWidget(lastAmount: amount, lastMerchant: recipient);
  }

  Future<void> creditBalance(double amount, {required String sender}) async {
    _balance += amount;
    await prefs.setPrimaryBalance(_balance);
    _balanceState = Success(_balance);
    notifyListeners();

    await _syncNativeWidget(lastAmount: amount, lastMerchant: sender);
  }

  Future<void> _syncNativeWidget({
    double lastAmount = 199.99,
    String lastMerchant = 'Apple Store',
  }) async {
    await HomeWidgetService.updateWidgetData(
      balance: _balance,
      lastAmount: lastAmount,
      lastMerchant: lastMerchant,
      lastDate: DateFormatter.formatShort(DateTime.now()),
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
