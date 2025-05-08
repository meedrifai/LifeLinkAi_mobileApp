import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lifelinkai/screens/dashboard/donations_page.dart';
import 'package:lifelinkai/screens/dashboard/who_will_donate_page.dart';
import 'package:lifelinkai/screens/homepage.dart';
import 'package:lifelinkai/screens/login_page.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/providers/donor_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => DonorProvider()..fetchDonors(),
        ),
        // Add other providers here if needed
      ],
      child: MaterialApp(
        title: 'LifeLinkAI Mobile App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
          useMaterial3: true,
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/login': (context) => const LoginScreen(),
          '/whoWillDonatePage': (context) => const WhoWillDonatePage(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/donationsPage') {
            final user = settings.arguments as User;
            return MaterialPageRoute(builder: (_) => DonationsPage(user: user));
          }
          return null;
        },
      ),
    );
  }
}