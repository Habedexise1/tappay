import 'dashboard_models.dart';

typedef DashboardSnapshot = ({
  double balance,
  bool isBalanceMasked,
  List<Beneficiary> beneficiaries,
  List<DashboardNotification> notifications,
});

abstract interface class DashboardRepository {
  Future<DashboardSnapshot> loadDashboard();

  Future<void> saveBalance(double balance);

  Future<void> setBalanceMasked(bool masked);
}
