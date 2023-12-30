import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings',
          style: TextStyle(
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Builder(
        builder: (context){
          final themeProvider = Provider.of<ThemeProvider>(context);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: const Text('Light Mode'),
                trailing: Switch(
                  value: themeProvider.isLightMode,
                  onChanged: (value){
                    themeProvider.toggleTheme();
                  },
                ),
              ),
              ListTile(
                title: const Text('Dashboard'),
                onTap: (){
                  Navigator.pushNamed(context, '/dashboard');
                },
              ),
              ListTile(
                title: const Text('Terms of Use'),
                onTap: (){
                  Navigator.pushNamed(context, '/term_of_use');
                },
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: (){
                  Navigator.pushNamed(context, '/privacy_policy');
                },
              ),
              ListTile(
                title: const Text('Reset Password'),
                onTap: (){
                  Navigator.pushNamed(context, '/forgot_password');
                },
              ),
              ListTile(
                title: const Text('About Us'),
                onTap: (){
                  Navigator.pushNamed(context, '/about_us');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
