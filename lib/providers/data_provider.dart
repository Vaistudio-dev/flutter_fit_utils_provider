import 'dart:async';

import 'package:flutter_fit_events/flutter_fit_events.dart';
import 'package:flutter_fit_utils/flutter_fit_utils.dart';
import 'package:flutter_fit_utils_provider/flutter_fit_utils_provider.dart';

/// Provider containing a single [Modelable] object.
abstract class DataProvider<T extends Modelable> extends FitProvider {
  /// Service of the provider.
  late Service<T> service;

  /// Will create [T] for the user if none is found.
  final bool createIfDontExist;

  /// If set to [True], when creating a new instance, it will automatically be
  /// assigned [userId].
  final bool assignUserIdOnCreate;

  /// If set to [True], when updating a new instance, it will automatically be
  /// assigned [userId].
  final bool assignUserIdOnUpdate;

  /// Factory function to create an instance of [T].
  final T Function() factoryFunc;

  /// Id of the data's owner.
  String userId = "";

  /// Data contained by the provider.
  T? _data;

  /// Returns true if the data is null.
  bool get noData => _data == null;

  /// Data containes by the provider.
  /// Do not use if [noData] is true.
  T get data => _data!;

  /// Data contained by the provider.
  set data(T? newData) => _data = newData;

  /// Creates a new [SingleDataProvider].
  DataProvider(
    Service<T>? service,
    this.factoryFunc, {
    this.createIfDontExist = true,
    this.assignUserIdOnCreate = true,
    this.assignUserIdOnUpdate = true,
  }) {
    if (service != null) {
      this.service = service;
    }
  }

  @override
  Future<void> initialize({String? userId = ""}) async {
    if (initialized) {
      return;
    }

    await service.repository.initialize();

    this.userId = userId ?? "";

    final allData = await service.getAll(userId: userId);
    if (allData.isNotEmpty) {
      data = allData.first;
    } else if (createIfDontExist) {
      T newData = factoryFunc().copyWith(userId: userId) as T;
      newData = newData.copyWith(id: await service.create(newData)) as T;
      data = newData;

      AppEventsDispatcher().publish(DataCreatedEvent(service.repositoryId, data));
    } else {
      data = null;
    }

    initialized = true;
    AppEventsDispatcher().publish(ProviderInitializedEvent(service.repositoryId));
  }

  /// Adds a new instance of [T], [newData], to the repository, and replaces [_data].
  /// If the creation is successful, will return [true] and the assigned id of the instance.
  /// If the creation is not successful, will return [false] and [null].
  /// Note: [userId] is automatically applied to [newData].
  Future<(bool, String?)> createNew(T newData) async {
    if (!isInstanceValid(newData)) {
      AppEventsDispatcher().publish(OperationFailedEvent(OperationType.create, service.repositoryId, newData));
      return (false, null);
    }

    if (assignUserIdOnCreate) {
      newData = newData.copyWith(userId: userId) as T;
    }

    _data = newData.copyWith(id: await service.create(newData)) as T;

    notifyListeners();
    AppEventsDispatcher().publish(DataCreatedEvent(service.repositoryId, _data!));

    return (true, _data!.id);
  }

  /// Updates [_data] inside the repository.
  /// If the creation is sucessful, will return [true]. Otherwise, [false].
  /// Note: [userId] is automatically applied to [_data].
  Future<bool> update() async {
    if (_data == null || !isInstanceValid(_data as T)) {
      return false;
    }

    if (!isInstanceValid(_data!)) {
      AppEventsDispatcher().publish(OperationFailedEvent(OperationType.update, service.repositoryId, _data!));
      return false;
    }

    if (assignUserIdOnUpdate) {
      _data = _data!.copyWith(userId: userId) as T;
    }

    await service.update(_data!);

    notifyListeners();
    AppEventsDispatcher().publish(DataUpdatedEvent(service.repositoryId, _data!));

    return true;
  }

  /// Deletes [_data] from the repository.
  /// If the suppression is sucessful, returns [true]. Otherwise, [false].
  Future<bool> delete() async {
    if (_data == null) {
      AppEventsDispatcher().publish(OperationFailedEvent(OperationType.delete, service.repositoryId, _data!));
      return false;
    }

    await service.delete(_data!);

    notifyListeners();
    AppEventsDispatcher().publish(DataDeletedEvent(service.repositoryId, _data!));

    _data = null;

    return true;
  }

  /// Evaluates if an instance is valid within the context of the provider.
  /// If an instance is invalid, it won't be created or updated.
  bool isInstanceValid(T instance);

  @override
  void destroy() {
    super.destroy();

    _data = null;
    userId = "";

    notifyListeners();
    AppEventsDispatcher().publish(ProviderDestroyedEvent(service.repositoryId));
  }
}
