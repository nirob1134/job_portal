import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:job_portal/providers/auth_provider/application_provider.dart';
import 'package:job_portal/providers/auth_provider/event_provider.dart';
import 'package:job_portal/providers/auth_provider/favourite_provider.dart';
import 'package:job_portal/providers/auth_provider/job_provider.dart';
import 'package:job_portal/providers/auth_provider/my_auth_provider.dart';
import 'package:job_portal/providers/auth_provider/transport_application_provider.dart';
import 'package:job_portal/providers/auth_provider/transport_provider.dart';
import 'package:job_portal/utils/route_helper.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

const Color scaffoldBg = Color(0xFFFFFFFF);
const Color primaryTeal = Color(0xFF3CC6C6);
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final navigatorKey = GlobalKey<NavigatorState>();


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}


class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context)=>MyAuthProvider()),
          ChangeNotifierProvider(create: (context)=>JobProvider()),
          ChangeNotifierProvider(create: (context)=>ApplicationProvider()),
          ChangeNotifierProvider(create: (context) => EventProvider()),
          ChangeNotifierProvider(create: (context) => FavouriteProvider()),
          ChangeNotifierProvider(create: (context) => TransportProvider()),
          ChangeNotifierProvider(
            create: (context) => TransportApplicationProvider(
              transportProvider: Provider.of<TransportProvider>(context, listen: false),
            ),
          ),
        ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor:scaffoldBg,
        ),
        routes: RouteHelper.routes(),
        scaffoldMessengerKey: scaffoldMessengerKey,
        navigatorKey: navigatorKey,
      ),
    );
  }

}

