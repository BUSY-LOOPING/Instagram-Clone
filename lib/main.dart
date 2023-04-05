import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/private_keys.dart';
import 'package:instagram_clone/providers/user_profile_provider.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/screens/confirm_otp_screen.dart';
import 'package:instagram_clone/screens/edit_profile_screen.dart';
import 'package:instagram_clone/screens/home_screen.dart';
import 'package:instagram_clone/screens/login_screen.dart';
import 'package:instagram_clone/screens/name_password_screen.dart';
import 'package:instagram_clone/screens/new_post_screen.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/screens/select_post_screen.dart';
import 'package:instagram_clone/screens/pick_profile_pic.dart';
import 'package:instagram_clone/screens/pick_username_screen.dart';
import 'package:instagram_clone/screens/signup_screen.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //makes sure widgets are initialized
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FIREBASE_OPTIONS,
    );
  } else {
    await Firebase.initializeApp();
  }
  GestureBinding.instance.resamplingEnabled = true;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var initialRoute = LoginScreen.routeName;
    if (AuthMethods().getCurrentUser() != null &&
        AuthMethods().getCurrentUser()!.email != null) {
      initialRoute = '/home';
    }
    // initialRoute = CommentsScreen.routeName;

    var transparentColor = Colors.transparent;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(
          key: ValueKey('1'),
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          key: ValueKey('2'),
          create: (_) => UserProfileProvider(),
        )
      ],
      child: MaterialApp(
        initialRoute: initialRoute,
        routes: {
          LoginScreen.routeName: (context) => LoginScreen(),
          SignUpScreen.routeName: (context) => SignUpScreen(),
          ConfirmOtpScreen.routeName: (context) => ConfirmOtpScreen(),
          '/home': (context) => HomeScreen(),
          '/namePassword': (context) => NamePasswordScreen(),
          '/pickUsername': (context) => PickUserNameScreen(),
          '/pickProfilePic': (context) => PickProfilePicScreen(),
          '/selectPost': (context) => SelectPostScreen(),
          '/newPost': (context) => NewPostScreen(),
          CommentsScreen.routeName: (context) => CommentsScreen(),
          EditProfileScreen.routeName: (context) => EditProfileScreen(),
          ProfileScreen.routeName: (context) => ProfileScreen(),
        },
        // onGenerateRoute: (settings) {
        //   print('settings name ${settings}');
        //   if (settings.name == EditProfileScreen.routeName) {
        //     return PageRouteBuilder(
        //         // fullscreenDialog: true,
        //         settings:
        //             settings, // Pass this to make popUntil(), pushNamedAndRemoveUntil(), works
        //         pageBuilder: (_, __, ___) => EditProfileScreen(),
        //         transitionsBuilder:
        //             (context, animation, secondaryAnimation, child) {
        //           var begin = Offset(0.0, 1.0);
        //           var end = Offset.zero;
        //           var tween =
        //               Tween<Offset>(begin: begin, end: end).animate(animation);
        //           // var offsetAnimation = animation.drive(tween);
        //           return SlideTransition(
        //             position: tween,
        //             child: child,
        //           );
        //         });
        //   } else {
        //     return null;
        //     // return PageRouteBuilder(
        //     //   settings: settings,
        //     //   pageBuilder: (BuildContext context, Animation<double> animation,
        //     //       Animation<double> secondaryAnimation) {
        //     //     return HomeScreen();
        //     //   },
        //     // );
        //   }
        // },

        debugShowCheckedModeBanner: false,
        title: 'Instagram clone',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBgColor,
          highlightColor: transparentColor,
          splashColor: transparentColor,
        ),

        // home: StreamBuilder(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.active) {
        //       print('ConnectionState.active');
        //       if (snapshot.hasData) {
        //         print('ConnectionState.active hasData');
        //         return HomeScreen();
        //       } else if (snapshot.hasError) {
        //         print('ConnectionState.active hasError');
        //         print(snapshot.error);
        //       }
        //     } else if (snapshot.connectionState == ConnectionState.waiting) {
        //       print('ConnectionState.waiting');
        //       return Center(
        //         child: CircularProgressIndicator(
        //           strokeWidth: 2,
        //           color: primaryColor,
        //         ),
        //       );
        //     }
        //     return const LoginScreen();
        //   },
        // ),

        // home: const Scaffold(
        //   body: ResponsiveLayout(
        //     mobileScreenLayout: MobileScreenLayout(),
        //     webScreenLayout: WebScreenLayout(),
        //   ),
        // ),
      ),
    );
  }
}
