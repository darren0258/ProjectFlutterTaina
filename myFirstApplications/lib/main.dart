import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myfirstapplications/page/admin_page.dart';
import 'package:myfirstapplications/page/all_page.dart';
import 'package:myfirstapplications/page/home_page.dart';
import 'package:myfirstapplications/page/login_page.dart';
import 'package:myfirstapplications/page/register_page.dart';
import 'package:myfirstapplications/service/auth_service.dart';
import 'package:myfirstapplications/theme/page_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:provider/provider.dart';
import 'package:myfirstapplications/page/home.dart';
import 'package:myfirstapplications/page/homepage.dart';
import 'package:myfirstapplications/page/record_page.dart';
import 'package:myfirstapplications/page/userpage.dart';
import 'package:myfirstapplications/widget/location.dart';

import 'model/datamodel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(MyApp(
    progress: false,
    origin: const [LatLng(10, 10)],
  ));
}

class MyApp extends StatelessWidget {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final bool progress;
  final List<LatLng> origin;

  MyApp({Key? key, required this.progress, required this.origin})
      : super(key: key);

  void signup() async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
          email: "darren", password: "12345");
    } catch (e) {
      print(e);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataModel(),
      child: FutureBuilder(
          future: firebase,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text("${snapshot.error}"),
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: PageTheme.lightTheme(context),
                  //themeMode: ThemeMode.dark,
                  darkTheme: PageTheme.darkTheme(context),
                  routes: {
                    AllPage.registerRoute: (context) => const RegisterPage(),
                    "/": (context) => const RegisterPage(),
                    AllPage.homeRoute: (context) => const MyHomePage(),
                    AllPage.registerRoute: (context) => const RegisterPage(),
                    AllPage.appRoute: (context) => const RecordPage(),
                    AllPage.adminHomeRoute: (context) => const Home(),
                  });
            }
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }),
    );
  }
}
