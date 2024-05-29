import 'package:flutter/widgets.dart';
import 'package:flutter_fit_utils/flutter_fit_utils.dart';
import 'package:flutter_fit_utils_provider/flutter_fit_utils_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider(
                FirestoreService<User>("MyFirestoreCollection", User.fromModel),
                () => const User())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

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

/// Example user class.
class User extends Modelable {
  static const String _nameKey = "name";

  /// User's last name.
  final String name;

  /// Creates a new user.
  const User({this.name = "", super.id, super.userId});

  /// Creates an invalid user.
  const User.invalid()
      : name = "",
        super.invalid();

  /// Creates a user from a [Model].
  User.fromModel(super.model)
      : name = model.data[_nameKey].toString(),
        super.fromModel();

  @override
  User copyWith({String? id, String? userId, bool? invalid, String? name}) =>
      User(
        name: name ?? this.name,
        id: id ?? this.id,
        userId: userId ?? this.userId,
      );

  @override
  Model toModel() => Model(
        id: id,
        userId: userId,
        data: {
          _nameKey: name,
        },
      );
}
