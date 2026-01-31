
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthState with ChangeNotifier {

  late SharedPreferences _prefs;

  bool _biometricsEnabled = false;
  bool _biometricsAuthorized = false;

  LocalAuthState({
    required SharedPreferences preferences
  }){
    _prefs=preferences;
    biometricState();
  }
  bool get biometricEnabled => _biometricsEnabled;
  bool isBiometricEnabled() => _biometricsEnabled;
  bool isBiometricAuthorized() => _biometricsAuthorized;

  Future<void> setBiometrics(bool action) async {

    print(action);
   _prefs.setBool('biometricsEnabled', action);
    _biometricsEnabled = action;

    notifyListeners();
  }

  void biometricState() async {
    _prefs=await SharedPreferences.getInstance();
    if (_prefs.containsKey('biometricsEnabled')) {
      _biometricsEnabled = _prefs.getBool("biometricsEnabled")!;
      notifyListeners();
    }
  }
  void closeAuth() {
    _biometricsAuthorized = true;
    notifyListeners();
  }
}