import 'package:flutter/widgets.dart';

/// Provider for a form.
/// Supports functionnalities like creating a new object of updating an
/// existing one.
abstract class FormProvider extends ChangeNotifier {
  /// Returns [true] if the instance has been initialized.
  bool initialized = false;

  /// Returns [true] if the provider is in "creation" mode.
  bool creationMode = true;

  /// Returns [true] if at least one bit of data has been changed in the object.
  /// Should be used when [creationMode] is set to [false].
  bool hasBeenModified();

  /// Initialize the provider.
  /// Should set [initialized] to [true] at the very end of the
  /// implementation.
  void initForm(BuildContext context, {String? elementId});

  /// Resets the data and marks the instance as uninitialized.
  @mustCallSuper
  void resetForm() {
    initialized = false;
  }

  /// Creates or update the data inside a repository.
  /// Returns [true] if the creation/update has been validated.
  bool updateOrCreate(BuildContext context);

  /// Creates or update the data inside a repository asynchronusly.
  /// Returns [true] if the creation/update has been validated.
  Future<bool> updateOrCreateAsync(BuildContext context);
}