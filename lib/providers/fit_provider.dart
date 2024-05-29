import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Basic data provider.
/// Can managage the initialization status of a provider.
///
/// The [initializationStream] lets listeners know as soon
/// as the [initialize] function is done.
abstract class FitProvider extends ChangeNotifier {
  final _initializationSubject = BehaviorSubject<bool>();

  /// Initialization stream.
  /// Gets updated when [initialized] is changed.
  Stream<bool> get initializationStream => _initializationSubject.stream;

  bool _initialized = false;

  /// Returns [true] if the provider has been initialized.
  bool get initialized => _initialized;
  set initialized(bool value) {
    _initialized = value;
    _initializationSubject.add(value);
  }

  /// Initializes the provider.
  /// Should set [initialized] to [true] at the very end of the
  /// implementation.
  Future<void> initialize({required dynamic data});

  /// Destroys the data and marks the instance as uninitialized.
  @mustCallSuper
  void destroy() {
    initialized = false;
  }

  @override
  void dispose() {
    _initializationSubject.close();
    super.dispose();
  }
}
