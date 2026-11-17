import '../../../core/storage/preferences_service.dart';
import '../domain/dashboard_models.dart';
import '../domain/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  MockDashboardRepository({required this.prefs, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final PreferencesService prefs;
  final DateTime Function() _clock;

  static const double openingBalance = 6000000.00;
  static const double _legacyDefaultBalance = 24580.50;

  @override
  Future<DashboardSnapshot> loadDashboard() async {
    final stored = prefs.getPrimaryBalance();
    final now = _clock();

    return (
      balance: stored == _legacyDefaultBalance ? openingBalance : stored,
      isBalanceMasked: prefs.isBalanceMasked(),
      beneficiaries: const [
        Beneficiary(
          id: 'b_1',
          name: 'Sarah Jenkins',
          handle: '@sarahj',
          initials: 'SJ',
        ),
        Beneficiary(
          id: 'b_2',
          name: 'David Miller',
          handle: '@dmiller',
          initials: 'DM',
        ),
        Beneficiary(
          id: 'b_3',
          name: 'Elena Rostova',
          handle: '@erostova',
          initials: 'ER',
        ),
        Beneficiary(
          id: 'b_4',
          name: 'Alexandre Chen',
          handle: '@alexc',
          initials: 'AC',
        ),
        Beneficiary(
          id: 'b_5',
          name: 'Priya Sharma',
          handle: '@priyash',
          initials: 'PS',
        ),
      ],
      notifications: [
        DashboardNotification(
          id: 'n1',
          title: 'Salary Credited',
          subtitle: '\$4,500.00 has been deposited from Stripe Corp',
          date: now.subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        DashboardNotification(
          id: 'n2',
          title: 'Security Alert: New Sign-in',
          subtitle: 'Sign-in detected from iPhone 15 Pro in London, UK',
          date: now.subtract(const Duration(hours: 6)),
          isRead: false,
        ),
        DashboardNotification(
          id: 'n3',
          title: 'Monthly Statement Ready',
          subtitle:
              'Your statement for the previous month is ready for download',
          date: now.subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ],
    );
  }

  @override
  Future<void> saveBalance(double balance) => prefs.setPrimaryBalance(balance);

  @override
  Future<void> setBalanceMasked(bool masked) => prefs.setBalanceMasked(masked);
}
