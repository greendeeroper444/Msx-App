import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:msx_app/auths/auth.dart';
import 'package:msx_app/pages/Drawers/create_album.dart';
import 'package:msx_app/pages/Drawers/edit_profile.dart';
import 'package:msx_app/pages/Drawers/messenger.dart';
import 'package:msx_app/pages/Drawers/public_albums.dart';
import 'package:msx_app/pages/Drawers/setting.dart';
import 'package:msx_app/pages/about_us.dart';
import 'package:msx_app/pages/dashboard.dart';
import 'package:msx_app/pages/Bottom_Navigation/favorites.dart';
import 'package:msx_app/pages/Bottom_Navigation/home.dart';
import 'package:msx_app/pages/Bottom_Navigation/library.dart';
import 'package:msx_app/pages/forgot_password.dart';
import 'package:msx_app/pages/privacy_policy.dart';
import 'package:msx_app/pages/Bottom_Navigation/search.dart';
import 'package:msx_app/pages/signin_signup.dart';
import 'package:msx_app/pages/term_of_use.dart';
import 'package:msx_app/providers/theme_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      themeMode: themeProvider.isLightMode ? ThemeMode.light : ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const SigninSignUpPage(),
      routes: {
        '/home': (context) => const HomePage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/profile':(context) => const ProfilePage(),
        '/create_album':(context) => const CreateAlbumPage(),
        '/public_albums':(context) => const PublicPage(),
        '/messenger': (context) => MessengerPage(),
        '/setting':(context) => const SettingPage(),
        '/library': (context) => const LibraryPage(),
        '/favorites': (context) => const FavoritePage(),
        '/search': (context) => const SearchPage(),
        '/term_of_use': (context) => const TermOfUsePage(),
        '/privacy_policy': (context) => const PrivacyPolicyPage(),
        '/about_us': (context) => AboutUsPage(),
        '/dashboard': (context) => DashboardPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/auth') {
          return MaterialPageRoute(
            builder: (context) => const AuthPage(),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
