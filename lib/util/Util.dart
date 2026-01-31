
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:excel/excel.dart' as ex;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:printing/printing.dart';
import 'package:salon/Widgets/WebComponents/Header/Header.dart';
import 'package:salon/util/db_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../values/ResponsiveApp.dart';
import 'package:dropdown_button2/src/dropdown_button2.dart';
import 'package:file_selector/file_selector.dart';
//import 'dart:html' as html;


import 'SizingInfo.dart';

int daysInMonth(int month){
  var now = DateTime.now();

  var lastDateTime= (month<12)?
  DateTime(now.year,month + 1,0):DateTime(now.year+1,1,0);
  return lastDateTime.day;
}

Size displaySize(BuildContext context) {
  // debugPrint('Size = ' + MediaQuery.of(context).size.toString());
  return MediaQuery.of(context).size;
}

double displayHeight(BuildContext context) {
  // debugPrint('Height = ' + displaySize(context).height.toString());
  return displaySize(context).height;
}

double displayWidth(BuildContext context) {
  //debugPrint('Width = ' + displaySize(context).width.toString());
  return displaySize(context).width;
}

String hashPassword(String password) {
  var bytes = utf8.encode(password); // Convierte la contraseña en bytes
  var digest = sha256.convert(bytes); // Aplica el cifrado SHA-256
  return digest.toString(); // Retorna el resultado como una cadena hexadecimal
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height + 20);
    path.quadraticBezierTo(
        size.width, size.height + 20, size.width, size.height + 20);
    path.lineTo(size.width - 50, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}


NumberFormat numberFormat = NumberFormat('#,###.##', 'en_Us');

class AppData{
  static String? view;
  static String? logo;
  static String? companyName;
  static DateTime? selectedDateTime;
  static int? selectedChair;
  static int? catId;
  static Bookings? bookings;
  static BookingItem? bookingItem;
  static double? subtotal;
  static double? total;
  static double? totalPagar;
  static double? itbis;
  static PaymentMethod? paymentMethod;

  static Taxes taxes = Taxes();
  static User userData = User();
  static Company companyData = Company();
  static List<LevelPermission> currentLevelPermission = [];
  static CashRegister cashData = CashRegister();
  static CustomThemeData customThemeData = CustomThemeData();
  static bool autoPrintEnabled = false;
  static bool printCopy = false;
  static dynamic companyLogo;
  static List<dynamic>? moduleListData;

  AppData(){
    getAutoPrintStatus();
  }


  setModuleListData(List<dynamic>? data) => moduleListData = data;
  getModuleListData() => moduleListData;

  setAutoPrintEnabled(bool v) async{
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setBool('autoPrintEnabled', v);
    autoPrintEnabled = v;
  }
  getAutoPrintStatus() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (_prefs.containsKey('autoPrintEnabled')) {
      autoPrintEnabled = _prefs.getBool("autoPrintEnabled")!;
    }
  }
  getAutoPrintEnabled()=>autoPrintEnabled;

  setCurrentLevelPermission(List<LevelPermission> data) => currentLevelPermission = data;
  getCurrentLevelPermission() => currentLevelPermission;
  cleanCurrentLevelPermission() => currentLevelPermission.clear();

  setPrintCopyEnabled(bool v) => printCopy = v;
  getPrintCopyEnabled() => printCopy;

  getPaymentMethod() => paymentMethod;
  setPaymentMethod(PaymentMethod v) => paymentMethod = v;
  getItbis()=>itbis;
  setItbis(double v)=>itbis = v;
  getTotal()=>total;
  getTotalPagar()=>totalPagar;
  setTotal(double v)=>total = v;
  setTotalPagar(double v)=>totalPagar = v;
  getSubTotal()=>subtotal;
  setSubTotal(double v)=>subtotal = v;
  getView()=>view;
  setView(String v)=>view = v;
  getLogo()=>logo??'null';
  setLogo(String v)=>logo = v;
  getCompanyName()=>companyName??'null';
  setCompanyName(String v)=>companyName = v;
  getCat()=>catId;
  setCat(int? v)=>catId = v;
  getBooking()=>bookings;
  setBooking(Bookings v)=>bookings = v;
  getBookingItem()=>bookingItem;
  setBookingItem(BookingItem v)=>bookingItem = v;
  getDateTimeSelected()=>selectedDateTime;
  setDatetimeSelected(DateTime v)=>selectedDateTime = v;
  getChairSelected()=>selectedChair;
  setChairSelected(int v)=>selectedChair = v;

  setCustomThemeData(CustomThemeData data) => customThemeData = data;
  getCustomThemeData() => customThemeData;

  setCash(CashRegister data) => cashData = data;
  getCash() => cashData;

  setUserData(User data) => userData = data;
  getUserData() => userData;

  setCompanyData(Company data) => companyData = data;
  getCompanyData() => companyData;

  setTaxData(Taxes data) => taxes = data;
  getTaxData() => taxes;

  setCompanyLogo(ImageProvider<Object> image)=>companyLogo = image;
  getCompanyLogo()=>companyLogo;
  Future loadImageInitial() async {
    try {
      companyLogo = getCompanyData().logo != 'null'
          ? await flutterImageProvider(
          NetworkImage("${getCompanyData().logo}"))
          : await flutterImageProvider(
          const AssetImage('assets/images/vendo_logo.png'));


      if (kDebugMode) {
        print("****OK****");
      }
    } catch (e) {

      if (kDebugMode) {
        print("****ERROR loadImage: $e****");
      }
      return;
    }
  }
}

class CustomThemeData{
  int? id;
  String? primaryColor;
  String? secondaryColor;
  String? sideBarColor;
  String? sideBarTextColor;
  String? topBarTextColor;

  CustomThemeData({this.id, this.primaryColor, this.secondaryColor, this.sideBarColor, this.sideBarTextColor, this.topBarTextColor});
}

class CartItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  CartItem({required this.id, required this.name, required this.price, this.quantity = 1});
}

class Questions{
  int? user_id;
  String? question_1;
  String? question_2;
  String? question_3;
  String? response_1;
  String? response_2;
  String? response_3;

  Questions({this.user_id, this.question_1,this.question_2, this.question_3, this.response_1, this.response_2, this.response_3});
}

class User{
  int? id=0;
  int? group_id=0;
  int? rol_id=0;
  double? comission=0;
  String? group_name='';
  String? rol_name='';
  String? name='';
  String? email='';
  String? calling_code= '';
  String? mobile = '';
  String? mobile_verified= '';
  String? password = '';
  ImageFiles? image;
  String? remember_token='';
  int? security_questions;
  int? default_pass=0;
  int? new_customer=0;
  String? created_at='';
  int? booking_completed_count=0;
  int? booking_pending_count=0;
  int? booking_in_progress_count=0;
  int? booking_approved_count=0;
  int? booking_canceled_count=0;

  User({this.id, this.group_id,this.new_customer,this.comission,this.rol_id,this.rol_name,this.group_name,this.password,this.calling_code,this.email,this.image,
  this.mobile,this.mobile_verified,this.name,this.remember_token, this.created_at,this.booking_approved_count,
  this.booking_canceled_count,this.booking_completed_count,this.default_pass,this.booking_in_progress_count, this.security_questions,this.booking_pending_count});
}
class LevelPermission{
  int? module_id;
  int? permission_id;
  int? has_permission;
  String? permission_name;
  String? module_display_name;
  String? module_name;

  LevelPermission({this.module_name, this.module_id, this.has_permission,this.permission_id, this.permission_name, this.module_display_name});
}

class CashRegister{
  int? id;
  int? user_id;
  String? name;
  int? number;

  CashRegister({this.number, this.name, this.id, this.user_id});
}

class Batch{
  int? id;
  int? product_id;
  String? batch;
  String? quantity;
  String? cost;
  String? status;
  String? expiration_date;
  String? description;

  Batch({this.id, this.product_id, this.batch, this.quantity, this.expiration_date, this.cost, this.status, this.description});
}

class InventoryMovement{
  int?      id;
  Service?  product;
  User?     user;
  double?   quantity;
  String?   movement;
  double?   cost;
  double?   tax;
  double?   total;
  Batch?   batch;
  String? expiration_date;
  String?   concept;
  String?   description;
  DateTime? created_at;

  InventoryMovement({this.batch,this.total,this.tax, this.concept, this.created_at, this.description, this.expiration_date, this.id ,this.movement, this.cost, this.product, this.quantity, this.user});
}

class CashCount{
  int? id;
  int? cash_id;
  double? sales_amount;
  double? initial_cash_amount;
  double? cash;
  double? check;
  double? credit_card;
  double? debit_card;
  double? transfer;
  double? other;
  double? discounts;
  double? credit_sales;
  double? system_final_cash;
  double? real_final_cash;
  double? diference;
  double? extraordinary_outflow;
  String? comments;
  String? open_date;
  String? close_date;
  int? admin_open_id;
  int? admin_close_id;
  String? status;

  CashCount({this.cash,this.admin_close_id, this.admin_open_id, this.cash_id,this.real_final_cash, this.system_final_cash, this.check, this.close_date, this.comments ,this.credit_card ,this.credit_sales ,this.debit_card ,this.diference, this.discounts, this.extraordinary_outflow, this.id, this.initial_cash_amount ,this.open_date ,this.other ,this.sales_amount,this.status, this.transfer});
}

class Invoice{
  int? id;
  String? invoice_number;
  int? booking_id;
  DateTime? date_time;
  int? customer_id;
  String? invoice_type;
  String? customer_rnc;
  String? social_reason;
  int? user_id;
  int? cash_id;
  String? order_type;
  String? payment_method;
  String? payment_way;
  double? discount_percent;
  double? discount_total;
  double? total_taxes;
  double? subtotal;
  double? total_amount;
  double? total_card;
  double? total_transfers;
  double? total_cash;
  double? total_deposit;
  double? total_check;
  String? payment_status;
  List<Map<String,dynamic>>? invoiceDetail;

  Invoice({this.invoiceDetail,this.booking_id, this.cash_id,this.total_deposit,this.total_check, this.total_transfers, this.customer_id, this.customer_rnc, this.date_time ,this.discount_percent, this.discount_total, this.id, this.invoice_number ,this.invoice_type ,this.order_type, this.payment_method, this.payment_status, this.payment_way, this.social_reason, this.subtotal, this.total_amount ,this.total_taxes, this.user_id, this.total_card, this.total_cash});
}

class Categorie{
  int? id;
  String? name;
  String? slug;
  ImageFiles? image;
  String? status;
  String? createdAt;
  String? updatedAt;

  Categorie({this.id,this.name,this.slug,this.image,this.status,this.createdAt,this.updatedAt});
}

class Service{
  int? id;
  String? type;
  String? name;
  String? slug;
  ImageFiles? image;
  String? description;
  String? price;
  String? commission;
  String? time;
  String? time_type;
  String? discount;
  String? discount_type;
  String? category_id;
  String? category_name;
  String? location_name;
  String? location_id;
  int? apply_taxes;
  int? tax_id;
  int? quantity;
  String? status;
  String? createdAt;
  String? updatedAt;

  Service({this.id,this.type,this.commission,this.quantity,this.apply_taxes,this.tax_id,this.name,this.slug,this.category_name,this.location_name,
   this.description,this.discount,this.discount_type,this.category_id,
   this.location_id, this.price,this.time,this.time_type,
  this.image,this.status,this.createdAt,this.updatedAt});
}

class BookingTime{
  int? id;
  String? day;
  String? start_time;
  String? end_time;
  String? multiple_booking;
  String? max_booking;
  String? status;
  String? slot_duration;
  String? created_at;
  String? updated_at;

  BookingTime({this.id,this.day,this.start_time,this.end_time,this.multiple_booking,
    this.max_booking,this.status, this.slot_duration, this.created_at, this.updated_at});
}

class PaymentMethod{
  int? id;
  String? paypal_client_id;
  String? paypal_secret;
  String? stripe_client_id;
  String? stripe_secret;
  String? stripe_webhook_secret;
  String? stripe_status;
  String? paypal_status;
  String? paypal_mode;
  String? offline_payment;
  String? razorpay_key;
  String? razorpay_secret;
  String? razorpay_status;
  String? created_at;
  String? updated_at;

  PaymentMethod({
    this.id,this.offline_payment,this.paypal_client_id,this.paypal_mode,this.paypal_secret,
    this.paypal_status,this.razorpay_key, this.razorpay_secret, this.razorpay_status,
    this.stripe_client_id, this.stripe_secret, this.stripe_status, this.stripe_webhook_secret,
    this.created_at, this.updated_at});
}

class WidgetState{
  static String _widget='';

  WidgetState();

  getState()=>_widget;

  setWidget(String w)=>_widget=w;
}

class CustomSnackBar{
  CustomSnackBar();

  OverlayEntry? overlayEntry;

  void show({required BuildContext context, required String msg, required IconData icon,required Color color}) {
    OverlayState overlayState = Overlay.of(context);
    ResponsiveApp responsiveApp = ResponsiveApp(context);
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: 20, // Posición vertical personalizada
        right: 20,
        width: displayWidth(context),
        child: SafeArea(
          child: Material(
            color: Colors.transparent,
            child: AnimationLimiter(
              child: ListView(
                shrinkWrap: true,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: isMobile(context)? displayWidth(context)*0.90: responsiveApp.setWidth(300),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(responsiveApp.setWidth(8)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: responsiveApp.setHeight(15), horizontal: responsiveApp.setWidth(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon,
                              size: 50,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 20,),
                            Expanded(
                              child: Text(msg,
                                style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                overlayEntry!.remove();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry!);

    // Después de un cierto tiempo, elimina el Snackbar personalizado
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry!.remove();
    });
  }
}

class Bookings{
  int? id;
  int? employee_id;
  int?    user_id;
  String? date_time;
  int? chair_id;
  String? status;
  String? payment_gateway;
  double? original_amount;
  double? discount;
  double? discount_percent;
  String? tax_name;
  double? tax_percent;
  double? tax_amount;
  double? amount_to_pay;
  String? payment_status;
  String? source;
  String? additional_notes;
  String? created_at;
  String? updated_at;

  Bookings(
      {this.user_id,
      this.employee_id,
      this.chair_id,
      this.updated_at,
      this.created_at,
      this.additional_notes,
      this.source,
      this.payment_status,
      this.amount_to_pay,
      this.tax_amount,
      this.tax_percent,
      this.tax_name,
      this.discount_percent,
      this.discount,
      this.original_amount,
      this.payment_gateway,
      this.status,
      this.date_time,
      this.id});
}

class BookingItem{
  int? id;
  int? booking_id;
  int? business_service_id;
  int? quantity;
  int? chair_id;
  double? unit_price;
  double? amount;
  double? discount;
  String? discount_type;
  String? employee_name;
  String? type;
  String? service_name;
  String? updated_at;
  String? created_at;

  BookingItem(
      {this.id,
      this.created_at,
      this.updated_at,
      this.chair_id,
        this.type,
      this.employee_name,
      this.service_name,
      this.amount,
      this.discount,
      this.discount_type,
      this.booking_id,
      this.business_service_id,
      this.quantity,
      this.unit_price});
}

class BookingList {
  BookingItem bookingItem;
  Bookings    bookings;
  User?       user;
  Service?    service;
  User?     employee;

  BookingList({this.employee,this.service, required this.bookings, required this.bookingItem, this.user});
}

class Sucursal {
  int           id;
  String        name;
  String        created_at;
  String        updated_at;

  Sucursal({required this.id, required this.name, required this.created_at, required this.updated_at});
}

class Roles{
  int? id;
  String? name;
  String? display_name;
  String? description;
  int? member_count;
  String? created_at;
  String? updated_at;

  Roles({this.name,this.created_at,this.description, this.display_name, this.member_count, this.id, this.updated_at});
}

class EmployeeGroups{
  int? id;
  String? name;
  String? status;
  String? created_at;
  String? updated_at;

  EmployeeGroups({this.updated_at, this.id, this.created_at, this.name, this.status});
}

class Company{
  int? id;
  String? company_name;
  String? company_email;
  String? company_phone;
  ImageFiles? logo;
  String? address;
  String? date_format;
  String? time_format;
  String? website;
  String? timezone;
  String? locale;
  String? latitude;
  String? longitude;
  String? currency_id;
  String? created_at;
  String? updated_at;
  String? purchase_code;
  String? supported_until;
  String? cash_time_control_status;

  Company({this.id,this.address, this.cash_time_control_status,this.company_email, this.company_name, this.company_phone, this.created_at,
  this.currency_id, this.date_format, this.latitude, this.locale, this.logo, this.longitude, this.purchase_code,
  this.supported_until, this.time_format, this.timezone, this.updated_at, this.website});
}

class Taxes{
  int? id;
  String? tax_name;
  double? percent;
  String? status;
  String? created_at;
  String? updated_at;

  Taxes({this.id, this.tax_name, this.percent, this.status,this.created_at, this.updated_at});
}

class InvoiceDetail{
  int? invoice_id;
  int? booking_item_id;
  Service? service;
  User? employee;
  double? quantity;
  double? price;
  double? discount;
  double? tax;
  double? total;

  InvoiceDetail({this.invoice_id,this.discount,this.booking_item_id,this.employee, this.price, this.service, this.quantity, this.tax, this.total});

  Map<String, dynamic> toJson() {
    return {
      'product_id'  : service!.id!,
      'type'  : service!.type!,
      'employee_id'  : employee!.id!,
      'booking_item_id'  : booking_item_id,
      'quantity'    : quantity,
      'price'       : price,
      'discount'         : discount,
      'tax'         : tax,
      'total'       : total,
    };
  }
}

class Currencies{
  int? id;
  String? currency_name;
  String? currency_symbol;
  String? currency_code;
  String? created_at;
  String? updated_at;

  Currencies({this.id, this.currency_name, this.currency_symbol, this.currency_code,this.created_at, this.updated_at});
}

class PermissionRole{
  int? module_id;
  int? permission_id;
  int? role_id;
  String? permission_name;
  String? module_display_name;
  String? module_name;

  PermissionRole({this.module_name, this.module_id, this.role_id,this.permission_id, this.permission_name, this.module_display_name});
}

class CarrouselImages{
  int? id;
  ImageFiles? file_name;
  String? created_at;
  String? updated_at;

  CarrouselImages({this.id,this.file_name, this.created_at, this.updated_at});
}

class Chairs{
  int? chair_id;
  int? employee_id;
  String? chair_name;
  String? status;
  String? color;
  String? employee_name;
  String? employee_image;

  Chairs({this.chair_id,this.status, this.color,this.employee_id, this.chair_name, this.employee_name,this.employee_image});
}

Widget texto({required String text, TextAlign? alignment, double? size,Color? color,String? fontFamily, FontWeight? fontWeight}){

  return Text(text,
    textAlign: alignment,
    style: TextStyle(
    color: color,
    fontSize: size,
    fontFamily: fontFamily,
    fontWeight: fontWeight,
    ),
    );
}

void warningMsg({required BuildContext context, required String mainMsg, required String msg, IconData? icon,
  required String okBtnText, String? cancelBtnText, String? alternateBtnText, required VoidCallback okBtn,
  VoidCallback? cancelBtn,VoidCallback? alternateBtn}){
  ResponsiveApp responsiveApp = ResponsiveApp(context);
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: const Icon(Icons.close_rounded,color: Colors.grey,),
                ),
              ],
            ),
            Icon(icon??Icons.warning_rounded,color: const Color(0xffffc44e),
              size: responsiveApp.setWidth(70),
            ),
            SizedBox(height: responsiveApp.setHeight(20),),
            texto(
              text:mainMsg,
              size: responsiveApp.setSP(14),
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              //color: Colors.black87
            ),
            SizedBox(height: responsiveApp.setHeight(10),),
            texto(
              text:msg,
              alignment: TextAlign.center,
              size: responsiveApp.setSP(12),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ],
        ),
        actions: <Widget>[
          if(alternateBtn!=null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: alternateBtn,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 100),
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.green,
                    ),
                    child: Center(child: Text(alternateBtnText??'', style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          SizedBox(height: responsiveApp.setHeight(10),),
          if(cancelBtn!=null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  autofocus: true,
                  onTap: cancelBtn,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 100),
                    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: const Color(0xff6C9BD2),
                    ),
                    child: Center(child: Text(cancelBtnText??'', style: const TextStyle(color: Colors.white))),
                  ),
                ),
              ],
            ),
          SizedBox(height: responsiveApp.setHeight(10),),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: okBtn,
                child: Container(
                  constraints: BoxConstraints(minWidth: 100),
                  padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: const Color(0xffD3D3D3).withOpacity(0.4),
                  ),
                  child: Center(child: Text(okBtnText, style: const TextStyle(color: Colors.grey))),
                ),
              ),
            ],
          ),
        ],
      )
  );
}

Widget userImage({BoxShape? shape, double? width, required double height, required Widget image,Color? shadowColor,
  Color? color, BorderRadius? borderRadius}){
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: borderRadius,
      boxShadow: [
        BoxShadow(
          color: shadowColor??Colors.transparent,
          blurRadius: 3,
          spreadRadius: -1,
          offset: const Offset(-1,2),
        )
      ],
    ),
    child: ClipRRect(
        borderRadius: borderRadius??BorderRadius.circular(0),
        child: image,
    ),
  );
}

Widget customDropDown({required BuildContext context,required TextEditingController searchController, IconData? hintIcon, double? hintIconSize, Color? hintIconColor,
  String? hintText, double? hintTextSize, Color? hintTextColor, required List<String> items, double? itemTexSize,
  Color? itemTextColor, String? value, required dynamic Function(dynamic) onChanged, IconData? iconStyle, Color? iconStyleColor,
  double? iconStyleSize,required double searchInnerWidgetHeight,
}){
  return Padding(
    padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
    child: Row(
      children: [
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,

              hint: Row(
                children: [
                  Icon(
                    hintIcon?? Icons.list,
                    size: hintIconSize?? 25,
                    color: hintIconColor?? Colors.grey,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: Text(
                      hintText??'Select Item',
                      style: TextStyle(
                        fontSize: hintIconSize?? 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).hintColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              items: items
                  .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: itemTexSize??14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
                  .toList(),
              value: value,
              onChanged: onChanged,
              buttonStyleData: ButtonStyleData(
                height: 50,
                width: 160,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                  border: Border.all(
                    color: Colors.black26,
                  ),
                  color: Theme.of(context).cardColor,
                ),
                elevation: 0,
              ),
              iconStyleData: IconStyleData(
                icon: Icon(
                  iconStyle??Icons.arrow_forward_ios_outlined,
                ),
                iconSize: iconStyleSize??15,
                iconEnabledColor: Colors.blueGrey,
                iconDisabledColor: Colors.grey,
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 400,
                padding: null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Theme.of(context).cardColor,
                ),
                elevation: 2,
                offset: const Offset(-20, 0),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(40),
                  thickness: MaterialStateProperty.all<double>(6),
                  thumbVisibility: MaterialStateProperty.all<bool>(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                height: 40,
                padding: EdgeInsets.only(left: 14, right: 14),
              ),
              dropdownSearchData: DropdownSearchData(
                searchController: searchController,
                searchInnerWidgetHeight: searchInnerWidgetHeight,
                searchInnerWidget: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          cursorColor: Colors.black,
                          controller: searchController,
                          decoration: const InputDecoration(
                              hintText: 'Buscar aqui...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black)
                              ),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red,))),
                        ),
                      ),
                    ]
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget customDropDownButton({required String value, required ValueChanged<String?>? onChanged, required List<DropdownMenuItem<String>>? items}){
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
    decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        border: const Border.fromBorderSide(BorderSide(color: Colors.grey,)),
        borderRadius: BorderRadius.circular(15)),
    child: Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            onChanged: onChanged,
            items: items,
            // add extra sugar..
            icon: const Icon(Icons.arrow_drop_down_rounded),
            iconSize: 42,
            underline: const SizedBox(),
          ),
        ),
      ],
    ),
  );
}

final phoneFormatter = MaskTextInputFormatter(
  mask: '(###) ###-####',
  filter: {"#": RegExp(r'[0-9]')},
);

Widget field({required BuildContext context,int? minLines, int? maxLength, int? maxLines,String? initialValue, VoidCallback? onEditingComplete,void Function(String?)? onSaved,void Function(String)? onFieldSubmitted,void Function(String)? onChanged,String? Function(String?)? validator, Widget? suffix, bool? enabled,bool? obscureText,bool? readOnly, TextEditingController? controller, required String label, String? hint, required TextInputType keyboardType, VoidCallback? onTap}){
  ResponsiveApp responsiveApp = ResponsiveApp(context);
  return Padding(
    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
    child: Row(
        children: [
          Expanded(
            child: TextFormField(
              validator: (value) {
                if (value != null && value.trim().isEmpty) {
                  return 'Este campo no puede estar vacío';
                }
                return null;
              },
              //cursorColor: Colors.black,
              maxLength: maxLength,
              minLines: minLines,
              onSaved: onSaved,
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              inputFormatters: keyboardType==TextInputType.number?[FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),]:keyboardType==TextInputType.phone?[phoneFormatter]:null,
              enabled: enabled??true,
              readOnly: readOnly??false,
              obscureText: obscureText??false,
              initialValue: initialValue,
              onTap: onTap,
              onFieldSubmitted: onFieldSubmitted,
              onEditingComplete: onEditingComplete,
              onChanged: onChanged,
              decoration: InputDecoration(
                  suffix: suffix??const SizedBox(),
                  labelText: label,
                  labelStyle: const TextStyle(color: Color(0xff6C9BD2)),
                  hintText: hint??'',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff6C9BD2)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)
                  ),
                  focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xff6C9BD2))
                  ),
                  errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red,))),
            ),
          ),
        ]
    ),
  );
}

Widget customDropDownField({required BuildContext context,String? initialValue,void Function(String)? onChanged, required List<String> options, void Function(String)? onSelected, String? label, TextEditingController? controller, String? hint}){
  ResponsiveApp responsiveApp = ResponsiveApp(context);
  return  Padding(
    padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
    child: Row(
      children: [
        Expanded(
          child: // Autocomplete
          Autocomplete<String>(
            initialValue: TextEditingValue(text: initialValue??''),
            optionsBuilder: (TextEditingValue textEditingValue) {
              // Filtrar las opciones basadas en el texto ingresado
              if (textEditingValue.text.isEmpty) {
                return options;
              }
              return options
                  .where((option) => option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()))
                  .toList();
            },
            onSelected: onSelected,
            fieldViewBuilder: (BuildContext context,
                TextEditingController fieldTextEditingController,
                FocusNode fieldFocusNode,
                VoidCallback onFieldSubmitted) {
              return TextFormField(
                controller: controller??fieldTextEditingController,
                focusNode: fieldFocusNode,
                decoration: InputDecoration(
                    labelText: label?? 'Seleccionar opción o escribir',
                    isDense: false,
                    border: const OutlineInputBorder(
                      //borderSide: BorderSide(color: const Color(0xff6C9BD2)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      //borderSide: BorderSide(color: Colors.grey)
                    ),
                    focusedBorder: const OutlineInputBorder(
                      //borderSide: BorderSide(color: const Color(0xff6C9BD2))
                    ),
                    errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red,))
                ),
                onChanged: onChanged,
              );
            },
            optionsViewBuilder: (BuildContext context,
                AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: SizedBox(
                    height: responsiveApp.setHeight(200),
                    width: responsiveApp.setWidth(200),
                    child: ListView.builder(
                      itemCount: options.length,
                      itemBuilder: (BuildContext context, int index) {
                        final option = options.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(option),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class RealTimeClockScreen extends StatefulWidget {
  const RealTimeClockScreen({super.key, this.textSize});

  @override
  _RealTimeClockScreenState createState() => _RealTimeClockScreenState();

  final double? textSize;
}

class _RealTimeClockScreenState extends State<RealTimeClockScreen> {
  late String currentTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    // Inicializar la hora actual
    currentTime = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());

    // Configurar un Timer para actualizar la hora cada segundo
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancelar el Timer cuando se desmonta el Widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: texto(text: currentTime, size: widget.textSize??14),
    );
  }
}

class FileManager{
  // Abrir un solo archivo
  abreArchivo(Function(dynamic) result)async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);

    result(await file!.readAsBytes());
  }
// Abrir varios archivos
  abreArchivos(Function(dynamic) result)async {
    final typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'png']);
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    result(files);
  }
/*
// Guardar el archivo
  final file = await getSavePath(suggestedName: 'mi_archivo.txt');
  if (file != null) {

  }

 */
}
/*
class StartFilePicker {

  StartFilePicker();

  startFilePicker(Function(dynamic) result) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files!.length == 1) {
        final file = files[0];
        html.FileReader reader =  html.FileReader();

        reader.onLoadEnd.listen((e) {

          result({
            'bytes': reader.result as Uint8List
          });
        });

        reader.onError.listen((fileEvent) {
          print("Some Error occured while reading the file");
          result('error');
        });

        reader.readAsArrayBuffer(file);
      }
    });
  }
}

 */

void viewWidget(BuildContext context,Widget widget, VoidCallback onTap){
  ResponsiveApp responsiveApp = ResponsiveApp(context);
  if(isMobile(context)) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }else{
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                  onTap: onTap,
                  child: Icon(Icons.close_rounded, color: Colors.grey,)
              ),
            ],
          ),
          content: Container(
              width: isLandscape(context)? displayWidth(context)*0.5:displayWidth(context)*0.8,
              height: displayHeight(context)*0.8,
              child: widget),
        )
    );
  }
}
/*

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
        this.address,
        this.port,
        this.state,
        this.vendorId,
        this.productId,
        this.typePrinter = PrinterType.bluetooth,
        this.isBle = false});

  // Convierte el objeto a JSON
  Map<String, dynamic> toJson() => {
    'deviceName':deviceName,
    'address':address,
    'port':port,
    'state':state,
    'vendorId':vendorId,
    'productId':productId,
    'typePrinter':typePrinter.toString(),
    'isBle':isBle
  };

  // Crea el objeto desde JSON
  factory BluetoothPrinter.fromJson(Map<String, dynamic> json) {
    return BluetoothPrinter(
        deviceName:json['deviceName'],
        address:json['address'],
        port:json['port'],
        state:json['state'],
        vendorId:json['vendorId'],
        productId:json['productId'],
        typePrinter: PrinterType.values.firstWhere((e) => e.toString().split('.').last == json['typePrinter'].replaceAll("'", "").split('.').last),
        isBle:json['isBle']
    );
  }
}

 */
Widget customSwitch({required BuildContext context,required Widget label,required bool active,required VoidCallback onTap}){
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      label,
      InkWell(
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.decelerate,
          width: 50,
          decoration:BoxDecoration(
            borderRadius:BorderRadius.circular(50.0),
            color: active ? const Color(0xff6C9BD2) : Colors.grey.withOpacity(0.6),//const Color(0xff22d88d)
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: active ? Alignment.centerRight : Alignment.centerLeft,
            curve: Curves.decelerate,
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                width: 20,
                height: 20,
                decoration:BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:BorderRadius.circular(100.0),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}


Widget customTypeAhead({EdgeInsetsGeometry? margin, Widget? icon,TextInputType? keyboardType,required TextEditingController controller, required Function(dynamic) onSelect, String? hint, String? label, required FutureOr<List?> Function(String search) suggestionsCallBack, required Widget Function(BuildContext context, dynamic,) itemBuilder}){
  return Container(
    margin: margin??const EdgeInsets.only(left: 10),
    //padding: responsiveApp.edgeInsetsApp.allSmallEdgeInsets,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      //border: Border.all(color:Colors.grey.withOpacity(0.2))
    ),
    child: TypeAheadField(
      onSelected: onSelect,
      loadingBuilder: (context){
        return const LinearProgressIndicator();
      },
      builder: (context, texEditingController, node){
        return customField(
          margin: margin,
          context: context,
          focusNode: node,
          keyboardType: keyboardType,
          controller: texEditingController,
          icon: icon??const Icon(Icons.search, color: Colors.grey,),
          hintText: hint??'Buscar aquí...',);
      },
      controller: controller,
      suggestionsCallback: suggestionsCallBack,
      itemBuilder: itemBuilder,
    ),
  );
}

TextEditingController productTaxController = TextEditingController();
Widget customField(
    {required BuildContext context,
      String? Function(String?)? validator,
      EdgeInsetsGeometry? margin,
      bool? readOnly,
      bool? obscureText,
      bool? showBorder,
      int? maxLines,
      int? minLines,
      int? maxLength,
      String? initialValue,
      Widget?icon,
      TextStyle? style,
      Widget? suffix,
      FocusNode? focusNode,
      TextInputType? keyboardType,
      Function(String)? onChanged,
      Function()? onEditingComplete,
      TextEditingController? controller,
      Iterable<String>? autofillHints,
      bool? useValidator,
      required String hintText,
      String? labelText,
    }){
  bool useBorder = showBorder??true;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Container(
          margin: margin??const EdgeInsets.symmetric(horizontal: 10),
          //padding: responsiveApp.edgeInsetsApp.hrzSmallEdgeInsets,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            //border: Border.all(color:Colors.grey.withOpacity(0.2))
          ),
          child: TextFormField(
            validator: useValidator??true? validator?? (value) {
              if (value != null && value.trim().isEmpty) {
                return '';
              }
              return null;
            }:null,
            maxLength: maxLength,
            minLines: minLines,
            maxLines: maxLines??1,
            initialValue: initialValue,
            obscureText: obscureText?? keyboardType==TextInputType.visiblePassword,
            //inputFormatters: widget.keyboardType==TextInputType.number?[FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d{0,2})?$')),]:null,
            //keyboardType: widget.keyboardType,
            style: style??Theme.of(context).textTheme.bodyMedium,
            controller: controller,
            readOnly: readOnly??false,
            focusNode: focusNode,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            inputFormatters: keyboardType == TextInputType.number
                ? [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d+(\.\d{0,2})?$')),
            ]
                : keyboardType == TextInputType.phone
                ? [phoneFormatter]
                : null,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(color: Colors.grey),
              errorStyle: const TextStyle(fontSize: 0), // Oculta el texto de error
              labelText:labelText,
              icon: icon,
              prefixIconConstraints: const BoxConstraints(maxHeight: 15,maxWidth: 15),
              suffix: suffix,
              contentPadding:const  EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
              border: useBorder? OutlineInputBorder(borderRadius: BorderRadius.circular(15)):InputBorder.none,
              disabledBorder:useBorder? OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),borderRadius: BorderRadius.circular(15)):InputBorder.none,
              enabledBorder:useBorder? OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),borderRadius: BorderRadius.circular(15)):InputBorder.none,
              errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.red,),borderRadius: BorderRadius.circular(15)),
            ),
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
          ),
        ),
      ),
    ],
  );
}

loadingDialog(BuildContext context)async{
  showDialog(
      context: context,
      builder: (ctx) =>const AlertDialog(
        content:  Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              CircularProgressIndicator(),
              Text('Por favor espere...')
            ],
          ),
        ),
      )
  );
}

Future<void> saveFile(BuildContext context,Uint8List bytes, String fileName) async {
  String? outputPath = await FilePicker.platform.saveFile(
    bytes: bytes,
    dialogTitle: 'Guardar archivo en:',
    fileName: fileName,
  );

  if(!kIsWeb) {
    if (outputPath != null) {
      File file = File(outputPath);
      await file.writeAsBytes(bytes);
      print('Archivo guardado en: $outputPath');
      CustomSnackBar().show(context: context,
          msg: 'Archivo guardado correctamente!',
          icon: Icons.error_outline_rounded,
          color: Colors.green);
    } else {
      print('El usuario canceló la selección de la ubicación.');
      CustomSnackBar().show(context: context,
          msg: 'El usuario canceló la selección de la ubicación.',
          icon: Icons.warning_amber_rounded,
          color: Colors.deepOrange);
    }
  }
}

Future<void> exportToExcel(BuildContext context,dynamic data) async {


  // Crea un archivo Excel
  var excel = ex.Excel.createExcel();
  ex.Sheet sheetObject = excel['Sheet1'];
  // Agrega los encabezadosject.appendRow(row);
  List<ex.CellValue> header = [];
  List<ex.CellValue> values = [];
  try {
    for (var cell in data[0].keys.toList()) {
      header.add(ex.TextCellValue(cell));
    }
    sheetObject.appendRow(header);

    // Agrega los datos
    for (var row in data) {
      for (var cell in row.values.toList()) {
        values.add(ex.TextCellValue(cell ?? ''));
      }

      sheetObject.appendRow(values);
      values.clear();
    }
  }catch(e){
    print(e);
    CustomSnackBar().show(context: context, msg: 'Error al preparar los datos a exportar.', icon: Icons.error_outline_rounded, color: Colors.red);

  }

  // Convertir el archivo Excel a bytes
  var list = excel.encode();

  if (list != null) {
    Uint8List bytes = Uint8List.fromList(list);

    // Guardar el archivo Excel en la ubicación seleccionada por el usuario
    await saveFile(context,bytes, 'output.xlsx');

  } else {
    CustomSnackBar().show(context: context, msg: 'Error al codificar el archivo Excel.', icon: Icons.error_outline_rounded, color: Colors.red);
  }
}
