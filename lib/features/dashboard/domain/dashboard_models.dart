class Beneficiary {
  final String id;
  final String name;
  final String handle;
  final String initials;
  final String? avatarUrl;

  const Beneficiary({
    required this.id,
    required this.name,
    required this.handle,
    required this.initials,
    this.avatarUrl,
  });
}

class DashboardNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final bool isRead;

  const DashboardNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.isRead = false,
  });
}

