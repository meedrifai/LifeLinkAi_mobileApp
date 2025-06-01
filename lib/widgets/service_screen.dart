import 'package:flutter/material.dart';
import '../models/service_data.dart';

class ServiceScreen extends StatelessWidget {
  final ServiceData service;
  final int currentIndex;
  final int totalServices;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const ServiceScreen({
    Key? key,
    required this.service,
    required this.currentIndex,
    required this.totalServices,
    required this.onNext,
    required this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Service icon/image
                    Container(
  width: screenWidth * 0.6,
  height: screenWidth * 0.6,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
    // Remove the background color by not specifying `color`
  ),
  clipBehavior: Clip.hardEdge, // Makes the image respect the border radius
  child: service.imagePath.isNotEmpty
      ? Image.asset(
          service.imagePath,
          fit: BoxFit.cover, // Makes the image fill the container
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackIcon();
          },
        )
      : _buildFallbackIcon(),
),

                    
                    const SizedBox(height: 40),
                    
                    // Service title
                    Text(
                      service.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Service description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        service.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Progress dots
                    _buildProgressIndicator(),
                  ],
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalServices,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == currentIndex
                ? const Color(0xFFE53E3E)
                : const Color(0xFFE53E3E).withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Skip button (bottom)
        Expanded(
          child: OutlinedButton(
            onPressed: onSkip,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE53E3E)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Skip All',
              style: TextStyle(
                color: Color(0xFFE53E3E),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Next button
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              currentIndex == totalServices - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackIcon() {
    IconData iconData;
    switch (currentIndex) {
      case 0:
        iconData = Icons.chat_bubble_outline;
        break;
      case 1:
        iconData = Icons.location_on_outlined;
        break;
      case 2:
        iconData = Icons.analytics_outlined;
        break;
      case 3:
        iconData = Icons.manage_accounts_outlined;
        break;
      case 4:
        iconData = Icons.inventory_outlined;
        break;
      case 5:
        iconData = Icons.trending_up_outlined;
        break;
      default:
        iconData = Icons.favorite_outline;
    }

    return Icon(
      iconData,
      size: 80,
      color: const Color(0xFFE53E3E).withOpacity(0.8),
    );
  }
}