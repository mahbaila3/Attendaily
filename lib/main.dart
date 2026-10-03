
import 'package:attendaily/addBatch.dart';
import 'package:attendaily/notification_service.dart';

import 'package:attendaily/batchDetail.dart';
import 'package:attendaily/batchPage.dart';
import 'package:attendaily/first.dart';
import 'package:attendaily/onBoard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendaily/login/checkuser.dart';
import 'package:attendaily/login/login_Page.dart';
import 'package:attendaily/login/signup_Page.dart';
import 'package:attendaily/navigation.dart';
import 'package:attendaily/privacy.dart';
import 'package:attendaily/first.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
 WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp(
 options: DefaultFirebaseOptions.currentPlatform,
 );
await NotificationService.initialize();
 final prefs = await SharedPreferences.getInstance();

 final bool onboardingDone =
     prefs.getBool("onboardingDone") ?? false;
 runApp(
   MyApp(
     onboardingDone: onboardingDone,
   ),
 );

}


     class MyApp extends StatefulWidget {
       final bool onboardingDone;

       const MyApp({
         super.key,
         required this.onboardingDone,
       });
      // const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {




      @override
      Widget build(BuildContext context) {

              return MaterialApp(

     title: 'Attendaily',

// Device Preview settings


                home:StartupPage(onboardingDone: widget.onboardingDone),
                theme: ThemeData(
                  brightness: Brightness.light,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.blue,
                    brightness: Brightness.light,
                  ),
                ),

            );
           }
            }


class StartupPage extends StatelessWidget {

  final bool onboardingDone;

  const StartupPage({
    super.key,
    required this.onboardingDone,
  });

  @override
  Widget build(BuildContext context) {

    // ------------------------------------------
    // FIRST INSTALL
    // ------------------------------------------

    if (!onboardingDone) {
      return onBoard();
    }


    // ------------------------------------------
    // ONBOARDING ALREADY COMPLETED
    // ------------------------------------------

    final user = FirebaseAuth.instance.currentUser;


    // ------------------------------------------
    // USER ALREADY LOGGED IN
    // ------------------------------------------

    if (user != null) {
      return navigation();
    }


    // ------------------------------------------
    // NOT LOGGED IN
    // ------------------------------------------

    return loginPage();
  }
}


// ============================================================
// OLD MY HOME PAGE
// ============================================================

class MyHomePage extends StatefulWidget {

  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  logout() async {

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => loginPage(),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),

        actions: [

          TextButton(

            onPressed: () {
              logout();
            },

            child: const Text(
              "LogOut",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ),

        ],
      ),
    );
  }
}



//class MyHomePage extends StatefulWidget {
// const MyHomePage({
// super.key,
// required this.title,
// });
//
// final String title;
//
// @override
// State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//
//   logout()async{
//     FirebaseAuth.instance.signOut().then((value){
//       Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => loginPage(),));
//     });
//   }
// @override
// Widget build(BuildContext context) {
// return Scaffold(
// appBar: AppBar(
// backgroundColor:
// Theme.of(context).colorScheme.inversePrimary,
// title: Text(widget.title),
// actions: [TextButton(onPressed: (){logout();}, child: Text("LogOut",style: TextStyle(color: Colors.black)   ,))],),
// );
// }
//    }