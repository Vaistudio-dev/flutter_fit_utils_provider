import 'dart:async';

import 'package:flutter_fit_utils/flutter_fit_utils.dart';
import 'package:flutter_fit_utils_provider/flutter_fit_utils_provider.dart';
import 'package:flutter_fit_utils_provider/invalid_object.dart';

/// Provider containing a single [Modelable] object.
abstract class SingleDataProvider<T extends Modelable> extends FitProvider {
  final Service<T> _service;

  /// Will create [T] for the user if none is found.
  final bool createIfDontExist;

  /// Factory function of [T].
  final T Function()? factoryFunc;

  /// User id of the data's owner.
  String userId = "";

  /// Data contained by the provider.
  Modelable data = const InvalidObject();

  /// Creates a new [SingleDataProvider].
  SingleDataProvider(this._service, {this.createIfDontExist = true, this.factoryFunc});

  @override
  Future<void> initialize({dynamic data, String userId = ""}) async {
    if (initialized) {
      return;
    }

    this.userId = userId;

    final allData = await _service.getAll(userId: userId);
    if (allData.isNotEmpty) {
      data = allData.first;
    }
    else if (createIfDontExist && factoryFunc != null) {
      T newData = factoryFunc!().copyWith(userId: userId) as T;
      newData = newData.copyWith(id: await _service.create(newData)) as T;

      data = newData;
    }
    else {
      data = const InvalidObject();
    }

    initialized  = true;
  }

  /// Adds a new instance of [T], [newData], to the repository, and replaces [data].
  /// If the creation is sucessful, will return [true] and the assigned id of the instance.
  /// If the creation is not successful, will return [false] and [null].
  /// 
  /// Note: [userId] is automatically applied to [newData].
  Future<(bool, String?)> createNew(T newData) async {
    if (!isInstanceValid(newData)) {
      return (false, null);
    }

    newData = newData.copyWith(userId: userId) as T;
    data = newData.copyWith(id: await _service.create(newData));

    notifyListeners();

    return (true, data.id);
  }

  /// Updates [data] inside the repository.
  /// If the creation is sucessful, will return [true]. Otherwise, [false].
  /// 
  /// Note: [userId] is automatically applied to [data].
  Future<bool> update() async {
    if (data is! T || !isInstanceValid(data as T)) {
      return false;
    }

    data = data.copyWith(userId: userId);
    await _service.update(data as T);

    notifyListeners();

    return true;
  }

  /// Deletes [data] from the repository.
  /// If the suppression is sucessful, returns [true]. Otherwise, [false].
  Future<bool> delete() async {
    if (data is! T || data.invalid) {
      return false;
    }

    await _service.delete(data as T);
    notifyListeners();

    return true;
  }

  /// Evaluates if an instance is valid within the context of the provider.
  /// If an instance is invalid, it won't be created or updated.
  bool isInstanceValid(T instance);

  @override
  void destroy() {
    super.destroy();

    data = const InvalidObject();
    userId = "";

    notifyListeners();
  }
}