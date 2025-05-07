import 'package:flutter/material.dart';
import 'package:lifelinkai/screens/dashboard/donations_page.dart';
import 'package:lifelinkai/screens/homepage.dart';
import 'package:lifelinkai/screens/login_page.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/screens/dashboard/who_will_donate_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLinkAI Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/donationsPage':
            final user = settings.arguments as User;
            return MaterialPageRoute(
              builder: (_) => DonationsPage(user: user), 
            );
          case '/whoWillDonatePage':
            final user = settings.arguments as User;
            return MaterialPageRoute(
              builder: (_) => WhoWillDonatePage(user: user),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}