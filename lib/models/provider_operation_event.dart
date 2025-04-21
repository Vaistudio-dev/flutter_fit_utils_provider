import 'package:flutter_fit_events/flutter_fit_events.dart';
import 'package:flutter_fit_utils/flutter_fit_utils.dart';

/// Base operation event for providers.
sealed class ProviderOperationEvent extends AppEvent {
  /// Id of the affected data repository.
  final String repositoryId;

  /// Data related to the event.
  final Modelable data;

  /// Base operation event for providers.
  const ProviderOperationEvent(this.repositoryId, this.data, {super.description});
}

/// Event that indicates that a [Modelable] data has been created and pushed
/// inside a [Repository].
class DataCreatedEvent extends ProviderOperationEvent {
  /// Event that indicates that a [Modelable] data has been created and pushed
  /// inside a [Repository].
  DataCreatedEvent(super.repositoryId, super.data) : super(description: "Created ${data.id} inside $repositoryId");
}

/// Event that indicates that a [Modelable] data has been modified and pushed
/// inside a [Repository].
class DataUpdatedEvent extends ProviderOperationEvent {
  /// Event that indicates that a [Modelable] data has been modified and pushed
  /// inside a [Repository].
  DataUpdatedEvent(super.repositoryId, super.data) : super(description: "Updated ${data.id} inside $repositoryId");
}

/// Event that indicates that a [Modelable] data has been deleted from a [Repository].
class DataDeletedEvent extends ProviderOperationEvent {
  /// Event that indicates that a [Modelable] data has been deleted from a [Repository].
  DataDeletedEvent(super.repositoryId, super.data) : super(description: "Deleted ${data.id} inside $repositoryId");
}

/// Event that indicates that a create, update or delete operation has failed.
class OperationFailedEvent extends ProviderOperationEvent {
  /// Failed operation type.
  final OperationType type;

  /// Event that indicates that a create, update or delete operation has failed.
  OperationFailedEvent(this.type, super.repositoryId, super.data) : super(description: "Failed to ${type.name} ${data.id} inside $repositoryId");
}

/// CRUD operations.
enum OperationType {
  /// Create a record.
  create,
  /// Update a record.
  update,
  /// Delete a record.
  delete
}
