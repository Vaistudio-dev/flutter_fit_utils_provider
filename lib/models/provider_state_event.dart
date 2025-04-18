import 'package:flutter_fit_events/flutter_fit_events.dart';

/// Base event for signaling that the state of a provider has changed.
sealed class ProviderStateEvent extends AppEvent {
  final String repositoryId;

  const ProviderStateEvent(this.repositoryId);
}

/// Event that indicates that a provider has finished initializing itself.
class ProviderInitializedEvent extends ProviderStateEvent {
  /// Event that indicates that a provider has finished initializing itself.
  ProviderInitializedEvent(super.repositoryId);
}

/// Event that indicates that a provider has finished destroying itself.
class ProviderDestroyedEvent extends ProviderStateEvent {
  /// Event that indicates that a provider has finished destroying itself.
  ProviderDestroyedEvent(super.repositoryId);
}
