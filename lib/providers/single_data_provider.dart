import 'package:flutter_fit_utils/flutter_fit_utils.dart';
import 'package:flutter_fit_utils_provider/flutter_fit_utils_provider.dart';
import 'package:flutter_fit_utils_provider/invalid_object.dart';

/// Provider containing a single [Modelable] object.
abstract class SingleDataProvider<T extends Modelable> extends FitProvider {
  final Service<T> _service;

  /// Will create [T] for the user if none is found.
  final bool createIfDontExist;

  String _userId = "";
  late T data;

  SingleDataProvider(this._service, {this.createIfDontExist = true});

  @override
  Future<void> initialize({dynamic data, String userId = ""}) async {
    if (initialized) {
      return;
    }

    _userId = userId;

    final allData = await _service.getAll(userId: _userId);
    if (allData.isNotEmpty) {
      data = allData.first;
    }
    else if (createIfDontExist) {

    }
    else {
      data = const InvalidObject();
    }

    initialized  = true;
  }
}