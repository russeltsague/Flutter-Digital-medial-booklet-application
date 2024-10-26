import 'package:flutter/material.dart';
import 'package:medrec/view/admin_screen.dart';
import 'package:medrec/view/doctor/doctor_home_screen.dart';
import 'package:medrec/view/patient/home_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medrec/view/welcomescreens/welcome_screen1.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: HomeScreen(),
      // home: HomePage(),
      // home: WelcomeScreen1(

      // ),
      debugShowCheckedModeBanner: false,

      title: 'MedRec',

      routes: {
        '/': (context) => WelcomeScreen(),
        '/doctor': (context) => DoctorHomePage(),

        '/home': (context) => HomePage(),

        '/admin': (context) => AdminScreen(), // Add this route for admin role
      },

      initialRoute: '/',
    );
  }
}
