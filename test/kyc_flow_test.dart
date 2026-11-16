import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tappay/core/security/biometrics_service.dart';
import 'package:tappay/core/storage/preferences_service.dart';
import 'package:tappay/core/storage/secure_storage_service.dart';
import 'package:tappay/features/kyc/data/mock_kyc_repository.dart';
import 'package:tappay/features/kyc/domain/kyc_models.dart';
import 'package:tappay/features/kyc/domain/kyc_repository.dart';
import 'package:tappay/features/kyc/presentation/kyc_controller.dart';
import 'package:tappay/features/kyc/presentation/kyc_navigation.dart';
import 'package:tappay/features/kyc/presentation/screens/kyc_camera_permission_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/kyc_id_details_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/kyc_income_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/kyc_selfie_capture_screen.dart';
import 'package:tappay/features/kyc/presentation/screens/kyc_selfie_intro_screen.dart';
import 'package:tappay/features/kyc/presentation/selfie_camera.dart';
import 'package:tappay/features/transactions/data/transaction_repository.dart';
import 'package:tappay/main.dart';

const _statement = KycDocument(
  name: 'statement.pdf',
  path: '/tmp/statement.pdf',
  sizeBytes: 200 * 1024,
  isImage: false,
);

class _FakeMedia implements KycMediaSource {
  KycDocument? next = _statement;
  int calls = 0;

  @override
  Future<KycDocument?> pickDocument() async {
    calls++;
    return next;
  }

  @override
  Future<KycDocument?> pickPhoto() => pickDocument();

  @override
  Future<KycDocument?> takePhoto() => pickDocument();
}

class _FakePermission implements CameraPermissionService {
  CameraPermission current;

  _FakePermission({this.current = CameraPermission.denied});

  @override
  Future<CameraPermission> status() async => current;

  @override
  Future<CameraPermission> request() async =>
      current = CameraPermission.granted;

  @override
  Future<bool> openSettings() async => true;
}

class _FakeCamera extends SelfieCamera {
  final int selfieBytes;
  bool _ready = false;

  _FakeCamera(this.selfieBytes);

  @override
  bool get isReady => _ready;
  @override
  String? get error => null;
  @override
  SelfieLighting get lighting => SelfieLighting.good;
  @override
  double get previewAspectRatio => 3 / 4;

  @override
  Future<void> initialize() async {
    _ready = true;
    notifyListeners();
  }

  @override
  Widget buildPreview() => const ColoredBox(color: Colors.blueGrey);

  @override
  Future<KycDocument> capture() async => KycDocument(
    name: 'selfie.jpg',
    path: '/tmp/selfie.jpg',
    sizeBytes: selfieBytes,
    isImage: true,
  );
}

class _CountingRepository extends MockKycRepository {
  int submissions = 0;

  _CountingRepository(PreferencesService prefs)
    : super(
        prefs: prefs,
        uploadDuration: const Duration(milliseconds: 120),
        reviewDuration: const Duration(milliseconds: 300),
      );

  @override
  Future<KycStatus> submit(
    KycFlow flow,
    KycApplication application, {
    void Function(double progress)? onProgress,
  }) {
    submissions++;
    return super.submit(flow, application, onProgress: onProgress);
  }
}

class _MemorySecureStorage extends SecureStorageService {
  String? pin = '1234';

  @override
  Future<void> savePin(String value) async => pin = value;
  @override
  Future<String?> getPin() async => pin;
  @override
  Future<bool> hasPin() async => pin != null;
  @override
  Future<bool> isBiometricsEnabled() async => false;
  @override
  Future<bool> isTwoFactorEnabled() async => false;
  @override
  Future<String> getTwoFactorType() async => 'SMS';
}

class _NoBiometrics extends BiometricsService {
  @override
  Future<bool> canAuthenticate() async => false;
}

Future<PreferencesService> _prefs() async {
  SharedPreferences.setMockInitialValues({'tappay_theme_mode': 'light'});
  return PreferencesService.init();
}

/// Home with a button that starts [flow], mirroring the dashboard banner.
class _Launcher extends StatelessWidget {
  final KycFlow flow;

  const _Launcher(this.flow);

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        onPressed: () => KycNavigator.start(context, flow),
        child: const Text('Start KYC'),
      ),
    ),
  );
}

Widget _app({
  required PreferencesService prefs,
  required KycRepository repository,
  required _FakeMedia media,
  required _FakePermission permission,
  required int selfieBytes,
  KycFlow flow = KycFlow.usd,
}) {
  return TapPayRoot(
    preferencesService: prefs,
    secureStorageService: _MemorySecureStorage(),
    biometricsService: _NoBiometrics(),
    transactionRepository: MockTransactionRepository(),
    kycRepository: repository,
    kycMediaSource: media,
    cameraPermissionService: permission,
    selfieCameraFactory: () => _FakeCamera(selfieBytes),
    initialHome: _Launcher(flow),
  );
}

void _phoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _completeUsdForms(WidgetTester tester) async {
  await _tap(tester, find.text('Start KYC'));
  expect(find.text('What do you do?'), findsOneWidget);

  await _tap(tester, find.byKey(const ValueKey('kyc_employment_field')));
  await _tap(tester, find.byKey(const ValueKey('kyc_option_Self-employed')));
  await tester.enterText(
    find.descendant(
      of: find.byKey(const ValueKey('kyc_occupation_field')),
      matching: find.byType(EditableText),
    ),
    'Designer',
  );
  await tester.pump();
  await _tap(tester, find.byKey(const ValueKey('kyc_next_btn')));

  expect(find.byType(KycIncomeScreen), findsOneWidget);
  await _tap(tester, find.byKey(const ValueKey('kyc_income_band_field')));
  await _tap(tester, find.byKey(const ValueKey('kyc_option_\$100 - \$10,000')));
  await _tap(tester, find.byKey(const ValueKey('kyc_bank_statement_upload')));
  await _tap(tester, find.byKey(const ValueKey('kyc_origin_files')));
  expect(find.text('statement.pdf'), findsOneWidget);
  await _tap(tester, find.byKey(const ValueKey('kyc_next_btn')));

  expect(find.byType(KycSelfieIntroScreen), findsOneWidget);
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('home_widget'),
          (_) async => true,
        );
  });

  group('KYC domain', () {
    test('wallet currency selects the KYC flow', () {
      expect(KycFlow.forCurrencyCode('USD'), KycFlow.usd);
      expect(KycFlow.forCurrencyCode('NGN'), KycFlow.usd);
      expect(KycFlow.forCurrencyCode('gbp'), KycFlow.gbpEur);
      expect(KycFlow.forCurrencyCode('EUR'), KycFlow.gbpEur);
      expect(KycFlow.usd.stepAfter(KycStep.income), KycStep.selfie);
      expect(KycFlow.usd.stepAfter(KycStep.selfie), isNull);
    });

    test('date of birth requires an adult', () {
      final now = DateTime(2026, 11, 16);
      expect(
        KycRules.validateDateOfBirth(DateTime(2010, 1, 1), now: now),
        contains('18'),
      );
      expect(
        KycRules.validateDateOfBirth(DateTime(2008, 11, 17), now: now),
        isNotNull,
        reason: 'turns 18 tomorrow',
      );
      expect(
        KycRules.validateDateOfBirth(DateTime(2008, 11, 16), now: now),
        isNull,
      );
    });

    test('ID dates are parsed and validated', () {
      final now = DateTime(2026, 11, 16);
      expect(MonthYear.tryParse('13/27'), isNull);
      expect(MonthYear.tryParse('09/27').toString(), '09/27');
      expect(
        KycRules.validateExpiryDate(MonthYear.tryParse('10/26'), now: now),
        'This ID has expired',
      );
      expect(
        KycRules.validateExpiryDate(
          MonthYear.tryParse('01/27'),
          issue: MonthYear.tryParse('02/27'),
          now: now,
        ),
        'Must be after issue date',
      );
      expect(
        KycRules.validateIssueDate(MonthYear.tryParse('12/26'), now: now),
        'Cannot be in the future',
      );
    });
  });

  group('KycController', () {
    late PreferencesService prefs;
    late _CountingRepository repo;
    late _FakeMedia media;
    late KycController kyc;

    setUp(() async {
      prefs = await _prefs();
      repo = _CountingRepository(prefs);
      media = _FakeMedia();
      kyc = KycController(repository: repo, media: media)..start(KycFlow.usd);
    });

    void fillUsd({int selfieBytes = 80 * 1024}) {
      kyc
        ..setEmploymentStatus(EmploymentStatus.employed)
        ..setOccupation('Engineer')
        ..setIncomeBand(IncomeBand.upTo10k);
      kyc.setSelfie(
        KycDocument(
          name: 's.jpg',
          path: '/tmp/s.jpg',
          sizeBytes: selfieBytes,
          isImage: true,
        ),
      );
    }

    test('attaches documents and rejects files over 10 MB', () async {
      await kyc.attach(KycDocumentSlot.bankStatement, KycMediaOrigin.files);
      expect(kyc.application.bankStatement?.name, 'statement.pdf');

      media.next = const KycDocument(
        name: 'huge.pdf',
        path: '/tmp/huge.pdf',
        sizeBytes: 11 * 1024 * 1024,
        isImage: false,
      );
      await kyc.attach(KycDocumentSlot.utilityBill, KycMediaOrigin.files);
      expect(kyc.application.utilityBill, isNull);
      expect(kyc.attachState(KycDocumentSlot.utilityBill)?.isFailure, isTrue);

      kyc.removeDocument(KycDocumentSlot.bankStatement);
      expect(kyc.application.bankStatement, isNull);
    });

    test('blocks submission until every step is complete', () async {
      expect(kyc.canContinue(KycStep.employment), isFalse);
      expect(await kyc.submit(), KycStatus.unverified);
      expect(repo.submissions, 0);
    });

    test('submits once, then the review verifies and persists', () async {
      fillUsd();
      await kyc.attach(KycDocumentSlot.bankStatement, KycMediaOrigin.files);

      final first = kyc.submit();
      final second = kyc.submit();
      expect(identical(first, second), isTrue, reason: 'idempotent');
      expect(await first, KycStatus.inReview);
      expect(repo.submissions, 1);
      expect(kyc.statusFor(KycFlow.usd), KycStatus.inReview);

      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(kyc.isVerified, isTrue);
      expect(repo.loadStatus(KycFlow.usd), KycStatus.verified);
      expect(kyc.statusFor(KycFlow.gbpEur), KycStatus.unverified);
    });

    test('an unclear selfie fails and can be retaken', () async {
      fillUsd(selfieBytes: 4 * 1024);
      await kyc.attach(KycDocumentSlot.bankStatement, KycMediaOrigin.files);

      expect(await kyc.submit(), KycStatus.failed);
      expect(kyc.submission.isFailure, isTrue);

      kyc.retrySelfie();
      expect(kyc.application.selfie, isNull);
      expect(kyc.submission.isInitial, isTrue);
    });
  });

  group('KYC UI', () {
    testWidgets('USD KYC: forms, camera permission, selfie and success', (
      tester,
    ) async {
      _phoneViewport(tester);
      final prefs = await _prefs();
      final repo = _CountingRepository(prefs);
      await tester.pumpWidget(
        _app(
          prefs: prefs,
          repository: repo,
          media: _FakeMedia(),
          permission: _FakePermission(),
          selfieBytes: 80 * 1024,
        ),
      );
      await tester.pumpAndSettle();

      await _completeUsdForms(tester);

      await _tap(tester, find.byKey(const ValueKey('kyc_take_selfie_btn')));
      expect(find.byType(KycCameraPermissionScreen), findsOneWidget);
      expect(find.text('Camera access'), findsOneWidget);

      await _tap(tester, find.byKey(const ValueKey('kyc_camera_allow_btn')));
      expect(find.byType(KycSelfieCaptureScreen), findsOneWidget);
      expect(find.text('Position your face in the oval'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('kyc_shutter_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      expect(find.byKey(const ValueKey('kyc_uploading_text')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('Thank you!'), findsOneWidget);
      expect(repo.submissions, 1);

      await _tap(tester, find.byKey(const ValueKey('kyc_result_btn')));
      expect(find.text('Start KYC'), findsOneWidget, reason: 'journey closed');

      await tester.pump(const Duration(milliseconds: 400));
      final context = tester.element(find.text('Start KYC'));
      expect(context.read<KycController>().isVerified, isTrue);
    });

    testWidgets('a rejected selfie shows failure and retakes it', (
      tester,
    ) async {
      _phoneViewport(tester);
      final prefs = await _prefs();
      await tester.pumpWidget(
        _app(
          prefs: prefs,
          repository: _CountingRepository(prefs),
          media: _FakeMedia(),
          permission: _FakePermission(current: CameraPermission.granted),
          selfieBytes: 3 * 1024,
        ),
      );
      await tester.pumpAndSettle();
      await _completeUsdForms(tester);

      await _tap(tester, find.byKey(const ValueKey('kyc_take_selfie_btn')));
      expect(
        find.byType(KycCameraPermissionScreen),
        findsNothing,
        reason: 'permission already granted',
      );
      await tester.tap(find.byKey(const ValueKey('kyc_shutter_btn')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Verification failed'), findsOneWidget);
      await _tap(tester, find.byKey(const ValueKey('kyc_result_btn')));
      expect(find.byType(KycSelfieCaptureScreen), findsOneWidget);
    });

    testWidgets('ID details formats MM/YY and flags an expired ID', (
      tester,
    ) async {
      _phoneViewport(tester);
      final prefs = await _prefs();
      await tester.pumpWidget(
        _app(
          prefs: prefs,
          repository: _CountingRepository(prefs),
          media: _FakeMedia(),
          permission: _FakePermission(),
          selfieBytes: 80 * 1024,
          flow: KycFlow.gbpEur,
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.text('Start KYC'));
      context.read<KycController>().start(KycFlow.gbpEur);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const KycIdDetailsScreen()),
      );
      await tester.pumpAndSettle();

      Finder field(String key) => find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(EditableText),
      );

      await tester.enterText(field('kyc_id_number_field'), 'A1234567');
      await tester.enterText(field('kyc_issue_date_field'), '0120');
      await tester.enterText(field('kyc_expiry_date_field'), '0121');
      await tester.pump();

      expect(find.text('01/20'), findsOneWidget);
      expect(find.text('This ID has expired'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('kyc_next_btn')),
          matching: find.text('Next'),
        ),
        findsOneWidget,
      );
      final kyc = context.read<KycController>();
      expect(kyc.canContinue(KycStep.idDetails), isFalse);

      await tester.enterText(field('kyc_expiry_date_field'), '0135');
      await tester.pump();
      expect(find.text('This ID has expired'), findsNothing);
      expect(kyc.canContinue(KycStep.idDetails), isTrue);
    });
  });
}
