import 'package:flutter/material.dart';
import '../../components/app_bar.dart';
import '../../components/bottom_navigation.dart';
import '../../components/drawers.dart';
import '../../components/recent_music.dart';
import '../../components/recommended_music.dart';
import '../../services/authservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: const MyDrawer(),

      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            SizedBox(height: 50),

            RecommendedMusicFeature(),

            SizedBox(height: 100),

            RecentMusicFeature(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/library');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/favorites');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/search');
              break;
          }
        },
      ),
    );
  }
}
