import 'package:flutter_fit_utils/flutter_fit_utils.dart';

import '../flutter_fit_utils_provider.dart';

/// Provider that contains a list of [Modelable] objects.
abstract class ItemsProvider<T extends Modelable> extends FitProvider {
  final Service<T> _service;

  /// Returns the service of the provider.
  Service<T> getService() => _service;

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
  ItemsProvider(this._service, this.factoryFunc);

  @override
  Future<void> initialize({dynamic data, String userId = ""}) async {
    if (initialized) {
      return;
    }

    await _service.repository.initialize();

    this.userId = userId;

    _data = await _service.getAll(userId: userId);

    initialized = true;
  }

  /// Adds a new instance of [T], [newData], to the repository.
  /// If the creation is sucessful, will return [true] and the assigned id of the instance.
  /// If the creation is not successful, will return [false] and [null].
  ///
  /// Note: [userId] is automatically applied to [newData].
  Future<(bool, String?)> createNew(T newData) async {
    if (!isInstanceValid(newData)) {
      return (false, null);
    }

    newData = newData.copyWith(userId: userId) as T;
    _data.add(
        newData = newData.copyWith(id: await _service.create(newData)) as T);

    notifyListeners();

    return (true, newData.id);
  }

  /// Updates [_data] inside the repository.
  /// If the creation is sucessful, will return [true]. Otherwise, [false].
  ///
  /// Note: [userId] is automatically applied to [existingData].
  Future<bool> update(T existingData) async {
    if (_data.any((element) => element.id == existingData.id) ||
        !isInstanceValid(existingData)) {
      return false;
    }

    existingData = existingData.copyWith(userId: userId) as T;
    _data.replace(existingData);

    await _service.update(existingData);

    notifyListeners();

    return true;
  }

  /// Deletes [toDelete] from the repository.
  /// If the suppression is sucessful, returns [true]. Otherwise, [false].
  Future<bool> delete(T toDelete) async {
    if (toDelete.invalid ||
        !_data.any((element) => element.id == toDelete.id)) {
      return false;
    }

    _data.remove(toDelete);
    await _service.delete(_data as T);

    notifyListeners();

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
  }
}
