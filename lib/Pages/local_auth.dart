import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../util/states/local_auth_state.dart';
import '../util/Util.dart';

class MyLocalAuth extends StatefulWidget {
  const MyLocalAuth({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyLocalAuthState createState() => _MyLocalAuthState();
}

class _MyLocalAuthState extends State<MyLocalAuth> {

  @override
  void initState() {
    _checkBiometric();
    super.initState();
  }

  final LocalAuthentication _localAuthentication = LocalAuthentication();
  bool _canCheckBiometric = false;
  bool isFistTime = true;
  String _authorizedOrNot = "Not Authorized";
  List<BiometricType> _availableBiometricTypes = <BiometricType>[];

  Future<void> _checkBiometric() async {
    bool canCheckBiometric = false;
    try {
      canCheckBiometric = await _localAuthentication.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometric = canCheckBiometric;
    });
  }

  Future<void> _getListOfBiometricTypes() async {
    late List<BiometricType> listofBiometrics;
    try {
      listofBiometrics = await _localAuthentication.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _availableBiometricTypes = listofBiometrics;
    });
  }

  Future<void> _authorizeNow() async {
    bool isAuthorized = false;
    try {
      isAuthorized = await _localAuthentication.authenticate(
        localizedReason: "Please authenticate to complete your transaction",
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      if (isAuthorized) {

        Provider.of<LocalAuthState>(context, listen: false).setBiometrics(true);
        Provider.of<LocalAuthState>(context, listen: false).closeAuth();

        _authorizedOrNot = "Authorized";
        isFistTime = false;

      } else {
        _authorizedOrNot = "Not Authorized";
        isFistTime = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_canCheckBiometric && _authorizedOrNot == "Not Authorized" && isFistTime){
      _authorizeNow();
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: [
                Image.asset('assets/launcher_icon_base.png',
                    height: displayHeight(context)*0.10,
                    semanticLabel: 'Incomes representation'),
                const SizedBox(height: 50),
                Text("Please unlock to access your finances",
                  style: Theme.of(context).textTheme.titleLarge,),
              ],
            ),

            Column(
              children: [
                Text("Authorized : $_authorizedOrNot"),
                const SizedBox(height: 15.0,),
                InkWell(
                  onTap: (){
                    _authorizeNow();
                  },
                  child: Container(
                    height: 70.0,
                    width: 170.0,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.20),
                      //border: Border.all(color: Colors.blueAccent),
                      borderRadius: BorderRadius.circular(15.0)
                    ),
                    child: const Icon(Icons.fingerprint, color: Colors.grey, size: 60.0,),//Text("Authorize now"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}