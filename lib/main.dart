import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lifelinkai/screens/dashboard/donations_page.dart';
import 'package:lifelinkai/screens/dashboard/who_will_donate_page.dart';
import 'package:lifelinkai/screens/dashboard/add_donor_page.dart';
import 'package:lifelinkai/screens/homepage.dart';
import 'package:lifelinkai/screens/login_page.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/providers/auth_provider.dart';
import 'package:lifelinkai/providers/donation_provider.dart';
import 'package:lifelinkai/providers/theme_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LifeLinkAI Mobile App',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            initialRoute: '/',
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  );
                case '/login':
                  return MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  );
                case '/donationsPage':
                  final user = settings.arguments as User;
                  return MaterialPageRoute(
                    builder: (_) => DonationsPage(user: user),
                    maintainState: true,
                  );
                case '/whoWillDonatePage':
                  if (settings.arguments is Map) {
                    final args = settings.arguments as Map;
                    final user = args['user'] as User;
                    return MaterialPageRoute(
                      builder: (_) => WhoWillDonatePage(user: user),
                      maintainState: true,
                    );
                  } else {
                    final user = settings.arguments as User;
                    return MaterialPageRoute(
                      builder: (_) => WhoWillDonatePage(user: user),
                      maintainState: true,
                    );
                  }
                case '/addDonorPage':
                  if (settings.arguments is Map) {
                    final args = settings.arguments as Map;
                    final user = args['user'] as User;
                    return MaterialPageRoute(
                      builder: (_) => AddDonorPage(user: user),
                      maintainState: true,
                    );
                  } else {
                    final user = settings.arguments as User;
                    return MaterialPageRoute(
                      builder: (_) => AddDonorPage(user: user),
                      maintainState: true,
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
        },
      ),
    );
  }
}
