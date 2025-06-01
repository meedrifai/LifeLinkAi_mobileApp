import 'package:flutter/material.dart';
import '../models/service_data.dart';
import '../widgets/service_screen.dart';
import 'options_screen.dart';

class ServiceScreensNavigator extends StatefulWidget {
  const ServiceScreensNavigator({Key? key}) : super(key: key);

  @override
  State<ServiceScreensNavigator> createState() => _ServiceScreensNavigatorState();
}

class _ServiceScreensNavigatorState extends State<ServiceScreensNavigator> {
  int currentServiceIndex = 0;
  
  final List<ServiceData> services = [
    ServiceData(
      title: "AI Chatbot Assistance",
      description: "Get immediate answers to all your blood donation questions through our intelligent ML-powered chatbot.",
      imagePath: "bdbot.png",
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
    ),
    ServiceData(
      title: "Nearest Hospital Finder",
      description: "Locate the closest blood donation centers based on your current location with our smart mapping system.",
      imagePath: "bdmap.png",
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
    ),
    ServiceData(
      title: "Donor Return Prediction",
      description: "Hospitals can forecast donor return likelihood using our XGBoost-based predictive analytics model.",
      imagePath: "bdreq.png",
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
    ),
    ServiceData(
      title: "Hospital Donor Management",
      description: "Secure portal for hospitals to log in, add new donor information, and manage existing donor records.",
      imagePath: "bdmatching.png",
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
    ),
    ServiceData(
      title: "Blood Stock Forecasting",
      description: "Advanced analytics to help donation centers predict and manage their blood supply levels efficiently.",
      imagePath: "bdfor.png",
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
    ),
    ServiceData(
      title: "Donor Engagement Analytics",
      description: "Track donor recency, frequency, and engagement time to optimize blood donation campaigns and outreach.",
      imagePath: "bdana.png",
      backgroundColor: const Color(0xFFE53E3E),
      textColor: Colors.white,
    ),
  ];

  void _nextService() {
    if (currentServiceIndex < services.length - 1) {
      setState(() {
        currentServiceIndex++;
      });
    } else {
      _navigateToOptionsScreen();
    }
  }

  void _skipToOptionsScreen() {
    _navigateToOptionsScreen();
  }

  void _navigateToOptionsScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OptionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ServiceScreen(
      service: services[currentServiceIndex],
      currentIndex: currentServiceIndex,
      totalServices: services.length,
      onNext: _nextService,
      onSkip: _skipToOptionsScreen,
    );
  }
}