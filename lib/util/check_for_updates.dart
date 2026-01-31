import 'dart:convert';
import 'dart:js_interop_unsafe';
import 'package:http/http.dart' as http;
import 'dart:js_interop';

@JS()
external JSObject get globalThis;

void reloadPage() {
  JSObject location = globalThis.getProperty('location'.toJS) as JSObject;
  location.callMethod('reload'.toJS);
}

@JS()
external JSObject get localStorage;

void saveVersion(String version) {
  localStorage.callMethod('setItem'.toJS, 'app_version'.toJS, version.toJS);
}

String? getSavedVersion() {
  JSAny? storedValue = localStorage.callMethod('getItem'.toJS, 'app_version'.toJS);
  return storedValue?.toString();
}


Future<void> checkForUpdate() async {
  try {
    final response = await http.get(Uri.parse('https://peluqueria.elvisongr.com/version.php'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String latestVersion = data['version'];
      String? savedVersion = getSavedVersion();

      // Si la versión guardada no existe o es diferente, recargar una sola vez
      if (savedVersion == null || savedVersion != latestVersion) {
        saveVersion(latestVersion); // Guarda la nueva versión
        reloadPage(); // Recarga solo una vez
      }
    }
  } catch (e) {
    print('Error verificando actualización: $e');
  }
}
