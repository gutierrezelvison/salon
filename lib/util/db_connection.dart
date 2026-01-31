import 'dart:convert';
import 'dart:typed_data';
import "package:async/async.dart";
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Widgets/WebComponents/Header/Header.dart';
import '/util/Util.dart';


class BDConnection{
  
  //static String  host ='https://ericasblossombeautystudy.egtechrd.com/peluqueria_connect';
  //static String  host ='https://espacioprueba2.webcindario.com/peluqueria_connect';
  static String  host ='https://peluqueria.elvisongr.com/resources';
  //static String  host ='http://172.24.80.123/peluqueria_connect';
  //static String  host ='http://10.0.0.158/peluqueria_connect';
  final BuildContext? context;
  final String? origin; final String? email; final String? pass;
  BDConnection({this.context,this.origin,this.email, this.pass}){
    //print('$email $pass);
    if(email!=null) {
      if (origin == 'main') login(context!, email!, pass!);
    }
    if (origin == 'main') {
      getTaxData(context!);
      getCompanyData(context!);
    }
  }

  String getHost() {
    return host;
  }

  Future<Uint8List?> obtenerImagenDesdeServidor(String folder, String filename) async {
    try {
      final response = await http.get(
        Uri.parse("$host/get_image.php?folder=$folder&filename=$filename"),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes; // Convierte la respuesta en Uint8List
      } else {
        print("Error al obtener la imagen: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<double> getList({required BuildContext context,required String fechaInicio, required String fechaFin, required String condition, required String field}) async {
    double cant = 0;
    try{
      final response = await http.post(Uri.parse("$host/getData.php"),
          body: {
            'field'      : field.toString(),
            'condition'  : condition.toString(),
            'fechaInicio': fechaInicio.toString(),
            'fechaFin'   : fechaFin.toString(),
          }
      );
      var responseData = json.decode(response.body);
      cant = double.parse(responseData[0]['cant'].toString());
    }catch(e){

    }
    return cant;
  }

  Future<double> getList8({required BuildContext context,required String fechaInicio, required String fechaFin}) async {
    double cant = 0;
    try{
      final response = await http.post(Uri.parse("$host/getIncomes.php"),
          body: {
            'fechaInicio': fechaInicio.toString(),
            'fechaFin'   : fechaFin.toString(),
          }
      );

      var responseData = json.decode(response.body);

      cant  = responseData[0]["cant"]!=null?double.parse(responseData[0]["cant"].toString()):0;
    }catch(e){

    }


      return cant;
  }

  Future<List<dynamic>> getData({
    required Function(String) onError,
    BuildContext? context,
    required String fields,
    required String table,
    required String where,
    required String order,
    required String orderBy,
    required String groupBy,
  }) async {
    List<dynamic> docs = [];
    try{
      final response = await http.post(
          Uri.parse("$host/get_data.php"),
          body:{
            'fields'     : fields.toString(),
            'table'      : table.toString(),
            'where'      : where.toString(),
            'order'      : order.toString(),
            'order_by'   : orderBy.toString(),
            'group_by'   : groupBy.toString(),
          }
      );
      //print(response.body);
      print("""SELECT $fields FROM $table WHERE $where GROUP BY $groupBy ORDER BY $orderBy $order""");
      var responseData = json.decode(response.body);
      docs = responseData;
    }catch(e){
      print(e);
      if(e.toString().contains('errno = 1225')){
        docs.add('connection_error');
      }

    }
    return docs;
  }

  Future<List> getCategory(BuildContext context) async {
    List<Categorie> docs = [];
    try{
      final response = await http.post(
        Uri.parse("$host/getCategories.php"),
      );

      var responseData = json.decode(response.body);


      Categorie doc;
      doc = Categorie(name: 'all', image: ImageFiles(name: 'blanco.jpeg'));
      docs.add(doc);
      for (var singleDocument in responseData) {
        doc = Categorie(
          id: int.parse(singleDocument['id'].toString()),
          name: singleDocument['name'].toString(),
          slug: singleDocument['slug'].toString(),
          image: singleDocument['image']!=null? await setImages("categories", singleDocument['image']):null,
          status: singleDocument['status'].toString(),
          createdAt: singleDocument['createdAt'].toString(),
          updatedAt: singleDocument['updatedAt'].toString(),
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }
  Future<List<Service>> getServices({required BuildContext context,String? type,int? id,required String searchBy}) async {
    List<Service> docs=[];
    AppData appData = AppData();
    try {
      final response = await http.post(
          Uri.parse("$host/getServices.php"),
          body: {
            'id_cat': appData.getView() == 'only' ? (id??'').toString() : '',
            'campo': searchBy,
            'type': type??"service"
          }
      );

      var responseData = json.decode(response.body);

      Service doc;

      for (var singleDocument in responseData) {
        doc = Service(
          id: int.parse(singleDocument['id'].toString()),
          type: singleDocument['type'].toString(),
          name: singleDocument['name'].toString(),
          slug: singleDocument['slug'].toString(),
          description: singleDocument['description'].toString(),
          price: singleDocument['price'].toString(),
          commission: singleDocument['commission'].toString(),
          time: singleDocument['time'].toString(),
          time_type: singleDocument['time_type'].toString(),
          discount: singleDocument['discount'].toString(),
          discount_type: singleDocument['discount_type'].toString(),
          category_id: singleDocument['category_id'].toString(),
          category_name: singleDocument['category_name'].toString(),
          location_name: singleDocument['location_name'].toString(),
          location_id: singleDocument['location_id'].toString(),
          apply_taxes: int.parse(singleDocument['apply_taxes'].toString()),
          tax_id: int.parse(singleDocument['tax_id'].toString()),
          quantity: int.parse(singleDocument['quantity'].toString()),
          image: singleDocument['image']!=null && singleDocument['image']!=''? await setImages("services", singleDocument['image']):null,
          status: singleDocument['status'].toString(),
          createdAt: singleDocument['createdAt'].toString(),
          updatedAt: singleDocument['updatedAt'].toString(),
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }

  Future<List> getBookingTimes(BuildContext context,String day) async {
    List<BookingTime> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/getBookingTimes.php"),
          body: {
            'day': day,
          }
      );

      var responseData = json.decode(response.body);


      BookingTime doc;
      for (var singleDocument in responseData) {
        doc = BookingTime(
          id: int.parse(singleDocument['id'].toString()),
          day: singleDocument['day'].toString(),
          start_time: singleDocument['start_time'].toString(),
          end_time: singleDocument['end_time'].toString(),
          multiple_booking: singleDocument['multiple_booking'].toString(),
          max_booking: singleDocument['max_booking'].toString(),
          status: singleDocument['status'].toString(),
          slot_duration: singleDocument['slot_duration'].toString(),
          created_at: singleDocument['created_at'].toString(),
          updated_at: singleDocument['updated_at'].toString(),
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }

  Future<bool> updateBookingTimes(BuildContext context,BookingTime day) async {
    bool success= false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateBookingTime.php"),
          body: {
            'id': day.id.toString(),
            'day': day.day.toString(),
            'end_time': day.end_time.toString(),
            'max_booking': day.max_booking.toString(),
            'multiple_booking': day.multiple_booking.toString(),
            'slot_duration': day.slot_duration.toString(),
            'start_time': day.start_time.toString(),
            'status': day.status.toString(),
            'date': DateTime.now().toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') {
        success = true;
      }
    }catch(e){

    }

    return success;
  }

  Future<PaymentMethod> getPaymentMethods(BuildContext context) async {
    List<PaymentMethod> docs=[];
    PaymentMethod doc = PaymentMethod();
    try {
      final response = await http.post(
        Uri.parse("$host/getPaymentMethod.php"),
      );

      var responseData = json.decode(response.body);

      for (var singleDocument in responseData) {
        doc = PaymentMethod(
          id: int.parse(singleDocument['id'].toString()),
          paypal_client_id: singleDocument['paypal_client_id'].toString(),
          paypal_secret: singleDocument['paypal_secret'].toString(),
          stripe_client_id: singleDocument['stripe_client_id'].toString(),
          stripe_secret: singleDocument['stripe_secret'].toString(),
          stripe_webhook_secret: singleDocument['stripe_webhook_secret']
              .toString(),
          stripe_status: singleDocument['stripe_status'].toString(),
          paypal_status: singleDocument['paypal_status'].toString(),
          paypal_mode: singleDocument['paypal_mode'].toString(),
          offline_payment: singleDocument['offline_payment'].toString(),
          razorpay_key: singleDocument['razorpay_key'].toString(),
          razorpay_secret: singleDocument['razorpay_secret'].toString(),
          razorpay_status: singleDocument['razorpay_status'].toString(),
          created_at: singleDocument['created_at'].toString(),
          updated_at: singleDocument['updated_at'].toString(),
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return doc;
  }

  Future<bool> setUser({required BuildContext context,int? new_customer,required double comission,int? group_id,required int role, required String name, required String email,
    required String calling_code, required String mobile, required int mobile_verified,
    required String password,Stream<List<int>>? file, int? imageLength,}) async {
    bool success = false;


    try {
      String hashedPassword = hashPassword(password.toString()); // Cifra la contraseña
      var uri = Uri.parse("$host/addCustomerUser.php");
      var request = http.MultipartRequest("POST", uri);
      print("""
        1-$name
        2-$group_id\n
        3-$new_customer\n
        4-$comission\n
        5-$email\n
        6-$calling_code\n
        7-$mobile\n
        8-$mobile_verified\n
        9-$hashedPassword\n
        10-${DateTime.now()}
    """);
      if (file != null) {
        http.ByteStream stream;
        http.MultipartFile multipartFile;
        var length = imageLength;
        stream = http.ByteStream(DelegatingStream.typed(file));

        String imageName =
            '${DateTime.now().day}usdcq6${DateTime.now().month}5e3dc6${DateTime.now().year}h12dcs${DateTime.now().minute}sa03dsaa0${DateTime.now().second}';

        multipartFile = http.MultipartFile("image", stream, length!,
            filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['name'] = name.toString();
        request.fields['group_id'] = group_id.toString();
        request.fields['new_customer'] = new_customer.toString();
        request.fields['comission'] = comission.toString();
        request.fields['email'] = email.toString();
        request.fields['calling_code'] = calling_code.toString();
        request.fields['mobile'] = mobile.toString();
        request.fields['mobile_verified'] = mobile_verified.toString();
        request.fields['password'] = hashedPassword.toString();
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['name'] = name.toString();
        request.fields['group_id'] = group_id.toString();
        request.fields['new_customer'] = new_customer.toString();
        request.fields['comission'] = comission.toString();
        request.fields['email'] = email.toString();
        request.fields['calling_code'] = calling_code.toString();
        request.fields['mobile'] = mobile.toString();
        request.fields['mobile_verified'] = mobile_verified.toString();
        request.fields['password'] = hashedPassword.toString();
        request.fields['date'] = DateTime.now().toString();
      }

      http.Response response = await http.Response.fromStream(
          await request.send());
      print(response.body);
      var responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (await setRoleUser(role_id: role,
            user_id: int.parse(responseData['id']), context: context)) success = true;
      }
    }catch(e){
      print(e);
    }
    return success;
  }

  Future<bool> updateUser({required Function(String) onError, required BuildContext context,required User user, Stream<List<int>>? file,required int imageLength,required String imageName,}) async {

    bool success = false;
    try {
      var uri = Uri.parse("$host/updateCustomer.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;

      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));

        if (imageName == 'default-avatar-user') {
          imageName = '${DateTime
              .now()
              .day}usdcq6${DateTime
              .now()
              .month}5e3dc6${DateTime
              .now()
              .year}h12dcs${DateTime
              .now()
              .minute}sa03dsaa0${DateTime
              .now()
              .second}';
        }
        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['id'] = user.id.toString();
        request.fields['name'] = user.name!;
        request.fields['group_id'] = user.group_id.toString();
        request.fields['new_customer'] = user.new_customer.toString();
        request.fields['comission'] = user.comission.toString();
        request.fields['email'] = user.email!;
        request.fields['calling_code'] = user.calling_code.toString();
        request.fields['mobile'] = user.mobile.toString();
        request.fields['mobile_verified'] = user.mobile_verified.toString();
        request.fields['remember_token'] = user.remember_token.toString();
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['id'] = user.id.toString();
        request.fields['name'] = user.name!;
        request.fields['group_id'] = user.group_id.toString();
        request.fields['new_customer'] = user.new_customer.toString();
        request.fields['comission'] = user.comission.toString();
        request.fields['email'] = user.email!;
        request.fields['calling_code'] = user.calling_code.toString();
        request.fields['mobile'] = user.mobile.toString();
        request.fields['mobile_verified'] = user.mobile_verified.toString();
        request.fields['remember_token'] = user.remember_token.toString();
        request.fields['date'] = DateTime.now().toString();
      }
      http.Response response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        if (await updateRoleUser(context: context,role_id: user.rol_id!,
            user_id: user.id!)) success = true;
      }
    }catch(e){

    }
    return success;
  }

  Future<bool> deleteUser({required BuildContext context,required int id}) async {

    bool success = false;
    try {
      var uri = Uri.parse("$host/deleteUser.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['id'] = id.toString();

      request.fields['date'] = DateTime.now().toString();

      http.Response response = await http.Response.fromStream(
          await request.send());

      if (response.statusCode == 200) {
        success = true;
      }
    }catch(e){

    }
    return success;
  }

  Future<bool> setRoleUser({required BuildContext context,required int role_id,required int user_id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addRoleUser.php"),
          body: {
            'role_id': role_id.toString(),
            'user_id': user_id.toString(),
          }
      );
      //print(response.body);
      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){
      //print(e);
    }
    return success;
  }

  Future<bool> updateRoleUser({required BuildContext context,required int role_id,required int user_id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateRoleUser.php"),
          body: {
            'role_id': role_id.toString(),
            'user_id': user_id.toString(),
          }
      );
      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<List<dynamic>> login(BuildContext context,String email, String pass) async {
    List<dynamic> docs = [];
    late User doc;
    try{
      String hashedPassword = hashPassword(pass.toString()); // Cifra la contraseña
      final response = await http.post(
          Uri.parse("$host/login.php"),
          body: {
            'email' : email,
            'password' : hashedPassword,
          }
      );
      print(response.body);
      if(response.body=='Contraseña incorrecta'){
        docs.add('wrong_pass');
        return docs;
      }else {
        var responseData = json.decode(response.body);
        for (var singleDocument in responseData) {
          AppData appData = AppData();
          doc = User(
            id: int.parse(singleDocument['id'].toString()),
            rol_id: int.parse(singleDocument['role_id'].toString()),
            group_id: singleDocument['group_id'] != null
                ? int.parse(singleDocument['group_id'].toString())
                : 0,
            name: singleDocument['name'].toString(),
            email: singleDocument['email'].toString(),
            calling_code: singleDocument['calling_code'].toString(),
            mobile: singleDocument['mobile'].toString(),
            mobile_verified: singleDocument['mobile_verified'].toString(),
            security_questions:
                int.parse(singleDocument['security_questions'].toString()),
            default_pass: int.parse(singleDocument['default_pass'].toString()),
            password: pass,
            image: singleDocument['image'] != null && singleDocument['image'] != ''
                ?  await setImages("users", singleDocument['image'])
                : null,
            remember_token: singleDocument['remember_token'] != null
                ? singleDocument['remember_token'].toString()
                : "",
          );
          appData.setUserData(doc);
          docs.add(doc);
        }
      }
    }catch(e){
      print(e);
      if(e.toString().contains('errno = 1225')){
        docs.add('connection_error');
      }
    }
    return docs;
  }
Future<List<dynamic>> validateAdminPass(BuildContext context,int userID, String pass) async {
    List<dynamic> docs = [];
    late User doc;
    try{
      String hashedPassword = hashPassword(pass.toString()); // Cifra la contraseña
      final response = await http.post(
          Uri.parse("$host/validate_admin_pwd.php"),
          body: {
            'id' : userID.toString(),
            'password' : hashedPassword,
          }
      );
      print("Respuesta de validate pwd: ${response.body}");
      if(response.body=='Contraseña incorrecta'){
        docs.add('Contraseña incorrecta');
      }else if (response.body == 'Usuario no encontrado') {
        docs.add('Usuario no encontrado');
      }else{
        var responseData = json.decode(response.body);
        docs.add(responseData);
      }
      return docs;
    }catch(e){
      print(e);
      if(e.toString().contains('errno = 1225')){
        docs.add('connection_error');
      }
    }
    return docs;
  }

  Future<List> getUsers({required BuildContext context,required int roleId}) async {
    List<User> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/${roleId == 3 ? 'getUsers' : 'getEmployees'}.php"),
          body: {
            'roleId': roleId.toString(),
          }
      );
      var responseData = json.decode(response.body);

      late User doc;
      late User list;
      for (var singleDocument in responseData) {
        if (roleId == 3) {
          var query = await getUsersBookingCount(context: context,roleId: roleId,
              userId: int.parse(singleDocument['id'].toString()));
          for (var e in query) {
            list = User(
              booking_approved_count: e.booking_approved_count,
              booking_canceled_count: e.booking_canceled_count,
              booking_in_progress_count: e.booking_in_progress_count,
              booking_completed_count: e.booking_completed_count,
              booking_pending_count: e.booking_pending_count,
            );
          }
        }

        doc = roleId == 3
            ? User(
          id: int.parse(singleDocument['id'].toString()),
          group_id: singleDocument['group_id'] != null ? int.parse(
              singleDocument['group_id'].toString()) : 0,
          name: singleDocument['name'].toString(),
          email: singleDocument['email'].toString(),
          new_customer: int.parse(singleDocument['new_customer']),
          calling_code: singleDocument['calling_code'].toString(),
          mobile: singleDocument['mobile'].toString(),
          mobile_verified: singleDocument['mobile_verified'].toString(),
          password: singleDocument['password'].toString(),
          image: singleDocument['image'] != null
              ? await setImages("users", singleDocument['image'])
              : null,
          remember_token: singleDocument['remember_token'] != null
              ? singleDocument['remember_token'].toString()
              : "",
          created_at: singleDocument['created_at'].toString(),

          booking_approved_count: list.booking_approved_count,
          booking_canceled_count: list.booking_canceled_count,
          booking_in_progress_count: list.booking_in_progress_count,
          booking_completed_count: list.booking_completed_count,
          booking_pending_count: list.booking_pending_count,
        )
            : User(
          id: int.parse(singleDocument['id'].toString()),
          group_id: singleDocument['group_id'] != null ? int.parse(
              singleDocument['group_id'].toString()) : 0,
          name: singleDocument['name'].toString(),
          comission: double.parse(singleDocument['comission'].toString()),
          email: singleDocument['email'].toString(),
          calling_code: singleDocument['calling_code'].toString(),
          mobile: singleDocument['mobile'].toString(),
          mobile_verified: singleDocument['mobile_verified'].toString(),
          password: singleDocument['password'].toString(),
          image: singleDocument['image'] != null
              ? await setImages("users", singleDocument['image'])
              : null,
          remember_token: singleDocument['remember_token'] != null
              ? singleDocument['remember_token'].toString()
              : "",
          created_at: singleDocument['created_at'].toString(),
          rol_id: int.parse(singleDocument['rol_id'].toString()),
          group_name: singleDocument['group_name'].toString(),
          rol_name: singleDocument['rol_name'].toString(),
        );
        docs.add(doc);
        if (roleId == 3) {
          list = User(
            booking_approved_count: 0,
            booking_canceled_count: 0,
            booking_in_progress_count: 0,
            booking_completed_count: 0,
            booking_pending_count: 0,);
        }
      }
    }catch(e){
      print(e);
    }
    return docs;
  }
  Future<List> getRoleUsers({required BuildContext context,required int roleId}) async {
    List<User> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/getRoleUsers.php"),
          body: {
            'roleId': roleId.toString(),
          }
      );
      //print(response.body);
      var responseData = json.decode(response.body);

      late User doc;
      for (var singleDocument in responseData) {
        doc = User(
          id: int.parse(singleDocument['id'].toString()),
          group_id: singleDocument['group_id'] != null ? int.parse(
              singleDocument['group_id'].toString()) : 0,
          name: singleDocument['name'].toString(),
          email: singleDocument['email'].toString(),
          calling_code: singleDocument['calling_code'].toString(),
          mobile: singleDocument['mobile'].toString(),
          mobile_verified: singleDocument['mobile_verified'].toString(),
          password: singleDocument['password'].toString(),
          image: singleDocument['image'] != null
              ? await setImages("users", singleDocument['image'])
              : "",
          remember_token: singleDocument['remember_token'] != null
              ? singleDocument['remember_token'].toString()
              : "",
          created_at: singleDocument['created_at'].toString(),
          rol_id: int.parse(singleDocument['rol_id'].toString()),
          group_name: singleDocument['group_name'].toString(),
          rol_name: singleDocument['rol_name'].toString(),
        );
        docs.add(doc);
      }
    }catch(e){

    }
      return docs;
    }

  Future<List> getUsersBookingCount({required BuildContext context,required int roleId, required int userId}) async {
    List<User> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/getUsersBookingCount.php"),
          body: {
            'userId': userId.toString(),
            'roleId': roleId.toString(),
          }
      );
      var responseData = json.decode(response.body);

      late User doc;
      for (var singleDocument in responseData) {
        doc = User(
          id: singleDocument['id'] != null ? int.parse(
              singleDocument['id'].toString()) : 0,
          booking_approved_count: singleDocument['approved'] != null ? int
              .parse(singleDocument['approved'].toString()) : 0,
          booking_canceled_count: singleDocument['canceled'] != null ? int
              .parse(singleDocument['canceled'].toString()) : 0,
          booking_in_progress_count: singleDocument['in_progress'] != null ? int
              .parse(singleDocument['in_progress'].toString()) : 0,
          booking_completed_count: singleDocument['completed'] != null ? int
              .parse(singleDocument['completed'].toString()) : 0,
          booking_pending_count: singleDocument['pending'] != null ? int.parse(
              singleDocument['pending'].toString()) : 0,
        );
        docs.add(doc);
      }
    }catch(e){

    }

    return docs;
  }

  Future<bool> setBookingItem({required BuildContext context,required int booking_id,required discount, required int business_service_id, required int quantity,
    required double unit_price, required double amount, required int chairId}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addBookingItem.php"),
          body: {
            'booking_id': booking_id.toString(),
            'business_service_id': business_service_id.toString(),
            'quantity': quantity.toString(),
            'chair_id': chairId.toString(),
            'unit_price': unit_price.toString(),
            'discount': discount.toString(),
            'amount': amount.toString(),
            'fecha': DateTime.now().toString()
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<Map<String,dynamic>> setBooking({required BuildContext context, int? employee_id, required int user_id, required DateTime date_time,
    required String status, required String payment_gateway, required double original_amount,
    required double discount,required double discount_percent,required String tax_name,
    required double tax_percent,required double tax_amount,required double amount_to_pay,
    required String payment_status, required String source, String? additional_notes,
    required List<BookingItem> itemList,
  }) async {
    bool success = false;
    int idBooking = 0;
    try {
      final response = await http.post(
          Uri.parse("$host/addBooking.php"),
          body: {
            'employee_id': employee_id.toString(),
            'user_id': user_id.toString(),
            'date_time': date_time.toString(),
            'status': status.toString(),
            'payment_gateway': payment_gateway.toString(),
            'original_amount': original_amount.toString(),
            'discount': discount.toString(),
            'discount_percent': discount_percent.toString(),
            'tax_name': tax_name.toString(),
            'tax_percent': tax_percent.toString(),
            'tax_amount': tax_amount.toString(),
            'amount_to_pay': amount_to_pay.toString(),
            'payment_status': payment_status.toString(),
            'source': source.toString(),
            'additional_notes': additional_notes.toString(),
            'fecha': DateTime.now().toString()
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') {

        idBooking=int.parse(responseData['ultimoid'].toString());
        for (var item in itemList) {
          success = await setBookingItem(
              context: context,
              booking_id: int.parse(responseData['ultimoid'].toString()),
              business_service_id: item.business_service_id!,
              chairId: item.chair_id!,
              quantity: item.quantity!,
              discount: item.discount!,
              unit_price: item.unit_price!,
              amount: item.quantity! * item.unit_price!
          );
        }

      }
    }catch(e){
    }
    return {"idBooking":idBooking,"success":success,};
  }

  Future<bool> updateBooking({required BuildContext context, required int id,int? employee_id,
    int? user_id, DateTime? date_time,
    String? status, String? payment_gateway, double? original_amount,
    double? discount, double? discount_percent, String? tax_name,
    double? tax_percent, double? tax_amount, double? amount_to_pay,
    String? payment_status, String? source, String? additional_notes,
    List<BookingItem>? itemList,
  }) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateBooking.php"),
          body: {
            'id': id.toString(),
            'status': status.toString(),
            'payment_gateway': payment_gateway != null ? payment_gateway
                .toString() : '',
            'discount': discount != null ? discount.toString() : '',
            'discount_percent': discount_percent != null ? discount_percent
                .toString() : '',
            'tax_amount': tax_amount != null ? tax_amount.toString() : '',
            'amount_to_pay': amount_to_pay != null
                ? amount_to_pay.toString()
                : '',
            'payment_status': payment_status != null
                ? payment_status.toString()
                : '',
            'date': DateTime.now().toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success'] == 'true') {
        success = true;
        CustomSnackBar().show(
            context: context,
            msg: 'Operación realizada con éxito',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xff22d88d)
        );
      } else {
        CustomSnackBar().show(
            context: context,
            msg: responseData['error'],
            icon: Icons.error_outline_rounded,
            color: const Color(0xffFF525C)
        );
      }
    }catch(e){
    }
    return success;
  }

  Future<List> getBookingList({required BuildContext context,String? location,String? userName,required String status,String? status2,required String payment_status,required String fechaInicio, required String fechaFin}) async {
    List<BookingList> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/getBookingList.php"),
          body: {
            'fechaInicio': fechaInicio.toString(),
            'fechaFin': fechaFin.toString(),
            'status': status != 'all' ? status.toString() : '',
            'status2': status2 != null && status2 != 'all'
                ? status2.toString()
                : '',
            'payment_status': payment_status != 'all' ? payment_status
                .toString() : '',
            'userName': userName != 'all' ? userName.toString() : '',
            'location': location != 'all' ? location.toString() : '',
          }
      );

      var responseData = json.decode(response.body);

      BookingList doc;
      Service service;
      User user;
      Bookings bookings;
      BookingItem bookingItem;
      User employee;

      for (var singleDocument in responseData) {
        bookings = Bookings(
          id: int.parse(singleDocument['booking_id'].toString()),
          date_time: singleDocument['date_time'].toString(),
          status: singleDocument['status'].toString(),
          payment_gateway: singleDocument['payment_gateway'].toString(),
          original_amount: double.parse(
              singleDocument['original_amount'].toString()),
          discount: double.parse(singleDocument['discount'].toString()),
          discount_percent: double.parse(
              singleDocument['discount_percent'].toString()),
          tax_name: singleDocument['tax_name'].toString(),
          tax_percent: double.parse(singleDocument['tax_percent'].toString()),
          tax_amount: double.parse(singleDocument['tax_amount'].toString()),
          amount_to_pay: double.parse(
              singleDocument['amount_to_pay'].toString()),
          payment_status: singleDocument['payment_status'].toString(),
          source: singleDocument['source'].toString(),
          additional_notes: singleDocument['additional_notes'].toString(),
        );
        bookingItem = BookingItem(
            id: int.parse(singleDocument['booking_item_id'].toString()),
            quantity: int.parse(singleDocument['quantity'].toString()),
            unit_price: double.parse(singleDocument['unit_price'].toString()),
            amount: double.parse(singleDocument['amount'].toString())
        );

        service = Service(
          id: int.parse(singleDocument['service_id'].toString()),
          name: singleDocument['service_name'].toString(),
          type: singleDocument['service_type'].toString(),
          price: singleDocument['service_price'].toString(),
          discount: singleDocument['service_discount'].toString(),
          discount_type: singleDocument['service_discount_type'].toString(),
        );

        user = User(
          id: int.parse(singleDocument['user_id'].toString()),
          name: singleDocument['name'].toString(),
          email: singleDocument['email'].toString(),
          calling_code: singleDocument['calling_code'].toString(),
          mobile: singleDocument['mobile'].toString(),
          image: singleDocument['image']!=null?await setImages("users", singleDocument['image']):null,
        );
        employee = User(
          id: int.parse(singleDocument['employee_id'].toString()),
          name: singleDocument['employee_name'].toString(),
        );
        doc = BookingList(
            bookingItem: bookingItem,
            service: service,
            user: user,
            bookings: bookings,
            employee: employee
        );
        docs.add(doc);
      }
    }catch(e){
      print(e);
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return docs;
  }

  Future<List> getCustomerBookingList({required BuildContext context,int? condition,required String field}) async {
    List<BookingList> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/getCustomerBookingList.php"),
          body: {
            'field': field.toString(),
            'condition': condition.toString(),
          }
      );
      var responseData = json.decode(response.body);

      BookingList doc;
      Service service;
      User user;
      Bookings bookings;
      BookingItem bookingItem;
      User employee;

      for (var singleDocument in responseData) {
        bookings = Bookings(
          id: int.parse(singleDocument['booking_id'].toString()),
          date_time: singleDocument['date_time'].toString(),
          status: singleDocument['status'].toString(),
          payment_gateway: singleDocument['payment_gateway'].toString(),
          original_amount: double.parse(
              singleDocument['original_amount'].toString()),
          discount: double.parse(singleDocument['discount'].toString()),
          discount_percent: double.parse(
              singleDocument['discount_percent'].toString()),
          tax_name: singleDocument['tax_name'].toString(),
          tax_percent: double.parse(singleDocument['tax_percent'].toString()),
          tax_amount: double.parse(singleDocument['tax_amount'].toString()),
          amount_to_pay: double.parse(
              singleDocument['amount_to_pay'].toString()),
          payment_status: singleDocument['payment_status'].toString(),
          source: singleDocument['source'].toString(),
          additional_notes: singleDocument['additional_notes'].toString(),
        );
        bookingItem = BookingItem(
            id: int.parse(singleDocument['booking_item_id'].toString()),
            quantity: int.parse(singleDocument['quantity'].toString()),
            unit_price: double.parse(singleDocument['unit_price'].toString()),
            amount: double.parse(singleDocument['amount'].toString())
        );

        service = Service(
          id: int.parse(singleDocument['service_id'].toString()),
          name: singleDocument['service_name'].toString(),
        );

        user = User(
          id: int.parse(singleDocument['user_id'].toString()),
          name: singleDocument['name'].toString(),
          email: singleDocument['email'].toString(),
          calling_code: singleDocument['calling_code'].toString(),
          mobile: singleDocument['mobile'].toString(),
          image: singleDocument['image']!=null? await setImages("users", singleDocument['image']):null,
        );
        employee = User(
          id: int.parse(singleDocument['employee_id'].toString()),
          name: singleDocument['employee_name'].toString(),
        );
        doc = BookingList(
            bookingItem: bookingItem,
            service: service,
            user: user,
            bookings: bookings,
          employee: employee
        );
        docs.add(doc);
      }
    }catch(e){
    }
    return docs;
  }

  Future<List> getSucursales(BuildContext context) async {
    List<Sucursal> docs = [];
    try {
      final response = await http.post(
        Uri.parse("$host/getLocation.php"),
      );

      var responseData = json.decode(response.body);


      Sucursal doc;

      for (var singleDocument in responseData) {
        doc = Sucursal(
            id: int.parse(singleDocument['id'].toString()),
            name: singleDocument['name'],
            created_at: singleDocument['created_at'],
            updated_at: singleDocument['updated_at']
        );
        docs.add(doc);
      }
    }catch(e){
      print(e);
    }
    return docs;
  }

  Future<bool> setSucursal({required BuildContext context,required String name}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addSucursal.php"),
          body: {
            'name': name.toString(),
            'date': DateTime.now().toString()
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }

  Future<bool> deleteSucursal({required BuildContext context, required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteSucursal.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
  Future<bool> updateSucursal({required BuildContext context,required int id,required String name}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateSucursal.php"),
          body: {
            'id': id.toString(),
            'name': name.toString(),
            'date': DateTime.now().toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<List> getRoles(BuildContext context) async {
    List<Roles> docs=[];
    try {
      final response = await http.post(
        Uri.parse("$host/getRoles.php"),
      );

      var responseData = json.decode(response.body);

      Roles doc;
      int count = 0;
      for (var singleDocument in responseData) {
        count = await getRoleMembers(context,int.parse(singleDocument['id'].toString()));
        doc = Roles(
            id: int.parse(singleDocument['id'].toString()),
            name: singleDocument['name'],
            display_name: singleDocument['display_name'],
            description: singleDocument['description'],
            member_count: count,
            created_at: singleDocument['created_at'],
            updated_at: singleDocument['updated_at']
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }
  Future<int> getRoleMembers(BuildContext context,int roleId) async {
    int count=0;
    try {
      final response = await http.post(
          Uri.parse("$host/getRoleMembers.php"),
          body: {
            'roleId': roleId.toString()
          }
      );
      var responseData = json.decode(response.body);

      count = int.parse(responseData[0]['members'].toString());
    }catch(e){

    }
      return count;
    }

  Future<bool> setRol({required BuildContext context,required String name,required String display_name, String? description}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addRol.php"),
          body: {
            'name': name.toString(),
            'display_name': display_name.toString(),
            'description': description.toString(),
            'date': DateTime.now().toString()
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<bool> deleteRol({required BuildContext context, required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteRol.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
  Future<bool> updateRol({required BuildContext context,required int id,required String name,required String display_name, String? description}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateRol.php"),
          body: {
            'id': id.toString(),
            'name': name.toString(),
            'display_name': display_name.toString(),
            'description': description.toString(),
            'date': DateTime.now().toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
  Future<List> getGroups(BuildContext context) async {
    List<EmployeeGroups> docs=[];
    try {
      final response = await http.post(
        Uri.parse("$host/getGroup.php"),
      );

      var responseData = json.decode(response.body);

      EmployeeGroups doc;

      for (var singleDocument in responseData) {
        doc = EmployeeGroups(
            id: int.parse(singleDocument['id'].toString()),
            name: singleDocument['name'],
            status: singleDocument['status'],
            created_at: singleDocument['created_at'],
            updated_at: singleDocument['updated_at']
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }

  Future<bool> setGroup({required BuildContext context,required String name,required String status}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addGroup.php"),
          body: {
            'name': name.toString(),
            'status': status.toString(),
            'date': DateTime.now().toString()
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<bool> deleteGroup({required BuildContext context,required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteGroup.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
  Future<bool> updateGroup({required BuildContext context,required int id,required String name,required String status}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateGroup.php"),
          body: {
            'id': id.toString(),
            'name': name.toString(),
            'status': name.toString(),
            'date': DateTime.now().toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<bool> addCategory({required BuildContext context,Stream<List<int>>? file,required int imageLength, required String name, required String status, required String slug}) async {
    bool success = false;
    try {
      var uri = Uri.parse("$host/addCategories.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;
      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));

        String imageName = '${DateTime
            .now()
            .day}s2dsdcq6${DateTime
            .now()
            .month}5es1c6${DateTime
            .now()
            .year}h12ch${DateTime
            .now()
            .minute}sa0d002wd1${DateTime
            .now()
            .second}';
        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['name'] = name;
        request.fields['status'] = status;
        request.fields['slug'] = slug;
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['name'] = name;
        request.fields['status'] = status;
        request.fields['slug'] = slug;
        request.fields['date'] = DateTime.now().toString();
      }
      var respond = await request.send();
      if (respond.statusCode == 200) {
        success = true;
      }
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }

  Future<bool> updateCategory({required BuildContext context,Stream<List<int>>? file, required int id,required int imageLength, required String name,
    required String status, required String slug, required String imageName}) async {
    bool success = false;
    try {
      var uri = Uri.parse("$host/updateCategories.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;
      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));

        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['id'] = id.toString();
        request.fields['name'] = name;
        request.fields['status'] = status;
        request.fields['slug'] = slug;
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['id'] = id.toString();
        request.fields['name'] = name;
        request.fields['status'] = status;
        request.fields['slug'] = slug;
        request.fields['date'] = DateTime.now().toString();
      }
      var respond = await request.send();
      if (respond.statusCode == 200) {
        success = true;
      }
    }catch(e){

    }
    return success;
  }
  Future<bool> deleteCategory({required BuildContext context,required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteCategory.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
Future<bool> deleteData({required BuildContext context,required String table,required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteData.php"),
          body: {
            'id': id.toString(),
            'table': table.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
Future<bool> addService({required BuildContext context,Stream<List<int>>? file,required int imageLength, required String name,required int category_id,
  required String status, required String slug, required String imageName, required int location_id, required String type, int? apply_taxes, int? tax_id, int? quantity, required double discount,
  required String discount_type, required String time_type, required double time, required double price, required double commission, required String description}) async {
    bool success = false;
    try {
      var uri = Uri.parse("$host/addService.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;
      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));

        String imageName = '${DateTime
            .now()
            .day}mf2dq1${DateTime
            .now()
            .month}9tc3${DateTime
            .now()
            .year}h1h${DateTime
            .now()
            .minute}sa0d002wd1${DateTime
            .now()
            .second}';
        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['type'] = type;
        request.fields['name'] = name;
        request.fields['slug'] = slug;
        request.fields['description'] = description;
        request.fields['price'] = price.toString();
        request.fields['commission'] = commission.toString();
        request.fields['time'] = time.toString();
        request.fields['time_type'] = time_type;
        request.fields['discount'] = discount.toString();
        request.fields['discount_type'] = discount_type;
        request.fields['category_id'] = category_id.toString();
        request.fields['location_id'] = location_id.toString();
        request.fields['apply_taxes'] = apply_taxes.toString();
        request.fields['tax_id'] = tax_id.toString();
        request.fields['quantity'] = quantity.toString();
        request.fields['status'] = status;
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['type'] = type;
        request.fields['name'] = name;
        request.fields['slug'] = slug;
        request.fields['description'] = description;
        request.fields['price'] = price.toString();
        request.fields['commission'] = commission.toString();
        request.fields['time'] = time.toString();
        request.fields['time_type'] = time_type;
        request.fields['discount'] = discount.toString();
        request.fields['discount_type'] = discount_type;
        request.fields['category_id'] = category_id.toString();
        request.fields['location_id'] = location_id.toString();
        request.fields['apply_taxes'] = apply_taxes.toString();
        request.fields['tax_id'] = tax_id.toString();
        request.fields['quantity'] = quantity.toString();
        request.fields['status'] = status;
        request.fields['date'] = DateTime.now().toString();
      }

      var respond = await request.send();
      if (respond.statusCode == 200) {
        success = true;
      }
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }

  Future<bool> updateService({required BuildContext context,Stream<List<int>>? file, required int id,required int imageLength, required String name,required int category_id,
    required String status, required String slug, required String imageName, required int location_id, required String type, int? apply_taxes, int? tax_id, int? quantity, required double discount,
    required String discount_type, required String time_type, required double time, required double price, required double commission, required String description}) async {
    bool success = false;
    try {
      var uri = Uri.parse("$host/updateService.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;
      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));



        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['id'] = id.toString();
        request.fields['type'] = type;
        request.fields['name'] = name;
        request.fields['slug'] = slug;
        request.fields['description'] = description;
        request.fields['price'] = price.toString();
        request.fields['commission'] = commission.toString();
        request.fields['time'] = time.toString();
        request.fields['time_type'] = time_type;
        request.fields['discount'] = discount.toString();
        request.fields['discount_type'] = discount_type;
        request.fields['category_id'] = category_id.toString();
        request.fields['location_id'] = location_id.toString();
        request.fields['apply_taxes'] = apply_taxes.toString();
        request.fields['tax_id'] = tax_id.toString();
        request.fields['quantity'] = quantity.toString();
        request.fields['status'] = status;
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['id'] = id.toString();
        request.fields['type'] = type;
        request.fields['name'] = name;
        request.fields['slug'] = slug;
        request.fields['description'] = description;
        request.fields['price'] = price.toString();
        request.fields['commission'] = commission.toString();
        request.fields['time'] = time.toString();
        request.fields['time_type'] = time_type;
        request.fields['discount'] = discount.toString();
        request.fields['discount_type'] = discount_type;
        request.fields['category_id'] = category_id.toString();
        request.fields['location_id'] = location_id.toString();
        request.fields['apply_taxes'] = apply_taxes.toString();
        request.fields['tax_id'] = tax_id.toString();
        request.fields['quantity'] = quantity.toString();
        request.fields['status'] = status;
        request.fields['date'] = DateTime.now().toString();
      }
      var respond = await request.send();
      if (respond.statusCode == 200) {
        success = true;
      }
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }
  Future<bool> deleteService({required BuildContext context,required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteService.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);
      if (responseData['success'] == 'true') success = true;
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }

  Future<bool> updateCompany({required BuildContext context,required Company companyData, Stream<List<int>>? file,required int imageLength,required String imageName,}) async {

    bool success = false;
    try {
      var uri = Uri.parse("$host/updateCompany.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;
      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));

        if (imageName == 'logo' || imageName == 'null' || imageName == '') {
          imageName = '${DateTime
              .now()
              .day}ledcq6${DateTime
              .now()
              .month}507dz0${DateTime
              .now()
              .year}g95dfs${DateTime
              .now()
              .minute}or41gsxa1${DateTime
              .now()
              .second}';
        }
        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.png');
        request.files.add(multipartFile);
        request.fields['id'] = companyData.id.toString();
        request.fields['company_name'] = companyData.company_name!;
        request.fields['company_email'] = companyData.company_email!;
        request.fields['company_phone'] = companyData.company_phone!;
        request.fields['address'] = companyData.address!;
        request.fields['date_format'] = companyData.date_format ?? '';
        request.fields['time_format'] = companyData.time_format ?? '';
        request.fields['website'] = companyData.website ?? '';
        request.fields['timezone'] = companyData.timezone ?? '';
        request.fields['locale'] = companyData.locale ?? '';
        request.fields['latitude'] = companyData.latitude ?? '';
        request.fields['longitude'] = companyData.longitude ?? '';
        request.fields['currency_id'] = companyData.currency_id ?? '';
        request.fields['purchase_code'] = companyData.purchase_code ?? '';
        request.fields['supported_until'] = companyData.supported_until ?? '';
        request.fields['date'] = DateTime.now().toString();
      }else{
        request.fields['id'] = companyData.id.toString();
        request.fields['company_name'] = companyData.company_name!;
        request.fields['company_email'] = companyData.company_email!;
        request.fields['company_phone'] = companyData.company_phone!;
        request.fields['address'] = companyData.address!;
        request.fields['date_format'] = companyData.date_format ?? '';
        request.fields['time_format'] = companyData.time_format ?? '';
        request.fields['website'] = companyData.website ?? '';
        request.fields['timezone'] = companyData.timezone ?? '';
        request.fields['locale'] = companyData.locale ?? '';
        request.fields['latitude'] = companyData.latitude ?? '';
        request.fields['longitude'] = companyData.longitude ?? '';
        request.fields['currency_id'] = companyData.currency_id ?? '';
        request.fields['purchase_code'] = companyData.purchase_code ?? '';
        request.fields['supported_until'] = companyData.supported_until ?? '';
        request.fields['date'] = DateTime.now().toString();
      }

      http.Response response = await http.Response.fromStream(
          await request.send());
      if (response.statusCode == 200) {
        success = true;
      }
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }

  setImages(String folder, String name)async{
    ImageFiles imageFiles;
    var bytes;
    bytes = await obtenerImagenDesdeServidor(folder, name);
    imageFiles = ImageFiles(path: "$host/uploads/$folder/$name",name: name, bytes: bytes, length: bytes.length);
      return imageFiles;

  }

  Future<Company> getCompanyData(BuildContext context) async {
    List<Company> docs=[];
    Company doc = Company();
    try {
      final response = await http.post(
        Uri.parse("$host/getCompany.php"),
      );

      var responseData = json.decode(response.body);

      AppData appData = AppData();

      for (var singleDocument in responseData) {
        doc = Company(
            id: int.parse(singleDocument['id'].toString()),
            company_name: singleDocument['company_name'],
            company_email: singleDocument['company_email'],
            company_phone: singleDocument['company_phone'],
            logo: singleDocument['logo'] == null || singleDocument['logo'] == 'null' || singleDocument['logo'] ==''
                ? null
                : await setImages('company',singleDocument['logo']),
            address: singleDocument['address'],
            date_format: singleDocument['date_format'],
            time_format: singleDocument['time_format'],
            website: singleDocument['website'],
            timezone: singleDocument['timezone'],
            locale: singleDocument['locale'],
            latitude: singleDocument['latitude'],
            longitude: singleDocument['longitude'],
            currency_id: singleDocument['currency_id'],
            purchase_code: singleDocument['purchase_code'],
            cash_time_control_status:singleDocument['cash_time_control_status'],
            supported_until: singleDocument['supported_until'],
            created_at: singleDocument['created_at'],
            updated_at: singleDocument['updated_at']
        );
        appData.setCompanyData(doc);
        docs.add(doc);
      }
      getTaxData(context);
    }catch(e){

    }
    return doc;
  }

  Future<bool> updateTaxes({required BuildContext context,required Taxes taxData}) async {

    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateTaxes.php"),
          body: {
            'id': taxData.id.toString(),
            'tax_name': taxData.tax_name.toString(),
            'status': taxData.status.toString(),
            'percent': taxData.percent.toString(),
            'date': DateTime.now().toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<List<Taxes>> getTaxData(BuildContext context) async {
    List<Taxes> docs=[];
    try {
      final response = await http.post(
        Uri.parse("$host/getTaxData.php"),
      );

      var responseData = json.decode(response.body);

      Taxes doc;
      AppData appData = AppData();

      for (var singleDocument in responseData) {
        doc = Taxes(
            id: int.parse(singleDocument['id'].toString()),
            tax_name: singleDocument['tax_name'],
            percent: double.parse(singleDocument['percent']),
            status: singleDocument['status'],
            created_at: singleDocument['created_at'],
            updated_at: singleDocument['updated_at']
        );
        if(singleDocument['status']=='active') appData.setTaxData(doc);
        docs.add(doc);
      }
    }catch(e){
    }
    return docs;
  }

  Future<List> getCurrencies(BuildContext context) async {
    List<Currencies> docs=[];
    try {
      final response = await http.post(
        Uri.parse("$host/getCurrencies.php"),
      );

      var responseData = json.decode(response.body);

      Currencies doc;

      for (var singleDocument in responseData) {
        doc = Currencies(
            id: int.parse(singleDocument['id'].toString()),
            currency_name: singleDocument['currency_name'],
            currency_code: singleDocument['currency_code'],
            currency_symbol: singleDocument['currency_symbol'],
            created_at: singleDocument['created_at'],
            updated_at: singleDocument['updated_at']
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }

  Future<bool> updateCurrencies({required BuildContext context,required Currencies currencyData}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateCurrencies.php"),
          body: {
            'id': currencyData.id.toString(),
            'currency_name': currencyData.currency_name.toString(),
            'currency_code': currencyData.currency_code.toString(),
            'currency_symbol': currencyData.currency_symbol.toString(),
            'date': DateTime.now().toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<bool> addCurrency({required BuildContext context,required Currencies currency}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addCurrency.php"),
          body: {
            'currency_name': currency.currency_name.toString(),
            'currency_code': currency.currency_code.toString(),
            'currency_symbol': currency.currency_symbol.toString(),
            'date': DateTime.now().toString()
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<bool> deleteCurrency({required BuildContext context,required int id}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteCurrency.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }
  Future<List<dynamic>> getModules({
    required Function(String) onError,
    required BuildContext context,
    required String level_id,
  }) async {
    List<dynamic> docs = [];
    try{
      final response = await http.post(
          Uri.parse("$host/get_modules.php"),
          body:{
            'role_id'     : level_id.toString(),
          }
      );

      var responseData = json.decode(response.body);
      docs = responseData;
    }catch(e){

    }
    return docs;
  }
  Future<List> getPermission(BuildContext context, int levelId) async {
    List<LevelPermission> docs=[];
    try {
      final response = await http.post(
          Uri.parse("$host/getPermission.php"),
          body: {
            'role_id' : levelId.toString()
          }
      );
      var responseData = json.decode(response.body);

      LevelPermission doc;

      for (var singleDocument in responseData) {
        doc = LevelPermission(
          module_id: int.parse(singleDocument['module_id'].toString()),
          permission_id: int.parse(singleDocument['permission_id'].toString()),
          has_permission: int.parse(singleDocument['has_permission'].toString()),
          permission_name: singleDocument['permission_name'],
          module_display_name: singleDocument['module_display_name'],
          module_name: singleDocument['module_name'],
        );
        docs.add(doc);
      }
    }catch(e){
    }
    return docs;
  }

  Future<bool> addPermission(Function(String) onError, BuildContext context,int permissionId, int levelId ) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addPermission.php"),
          body: {
            'permission_id': permissionId.toString(),
            'role_id': levelId.toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }

  Future<bool> revokePermission(Function(String) onError, BuildContext context,int permissionId, int levelId ) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/revokePermission.php"),
          body: {
            'permission_id': permissionId.toString(),
            'role_id': levelId.toString(),
          }
      );

      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }

  Future<bool> addAllPermissions(Function(String) onError, BuildContext context,int levelId ) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addAllPermissions.php"),
          body: {
            'role_id': levelId.toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
    }
    return success;
  }

  Future<bool> revokeAllPermissions(Function(String) onError, BuildContext context,int levelId ) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/revokeAllPermissions.php"),
          body: {
            'role_id': levelId.toString(),
          }
      );

      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }

  Future<List> getCarrousel(BuildContext context) async {
    List<CarrouselImages> docs=[];
    CarrouselImages doc;
    try {
      final response = await http.post(
        Uri.parse("$host/getCarrousel.php"),
      );
      var responseData = json.decode(response.body);

      for (var singleDocument in responseData) {
        doc = CarrouselImages(
          id: int.parse(singleDocument['id'].toString()),
          updated_at: singleDocument['updated_at'].toString(),
          created_at: singleDocument['created_at'].toString(),
          file_name: singleDocument['file_name']!=null&&singleDocument['file_name']!='null'&&singleDocument['file_name']!=''? await setImages("carousel", singleDocument['file_name']):null,
        );
        docs.add(doc);
      }

    }catch(e){

    }
    return docs;
  }

  Future<bool> deleteCarousel(BuildContext context,int id ) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/deleteCarrousel.php"),
          body: {
            'id': id.toString(),
          }
      );

      var responseData = json.decode(response.body);
      if (responseData['success'] == 'true') success = true;
    }catch(e){

    }
    return success;
  }

  Future<bool> addCarousel({required BuildContext context,Stream<List<int>>? file,
    required int imageLength, required String imageName,}) async {
    bool success = false;
    try {
      var uri = Uri.parse("$host/addCarrousel.php");
      var request = http.MultipartRequest("POST", uri);
      http.ByteStream stream;
      var length = imageLength;
      if (file != null) {
        stream = http.ByteStream(
            DelegatingStream.typed(file));

        String imageName = '${DateTime
            .now()
            .day}cl2dq1${DateTime
            .now()
            .month}4dc3${DateTime
            .now()
            .year}2oh${DateTime
            .now()
            .minute}kh0d002wf1${DateTime
            .now()
            .second}';
        var multipartFile = http.MultipartFile(
            "image", stream, length, filename: '$imageName.jpeg');

        request.files.add(multipartFile);
        request.fields['date'] = DateTime.now().toString();
      }
      http.Response response = await http.Response.fromStream(
          await request.send());

      if (response.statusCode == 200) {
        success = true;
      }
    }catch(e){
      CustomSnackBar().show(
          msg: 'No se pudo establecer conexión con el servidor',
          color: Colors.red,
          context: context,
          icon: Icons.error_rounded
      );
    }
    return success;
  }

  Future<List> getFreeChair({required BuildContext context, required String date}) async {
    List<Chairs> docs=[];
    try {
      final response = await http.post(
        Uri.parse("$host/getFreeChair.php"),
        body: {
          'date' : date.toString(),
        }
      );

      var responseData = json.decode(response.body);

      Chairs doc;

      for (var singleDocument in responseData) {

        doc = Chairs(
          chair_id: int.parse(singleDocument['chair_id'].toString()),
          employee_id: singleDocument['employee_id']!='1'?int.parse(singleDocument['employee_id'].toString()):0,
          chair_name: singleDocument['chair_name'].toString(),
          status: singleDocument['status'].toString(),
          employee_image: singleDocument['employee_image']!=null? await setImages("users", singleDocument['employee_image']):null,
          employee_name: singleDocument['employee_id']!='1'?singleDocument['employee_name'].toString():'Sin asignar',

        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }

  Future<List> getChairs({required BuildContext context}) async {
    List<Chairs> docs=[];
    try {
      final response = await http.get(
          Uri.parse("$host/getChairs.php"),
      );

      var responseData = json.decode(response.body);

      Chairs doc;

      for (var singleDocument in responseData) {
        doc = Chairs(
          chair_id: int.parse(singleDocument['chair_id'].toString()),
          employee_id: singleDocument['employee_id']!='1'?int.parse(singleDocument['employee_id'].toString()):0,
          chair_name: singleDocument['chair_name'].toString(),
          status: singleDocument['status'].toString(),
          color: singleDocument['color'].toString(),
          employee_name: singleDocument['employee_id']!='1'?singleDocument['employee_name'].toString():'Sin asignar',

        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }

  Future<bool> deleteChair({required BuildContext context, required int chairId}) async {
    bool result = false;
    try {
      final response = await http.post(
        Uri.parse("$host/deleteChair.php"),
        body: {
          'id' : chairId.toString()
        }
      );
      var responseData = json.decode(response.body);

      if(responseData['success']=='true')result=true;

    }catch(e){
      print(e);
    }
    return result;
  }

  Future<bool> addChair({required BuildContext context, required Chairs chair}) async {
    bool result = false;
    try {
      final response = await http.post(
          Uri.parse("$host/addChair.php"),
          body: {
            'chair_name' : chair.chair_name.toString(),
            'employee_id' : chair.employee_id.toString(),
            'color' : chair.color.toString(),
            'status' : chair.status.toString(),
            'date' : DateTime.now().toString(),
          }
      );

      var responseData = json.decode(response.body);

      if(responseData['success']=='true')result=true;

    }catch(e){

    }
    return result;
  }

  Future<bool> updateChair({required BuildContext context, required Chairs chair}) async {
    bool result = false;
    try {
      final response = await http.post(
          Uri.parse("$host/updateChair.php"),
          body: {
            'chair_id' : chair.chair_id.toString(),
            'color' : chair.color.toString(),
            'chair_name' : chair.chair_name.toString(),
            'employee_id' : chair.employee_id.toString(),
            'status' : chair.status.toString(),
          }
      );

      var responseData = json.decode(response.body);

      if(responseData['success']=='true')result=true;

    }catch(e){

    }
    return result;
  }

  Future<List> getGroupUsers(BuildContext context, int group) async {
    List<User> docs=[];
    try {
      final response = await http.post(
        Uri.parse("$host/getGroupUsers.php"),
      );

      var responseData = json.decode(response.body);

      User doc;
      for (var singleDocument in responseData) {
        doc = User(
            id: int.parse(singleDocument['id'].toString()),
            name: singleDocument['name'],
        );
        docs.add(doc);
      }
    }catch(e){

    }
    return docs;
  }


  Future<bool> addQuestions({required Function(String) onError, required BuildContext context,required Questions questions}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/add_questions.php"),
          body: {
            'user_id': questions.user_id.toString(),
            'question_1': questions.question_1.toString(),
            'question_2': questions.question_2.toString(),
            'question_3': questions.question_3.toString(),
            'response_1': questions.response_1.toString(),
            'response_2': questions.response_2.toString(),
            'response_3': questions.response_3.toString(),
          }
      );
      var responseData = json.decode(response.body);

      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }

  Future<bool> updateQuestions({required Function(String) onError, required BuildContext context,required Questions questions}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/update_questions.php"),
          body: {
            'user_id': questions.user_id.toString(),
            'question_1': questions.question_1.toString(),
            'question_2': questions.question_2.toString(),
            'question_3': questions.question_3.toString(),
            'response_1': questions.response_1.toString(),
            'response_2': questions.response_2.toString(),
            'response_3': questions.response_3.toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
    }
    return success;
  }

  Future<bool> changePassword({required Function(String) onError, required BuildContext context,required String password, required int isDefaultPass, required int userId}) async {

    bool success = false;
    try {
      String hashedPassword = hashPassword(password.toString());

      var uri = Uri.parse("$host/change_password.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['id'] = userId.toString();
      request.fields['password'] = hashedPassword.toString();
      request.fields['default_pass'] = isDefaultPass.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());

      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
    }
    return success;
  }
  Future<bool> addCashCount({required Function(String) onError, required BuildContext context,required CashCount cashCount}) async {

    bool success = false;
    try {
      var uri = Uri.parse("$host/add_cash_count.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['cash_id']               = cashCount.cash_id.toString();
      request.fields['initial_cash_amount']   = cashCount.initial_cash_amount.toString();
      request.fields['comments']              = cashCount.comments.toString();
      request.fields['open_date']             = cashCount.open_date.toString();
      request.fields['admin_open_id']             = cashCount.admin_open_id.toString();
      request.fields['status']                = cashCount.status.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());

      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
    }
    return success;
  }

  Future<bool> updateCashCount({required Function(String) onError, required BuildContext context, required CashCount cashCount}) async {

    bool success = false;
    try {
      var uri = Uri.parse("$host/update_cash_count.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['id']                    = cashCount.id.toString();
      request.fields['system_final_cash']     = cashCount.system_final_cash.toString();
      request.fields['real_final_cash']       = cashCount.real_final_cash.toString();
      request.fields['diference']             = cashCount.diference.toString();
      request.fields['extraordinary_outflow'] = cashCount.extraordinary_outflow.toString();
      request.fields['comments']              = cashCount.comments.toString();
      request.fields['close_date']            = cashCount.close_date.toString();
      request.fields['admin_close_id']            = cashCount.admin_close_id.toString();
      request.fields['status']                = cashCount.status.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());


      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }
  Future<bool> updateCashRegister({required Function(String) onError, required BuildContext context,required CashRegister cashRegister}) async {

    bool success = false;
    try {

      var uri = Uri.parse("$host/update_cash_register.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['id']          = cashRegister.id.toString();
      request.fields['number'] = cashRegister.number.toString();
      request.fields['name']        = cashRegister.name.toString();
      request.fields['user_id']        = cashRegister.user_id.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());

      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
    }
    return success;
  }

  Future<bool> addCashRegister({required Function(String) onError, required BuildContext context,required CashRegister cashRegister}) async {

    bool success = false;
    try {

      var uri = Uri.parse("$host/add_cash_register.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['number'] = cashRegister.number.toString();
      request.fields['name']        = cashRegister.name.toString();
      request.fields['user_id']        = cashRegister.user_id.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());


      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }
  Future<bool> addAdminCashValidator({required Function(String) onError, required int userId}) async {

    bool success = false;
    try {

      var uri = Uri.parse("$host/add_admin_cash_validator.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['user_id']        = userId.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());


      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){

    }
    return success;
  }
  Future<bool> addInvoice({required Function(String) onError,required String procedure, required BuildContext context,required Invoice invoice}) async {
    bool success = false;

    try {

      var uri = Uri.parse("$host/add_invoice.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['invoice_number']    = invoice.invoice_number.toString();
      request.fields['booking_id']    = invoice.booking_id.toString();
      request.fields['date_time']         = invoice.date_time.toString();
      request.fields['user_id']           = invoice.user_id.toString();
      request.fields['customer_id']       = invoice.customer_id.toString();
      request.fields['invoice_type']      = invoice.invoice_type.toString();
      request.fields['customer_rnc']      = invoice.customer_rnc.toString();
      request.fields['social_reason']     = invoice.social_reason.toString();
      request.fields['cash_id']           = invoice.cash_id.toString();
      request.fields['order_type']        = invoice.order_type.toString();
      request.fields['payment_method']    = invoice.payment_method.toString();
      request.fields['payment_way']       = invoice.payment_way.toString();
      request.fields['discount_percent']  = invoice.discount_percent.toString();
      request.fields['discount_total']    = invoice.discount_total.toString();
      request.fields['total_taxes']       = invoice.total_taxes.toString();
      request.fields['subtotal']          = invoice.subtotal.toString();
      request.fields['total_amount']      = invoice.total_amount.toString();
      request.fields['total_card']        = invoice.total_card.toString();
      request.fields['total_transfers']        = invoice.total_transfers.toString();
      request.fields['total_cash']        = invoice.total_cash.toString();
      request.fields['total_deposit']        = invoice.total_deposit.toString();
      request.fields['total_check']        = invoice.total_check.toString();
      request.fields['payment_status']    = invoice.payment_status.toString();
      request.fields['invoice_details']   = jsonEncode(invoice.invoiceDetail);
      request.fields['procedure']         = procedure;

      http.Response response = await http.Response.fromStream(
          await request.send());

      print(response.body);

      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
      print(e);
    }
    return success;
  }
  Future<bool> updateInvoiceStatus({required Function(String) onError, required int id, required String status}) async {
    bool success = false;
    try {
      final response = await http.post(
          Uri.parse("$host/update_invoice_status.php"),
          body: {
            'id': id.toString(),
            'status': status.toString(),
          }
      );
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
      if (kDebugMode) {
        print(e);
      }
    }
    return success;
  }

  Future<bool> updateInventoryLocation({required Function(String) onError, required BuildContext context,required int productId, required String location}) async {

    bool success = false;
    try {

      var uri = Uri.parse("$host/update_inventory_location.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['product_id']      = productId.toString();
      request.fields['location']        = location.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());

      if (kDebugMode) {
        print(response.body);
      }
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
      if (kDebugMode) {
        print('exception: $e');
      }
    }
    return success;
  }
  Future<bool> updateBatch({required Function(String) onError, required BuildContext context,required Batch batch}) async {

    bool success = false;
    try {

      var uri = Uri.parse("$host/update_batch.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['id']              = batch.id.toString();
      request.fields['batch']           = batch.batch.toString();
      request.fields['quantity']        = batch.quantity.toString();
      request.fields['cost']            = batch.cost.toString();
      request.fields['status']          = batch.status.toString();
      request.fields['expiration_date'] = batch.expiration_date.toString();
      request.fields['description']     = batch.description.toString();


      http.Response response = await http.Response.fromStream(
          await request.send());
      if (kDebugMode) {
        print(response.body);
      }
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
      if (kDebugMode) {
        print('exception: $e');
      }
    }
    return success;
  }

  Future<bool> addInventoryMovement({required Function(String) onError, required BuildContext context,required int userId,required InventoryMovement inventoryMovement}) async {

    bool success = false;
    try {

      var uri = Uri.parse("$host/add_inventory_movement.php");

      var request = http.MultipartRequest("POST", uri);

      request.fields['product_id']        = inventoryMovement.product!.id.toString();
      request.fields['user_id']           = userId.toString();
      request.fields['quantity']          = inventoryMovement.quantity.toString();
      request.fields['movement']          = inventoryMovement.movement.toString();
      request.fields['cost']              = inventoryMovement.cost.toString();
      request.fields['batch']             = inventoryMovement.batch!.batch.toString();
      request.fields['expiration_date']   = inventoryMovement.expiration_date.toString();
      request.fields['concept']           = inventoryMovement.concept.toString();
      request.fields['description']       = inventoryMovement.description.toString();

      http.Response response = await http.Response.fromStream(
          await request.send());

      if (kDebugMode) {
        print(response.body);
      }
      var responseData = json.decode(response.body);
      if (responseData['success']=='true') {
        success=true;
      }else{
        onError(responseData['error']);
      }
    }catch(e){
      if (kDebugMode) {
        print('exception: $e');
      }
    }
    return success;
  }
}