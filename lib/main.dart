import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifelinkai/screens/dashboard/donations_page.dart';
import 'package:lifelinkai/screens/dashboard/who_will_donate_page.dart';
import 'package:lifelinkai/screens/homepage.dart';
import 'package:lifelinkai/screens/login_page.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/models/donor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

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
            return MaterialPageRoute(builder: (_) => DonationsPage(user: user));
          case '/whoWillDonatePage':
            // Handle both direct User object and Map arguments
            if (settings.arguments is Map<String, dynamic>) {
              final args = settings.arguments as Map<String, dynamic>;
              final user = args['user'] as User;
              final donors = args['donors'] as List<Donor>;
              return MaterialPageRoute(
                builder: (_) => WhoWillDonatePage(
                  user: user,
                ),
              );
            } else {
              // For backward compatibility with existing code
              final user = settings.arguments as User;
              // Create an empty list of donors when only user is passed
              return MaterialPageRoute(
                builder: (_) => WhoWillDonatePage(
                  user: user,
                ),
              );
            }
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