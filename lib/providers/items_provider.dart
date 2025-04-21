import 'package:flutter_fit_events/flutter_fit_events.dart';
import 'package:flutter_fit_utils/flutter_fit_utils.dart';

import '../flutter_fit_utils_provider.dart';

/// Provider that contains a list of [Modelable] objects.
abstract class ItemsProvider<T extends Modelable> extends FitProvider {
  /// Service of the provider.
  late Service<T> service;

  /// If set to [True], when creating a new instance, it will automatically be
  /// assigned [userId].
  final bool assignUserIdOnCreate;

  /// If set to [True], when updating a new instance, it will automatically be
  /// assigned [userId].
  final bool assignUserIdOnUpdate;

  /// Factory function to create an instance of [T].
  final T Function() factoryFunc;

  /// User id of the data's owner.
  String userId = "";

  /// List of data contained by the provider.
  List<T> _data = [];

  List<T> get data {
    return _data;
  }

  /// Creates a new [ItemsProvider].
  ItemsProvider(
    Service<T>? service,
    this.factoryFunc, {
    this.assignUserIdOnCreate = true,
    this.assignUserIdOnUpdate = true,
  }) {
    if (service != null) {
      this.service = service;
    }
  }

  @override
  Future<void> initialize({dynamic data, String? userId = ""}) async {
    if (initialized) {
      return;
    }

    await service.repository.initialize();

    this.userId = userId ?? "";

    _data = await service.getAll(userId: userId);

    initialized = true;
    AppEventsDispatcher().publish(ProviderInitializedEvent(service.repositoryId));
  }

  /// Adds a new instance of [T], [newData], to the repository.
  /// If the creation is sucessful, will return [true] and the assigned id of the instance.
  /// If the creation is not successful, will return [false] and [null].
  ///
  /// Note: [userId] is automatically applied to [newData].
  Future<(bool, String?)> createNew(T newData) async {
    if (!isInstanceValid(newData)) {
      AppEventsDispatcher().publish(OperationFailedEvent(OperationType.create, service.repositoryId, newData));
      return (false, null);
    }

    if (assignUserIdOnCreate) {
      newData = newData.copyWith(userId: userId) as T;
    }

    _data.add(newData = newData.copyWith(id: await service.create(newData)) as T);

    notifyListeners();
    AppEventsDispatcher().publish(DataCreatedEvent(service.repositoryId, newData));

    return (true, newData.id);
  }

  /// Updates [_data] inside the repository.
  /// If the creation is sucessful, will return [true]. Otherwise, [false].
  ///
  /// Note: [userId] is automatically applied to [existingData].
  Future<bool> update(T existingData) async {
    if (!_data.any((element) => element.id == existingData.id) || !isInstanceValid(existingData)) {
      AppEventsDispatcher().publish(OperationFailedEvent(OperationType.update, service.repositoryId, existingData));
      return false;
    }

    if (assignUserIdOnUpdate) {
      existingData = existingData.copyWith(userId: userId) as T;
    }

    _data.replace(existingData);

    await service.update(existingData);

    notifyListeners();
    AppEventsDispatcher().publish(DataUpdatedEvent(service.repositoryId, existingData));

    return true;
  }

  /// Deletes [toDelete] from the repository.
  /// If the suppression is sucessful, returns [true]. Otherwise, [false].
  Future<bool> delete(T toDelete) async {
    if (toDelete.invalid || !_data.any((element) => element.id == toDelete.id)) {
      AppEventsDispatcher().publish(OperationFailedEvent(OperationType.delete, service.repositoryId, toDelete));
      return false;
    }

    _data.remove(toDelete);
    await service.delete(toDelete);

    notifyListeners();
    AppEventsDispatcher().publish(DataDeletedEvent(service.repositoryId, toDelete));

    return true;
  }

  /// Evaluates if an instance is valid within the context of the provider.
  /// If an instance is invalid, it won't be created or updated.
  bool isInstanceValid(T instance);

  @override
  void destroy() {
    super.destroy();

    userId = "";
    _data = [];

    notifyListeners();
    AppEventsDispatcher().publish(ProviderDestroyedEvent(service.repositoryId));
  }
}
