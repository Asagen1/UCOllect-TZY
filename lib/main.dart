import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';

import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/dashboard/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle( 
    statusBarColor: Colors.transparent, 
    statusBarIconBrightness: Brightness.light, 
  ));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
    const MyApp({super.key});

    static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
    static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MantiCol',

          navigatorObservers: [observer],

          routes: {
            '/login': (context) => LoginPage(),
            '/dashboard': (context) => HomePage(),
          },

          theme: ThemeData(
            useMaterial3: true,
          ),

          
          home: const WelcomePage(),
        );
    }
}