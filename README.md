A flutter package to easily create providers of modelable data.
This package is part of the flutter_fit_utils environement. To know about other packages related to flutter_fit_utils, see the diagram below.

![flutter_fit_utils drawio](https://github.com/s0punk/flutter_fit_utils_provider/assets/59456672/74b056f7-f85d-4635-891c-fd9feee99cfb)

## Features

This package lets you use pre-built providers, or custom ones, for your models. These providers then use services to manage your data repositories.

## Getting started

- Go inside your pubspec.yaml file
- Add this line under the dependencies:
```
flutter_fit_utils_provider: ^1.0.0
```
- Get dependencies
```
flutter pub get
```

## Usage

Check out example/main.dart for the complete implementation.

### Creating a provider
Create a class that extends DataProvider or ItemsProvider. Use DataProvider if you want to provide a single modelable. On the contrary, use ItemsProvider if yout want to provide a list of modelables. It's that easy !

```dart
/// Provider for [User] data.
class UserProvider extends DataProvider<User> {
  /// Creates a new [UserProvider].
  UserProvider(super.service, super.factoryFunc);

  @override
  bool isInstanceValid(User instance) {
    /// Implement your logic here...
    return instance.name != "Bob";
  }
}
```

If you need, you can override methods to implement your own logic.

```dart
/// Provider for [User] data.
class UserProvider extends DataProvider<User> {
  /// Creates a new [UserProvider].
  UserProvider(super.service, super.factoryFunc);

  @override
  Future<void> initialize({dynamic data, String userId = ""}) async {
    /// Your own logic here.
  }

  @override
  bool isInstanceValid(User instance) {
    /// Implement your logic here...
    return instance.name != "Bob";
  }
}
```

You can always create a custom provider by inheriting FitProvider or FitFormProvider.

### Waiting for the initialization of your provider
FitProviders have an initialization stream that you can listen to. This way, you can update your UI when your provider is ready.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: context.read<UserProvider>().initializationStream,
      builder: (context, snapshot) {
        if (!context.watch<UserProvider>().initialized) {
          return const CircularProgressIndicator();
        }

        // Show your UI here.
        return const SizedBox.shrink();
      },
    );
  }
}
```

## Additional information

Feel free to [give any feedback](https://github.com/s0punk/flutter_fit_utils_provider/issues) ! This package is also open to contributions.
