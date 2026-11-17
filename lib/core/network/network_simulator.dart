import 'dart:async';

import '../errors/exceptions.dart';

typedef FailurePolicy = bool Function(String operation);

class NetworkSimulator {
  const NetworkSimulator({
    this.latency = const Duration(milliseconds: 1500),
    this.failurePolicy,
  });

  const NetworkSimulator.instant({this.failurePolicy})
    : latency = Duration.zero;

  final Duration latency;
  final FailurePolicy? failurePolicy;

  Future<T> request<T>(
    String operation,
    FutureOr<T> Function() body, {
    Duration? latencyOverride,
  }) async {
    final delay = latency == Duration.zero
        ? Duration.zero
        : (latencyOverride ?? latency);
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (failurePolicy?.call(operation) ?? false) {
      throw NetworkException(
        'Request "$operation" failed. Please try again.',
        'network_error',
      );
    }
    return body();
  }
}
