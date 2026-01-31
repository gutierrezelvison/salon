import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'states/local_auth_state.dart';
import 'states/login_state.dart';

final GetIt _l = GetIt.instance;

Future<void> init() async {

  var sharedPreferences = await SharedPreferences.getInstance();
  _l.registerSingleton(sharedPreferences);

  _l.registerLazySingleton(
        () => LoginState(
      preferences: _l(),
    ),
  );

  _l.registerLazySingleton(
        () => LocalAuthState(
            preferences: _l()
        ),
  );

/*
  if (kIsWeb) {
    _l.registerSingleton<LocalNotifications>(WebLocalNotifications());
  } else {
    _l.registerSingleton<LocalNotifications>(MobileLocalNotifications());
  }

 */
}
