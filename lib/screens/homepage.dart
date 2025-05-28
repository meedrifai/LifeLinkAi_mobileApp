import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // Configuration de l'animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Animation de la largeur du soulignement
    _widthAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Animation de la couleur du soulignement
    _colorAnimation = ColorTween(
      begin: Colors.redAccent.withOpacity(0.7),
      end: Colors.redAccent,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    // Démarrer l'animation après la construction initiale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE7ED),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image principale
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 8, 24),
                  child: Image.asset(
                    'assets/HomePagePic.png',
                    height: 380,
                  ),
                ),
                const SizedBox(height: 24),

                // Slogan avec ligne animée sous "Lives"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Stack(
                    children: [
                      // Texte complet du slogan
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            TextSpan(text: 'Connecting '),
                            TextSpan(
                              text: 'Lives',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w900,
                                fontSize: 42,
                              ),
                            ),
                            TextSpan(text: ' Through\n'),
                            TextSpan(
                              text: 'Blood Donation',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Line under "Lives"
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 45,
                        child: Center(
                          child: SizedBox(
                            width: 100,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Container(
                                  width: 100,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _colorAnimation.value!.withOpacity(0.0),
                                        _colorAnimation.value!,
                                        _colorAnimation.value!.withOpacity(0.0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _colorAnimation.value!.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Description text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Join us in making a difference. Every drop counts in saving lives.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Bouton Get Started
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.redAccent,
                      elevation: 3,
                      shadowColor: Colors.redAccent.withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}