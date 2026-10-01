import 'package:client/core/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_notifier.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier{
  
  @override
  UserModel? build(){
    return null;
  }

  // FIXED: Added the '?' to allow null values during logout
  void addUser(UserModel? user){
    state = user;
  }
}