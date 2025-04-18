import 'package:flutter_fit_events/flutter_fit_events.dart';
import 'package:flutter_fit_utils/flutter_fit_utils.dart';

/// Base operation event for providers.
sealed class ProviderOperationEvent extends AppEvent {
  final String repositoryId;
  final Modelable data;

  const ProviderOperationEvent(this.repositoryId, this.data);
}

/// Event that indicates that a [Modelable] data has been created and pushed
/// inside a [Repository].
class DataCreatedEvent extends ProviderOperationEvent {
  /// Event that indicates that a [Modelable] data has been created and pushed
  /// inside a [Repository].
  const DataCreatedEvent(super.repositoryId, super.data);
}

/// Event that indicates that a [Modelable] data has been modified and pushed
/// inside a [Repository].
class DataUpdatedEvent extends ProviderOperationEvent {
  /// Event that indicates that a [Modelable] data has been modified and pushed
  /// inside a [Repository].
  const DataUpdatedEvent(super.repositoryId, super.data);
}

/// Event that indicates that a [Modelable] data has been deleted from a [Repository].
class DataDeletedEvent extends ProviderOperationEvent {
  /// Event that indicates that a [Modelable] data has been deleted from a [Repository].
  const DataDeletedEvent(super.repositoryId, super.data);
}
