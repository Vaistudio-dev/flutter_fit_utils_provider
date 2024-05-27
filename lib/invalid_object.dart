import 'package:flutter_fit_utils/flutter_fit_utils.dart';

/// Represents an invalid instance of a [Modelable] object.
class InvalidObject extends Modelable {
  /// Creates a new invalid object.
  const InvalidObject() : super(invalid: true);

  @override
  Modelable copyWith({String? id, String? userId}) {
    throw UnimplementedError();
  }

  @override
  Model toModel() {
    throw UnimplementedError();
  }
}
