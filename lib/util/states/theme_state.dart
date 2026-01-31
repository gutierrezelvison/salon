import 'package:flutter/material.dart';
import '../Util.dart';
import '../db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState with ChangeNotifier {
  bool _isDarkModeEnabled = false;
  late SharedPreferences _prefs;
  BDConnection bdConnection = BDConnection();
  bool _isLoading = false;

  ThemeData get currentTheme => _isDarkModeEnabled
      ? ThemeData.dark().copyWith(
    primaryColor: Color(int.parse('0xFF${AppData().getCustomThemeData().primaryColor.toString().replaceAll(RegExp(r'[^\d]'), '')}')),
    )
      : _getThemeLight();

  ThemeState() {
    themeState();
  }

  bool get isDarkModeEnabled => _isDarkModeEnabled;

  bool darkModeEnabled() => _isDarkModeEnabled;
  bool isLoading() => _isLoading;

  void setDarkMode(bool b) {
    _isDarkModeEnabled = b;
    _prefs.setBool('isDarkModeEnabled', _isDarkModeEnabled);
    notifyListeners();
  }

  ThemeData _getThemeLight() {
    final theme = ThemeData(
      useMaterial3: true,
      primaryColor: Color(int.parse('0xFF${AppData().getCustomThemeData().primaryColor.toString().replaceAll(RegExp(r'[^\d]'), '')}')),
      colorScheme: ThemeData().colorScheme.copyWith(
        surface: Colors.white,surfaceTint: Colors.white,
        //primary: Colors.blue,
        surfaceContainerLow: Colors.white,

      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: ThemeData().appBarTheme.copyWith(color: Colors.white),
      bottomSheetTheme: ThemeData().bottomSheetTheme.copyWith(backgroundColor: Colors.white),
      cardColor: Colors.white,
      dialogTheme: ThemeData().dialogTheme.copyWith(backgroundColor: Colors.white),
      datePickerTheme: ThemeData().datePickerTheme.copyWith(backgroundColor: Colors.white),
      timePickerTheme: ThemeData().timePickerTheme.copyWith(backgroundColor: Colors.white),
      popupMenuTheme: ThemeData().popupMenuTheme.copyWith(color: Colors.white),

    );

    return theme;
  }

  void themeState() async {
    _isLoading = true;
    notifyListeners();
    _prefs=await SharedPreferences.getInstance();
    final query = await bdConnection.getData(onError: (e){},
        fields: '* ',
        table: 'theme_settings ',
        where: 'id=1',
        order: 'ASC',
        orderBy: 'id',
        groupBy: 'id');
    if(query.isNotEmpty){
      AppData().setCustomThemeData(
          CustomThemeData(
              id: int.parse(query[0]['id']),
              primaryColor: query[0]['primary_color'],
              secondaryColor : query[0]['secondary_color'],
              sideBarColor: query[0]['sidebar_bg_color'],
              sideBarTextColor: query[0]['sidebar_text_color	'],
              topBarTextColor:  query[0]['topbar_text_color']
          )
      );
    }
    if (_prefs.containsKey('isDarkModeEnabled')) {
      _isDarkModeEnabled=_prefs.getBool("isDarkModeEnabled")!;
      _isLoading = false;
      notifyListeners();
    } else {
      _isLoading = false;
      notifyListeners();
    }
  }
}
