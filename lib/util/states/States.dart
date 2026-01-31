import 'dart:convert';

import 'package:flutter/material.dart';
import '../../util/Util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartState with ChangeNotifier{
  static List<dynamic> cart_data =[];
  bool _isStateChanged =false;
  CartState(){
    getPrefs();
  }

  isStateChanged()=> _isStateChanged;
  getCartData()=>cart_data;

  Future<void> setPrefs(BuildContext context, int idProd, String name, int can, double price) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> jsonData = {
      'id': idProd,
      'name': name,
      'quantity': can,
      'price': price,
    };

    if (prefs.containsKey('cart_data')) {
      String? storedJson = prefs.getString('cart_data');
      if (storedJson != null) {
        List<dynamic> items = jsonDecode(storedJson);

        var existingProductIndex = items.indexWhere((element) => element['id'] == idProd);

        if (existingProductIndex != -1) {
          // Si el producto ya existe, actualizamos la cantidad
          items[existingProductIndex]['quantity'] += can;
        } else {
          // Si el producto no existe, lo agregamos a la lista
          items.add(jsonData);
        }

        String updatedJsonString = jsonEncode(items);
        await prefs.setString('cart_data', updatedJsonString);
        _isStateChanged= true;
        notifyListeners();
      }
    } else {
      // Si no hay datos guardados, creamos una nueva lista con el producto y lo guardamos
      List<dynamic> items = [jsonData];
      await prefs.setString('cart_data', jsonEncode(items));
      _isStateChanged = true;
      notifyListeners();
    }

    notifyListeners();
    CustomSnackBar showSnackBar = CustomSnackBar();
    showSnackBar.show(
      context: context,
      msg: 'Se ha agregado el item con éxito',
      icon: Icons.check_circle_outline,
      color: const Color(0xff22d88d),
    );
  }

  Future cleanCart(BuildContext context) async{
    final prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey('cart_data')) {
      prefs.remove('cart_data');
      cart_data.clear();
      _isStateChanged = true;
      notifyListeners();
      CustomSnackBar showSnackBar = CustomSnackBar();
      showSnackBar.show(context: context, msg: 'El carrito se vació correctamente', icon: Icons.check_circle_outline, color: const Color(0xff22d88d));
    }
  }

  Future<void> removeItemFromCart(BuildContext context, int idProd) async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey('cart_data')) {
      String? storedJson = prefs.getString('cart_data');
      if (storedJson != null) {
        List<dynamic> items = jsonDecode(storedJson);

        var existingProductIndex = items.indexWhere((element) => element['id'] == idProd);

        if (existingProductIndex != -1) {
          // Remover el elemento de la lista basado en el índice encontrado
          items.removeAt(existingProductIndex);

          String updatedJsonString = jsonEncode(items);
          await prefs.setString('cart_data', updatedJsonString);

          print('Se ha eliminado el producto del carrito');
        } else {
          print('El producto con ID $idProd no existe en el carrito');
        }
      }
    } else {
      print('No hay elementos en el carrito para eliminar');
    }
    _isStateChanged = true;
    notifyListeners();
    CustomSnackBar showSnackBar = CustomSnackBar();
    showSnackBar.show(
      context: context,
      msg: 'Se ha eliminado el item del carrito',
      icon: Icons.check_circle_outline,
      color: const Color(0xff22d88d),
    );
  }

  Future getPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    if(prefs.containsKey('cart_data')){
      cart_data.clear();
      cart_data = jsonDecode(prefs.getString('cart_data')!);
    }else{
      cart_data = [];
    }
    _isStateChanged = true;
    notifyListeners();
  }
}