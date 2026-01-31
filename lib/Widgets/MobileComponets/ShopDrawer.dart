
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/states/login_state.dart';
import '../../values/ResponsiveApp.dart';
import '../../values/StringApp.dart';

class ShopDrawer extends StatefulWidget {
  const ShopDrawer({Key? key}) : super(key: key);

  @override
  _ShopDrawerState createState() => _ShopDrawerState();
}

class _ShopDrawerState extends State<ShopDrawer> {

  late ResponsiveApp responsiveApp;

  @override
  void initState() {
  }


  @override
  Widget build(BuildContext context) {
    responsiveApp = ResponsiveApp(context);
    return Consumer<LoginState>(
        builder: (context, loginProvider, child1) {
          return SizedBox(
          width: responsiveApp.drawerWidth,
          child: Drawer(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  /*
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      nameStr,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    accountEmail: Text(emailDefautStr),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                    ),
                    currentAccountPicture: const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/default-avatar-user.png"),
                    ),
                  ),

                   */
                  if(loginProvider.isLoggedIn())
                  getItem(
                    onTap: () {
                      kIsWeb?
                      Provider.of<LoginState>(context,listen: false).gotoHome(false)
                      : Navigator.of(context).pushNamed("/MainPage");
                    },
                    title: 'ir a la cuenta',
                    icon: Icons.dataset_sharp,
                  ),
                  getItem(
                      onTap: () {},
                      title: aboutUsStr,
                      icon: Icons.article_outlined,
                  ),
                  getItem(
                    onTap: () {},
                    title: locationStr,
                    icon: Icons.location_on_outlined,
                  ),
                  getItem(
                    onTap: () {
                      Navigator.of(context).pushNamed("/Login");
                    },
                    title: loginStr,
                    icon: Icons.lock_outlined,
                  ),
                  Expanded(
                    child: Padding(
                      padding: responsiveApp.edgeInsetsApp.allMediumEdgeInsets,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          copyrightStr,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  getItem({required String title, required IconData icon, onTap}){
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      leading: Icon(
        icon,
        color: Colors.blueGrey,
      ),
    );
  }
}
