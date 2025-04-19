import 'package:flutter_fit_events/flutter_fit_events.dart';

/// Base event for signaling that the state of a provider has changed.
sealed class ProviderStateEvent extends AppEvent {
  /// Id of the affected data repository.
  final String repositoryId;

  /// Base event for signaling that the state of a provider has changed.
  const ProviderStateEvent(this.repositoryId, {super.description});
}

/// Event that indicates that a provider has finished initializing itself.
class ProviderInitializedEvent extends ProviderStateEvent {
  /// Event that indicates that a provider has finished initializing itself.
  ProviderInitializedEvent(super.repositoryId) : super(description: "Initialized $repositoryId");
}

/// Event that indicates that a provider has finished destroying itself.
class ProviderDestroyedEvent extends ProviderStateEvent {
  /// Event that indicates that a provider has finished destroying itself.
  ProviderDestroyedEvent(super.repositoryId) : super(description: "Destroyed $repositoryId");
}
