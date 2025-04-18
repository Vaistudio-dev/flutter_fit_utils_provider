import 'dart:async';

import 'package:flutter_fit_events/flutter_fit_events.dart';
import 'package:flutter_fit_utils/flutter_fit_utils.dart';
import 'package:flutter_fit_utils_provider/flutter_fit_utils_provider.dart';
import 'package:flutter_fit_utils_provider/invalid_object.dart';

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

  /// User id of the data's owner.
  String userId = "";

  /// Data contained by the provider.
  Modelable _data = const InvalidObject();

  /// Data contained by the provider.
  T get data {
    if (_data is! T || _data.invalid) {
      return factoryFunc().copyWith(invalid: true) as T;
    }

    return _data as T;
  }

  set data(T data) {
    _data = data;
  }

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
  Future<void> initialize({dynamic data, String? userId = ""}) async {
    if (initialized) {
      return;
    }

    await service.repository.initialize();

    this.userId = userId ?? "";

    final allData = await service.getAll(userId: userId);
    if (allData.isNotEmpty) {
      _data = allData.first;
    } else if (createIfDontExist) {
      T newData = factoryFunc().copyWith(userId: userId) as T;
      newData = newData.copyWith(id: await service.create(newData)) as T;
      _data = newData;

      AppEventsDispatcher().publish(DataCreatedEvent(service.repositoryId, _data));
    } else {
      _data = const InvalidObject();
    }

    initialized = true;
    AppEventsDispatcher().publish(ProviderInitializedEvent(service.repositoryId));
  }

  /// Adds a new instance of [T], [newData], to the repository, and replaces [_data].
  /// If the creation is sucessful, will return [true] and the assigned id of the instance.
  /// If the creation is not successful, will return [false] and [null].
  ///
  /// Note: [userId] is automatically applied to [newData].
  Future<(bool, String?)> createNew(T newData) async {
    if (!isInstanceValid(newData)) {
      return (false, null);
    }

    if (assignUserIdOnCreate) {
      newData = newData.copyWith(userId: userId) as T;
    }

    _data = newData.copyWith(id: await service.create(newData));

    notifyListeners();
    AppEventsDispatcher().publish(DataCreatedEvent(service.repositoryId, _data));

    return (true, _data.id);
  }

  /// Updates [_data] inside the repository.
  /// If the creation is sucessful, will return [true]. Otherwise, [false].
  ///
  /// Note: [userId] is automatically applied to [_data].
  Future<bool> update() async {
    if (_data is! T || !isInstanceValid(_data as T)) {
      return false;
    }

    if (assignUserIdOnUpdate) {
      _data = _data.copyWith(userId: userId);
    }

    await service.update(_data as T);

    notifyListeners();
    AppEventsDispatcher().publish(DataUpdatedEvent(service.repositoryId, _data));

    return true;
  }

  /// Deletes [_data] from the repository.
  /// If the suppression is sucessful, returns [true]. Otherwise, [false].
  Future<bool> delete() async {
    if (_data is! T || _data.invalid) {
      return false;
    }

    await service.delete(_data as T);

    notifyListeners();
    AppEventsDispatcher().publish(DataDeletedEvent(service.repositoryId, _data));

    return true;
  }

  /// Evaluates if an instance is valid within the context of the provider.
  /// If an instance is invalid, it won't be created or updated.
  bool isInstanceValid(T instance);

  @override
  void destroy() {
    super.destroy();

    _data = const InvalidObject();
    userId = "";

    notifyListeners();
    AppEventsDispatcher().publish(ProviderDestroyedEvent(service.repositoryId));
  }
}
