
import 'package:flutter/material.dart';
import '../values/StringApp.dart';

import 'Product.dart';

class Section{
  String title, subtitle;
  Color color;
  List<Product> list;

  Section({required this.title,required this.subtitle, required this.color, required this.list});//required this.list
}

List<Section> sections= [
  Section(
    title: coffeesStr,
    color: Colors.yellow,
    subtitle: "Café 100% puro",
    list: coffeeList,
  ),
  Section(
    title: drinksStr,
    color: Colors.red,
    subtitle: "Bebidas de todos los sabores",
    list: drinkList,
  ),
  Section(
    title: cakesStr,
    color: Colors.blue,
    subtitle: "Deliciosos pasteles",
    list: cakeList,
  ),
  Section(
    title: sandwichesStr,
    color: Colors.purpleAccent,
    subtitle: "Come algo ligero",
    list: sandwichesList,
  ),
];