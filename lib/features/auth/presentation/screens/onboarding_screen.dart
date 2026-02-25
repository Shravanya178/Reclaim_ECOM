import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Welcome to ReClaim',
      subtitle: 'Transform waste into opportunity',
      description: 'Discover how discarded materials can become the foundation for your next innovative project.',
      imagePath: 'assets/images/onboarding_1.png',
    ),
    const OnboardingPage(
      title: 'Smart Material Detection',
      subtitle: 'AI-powered waste identification',
      description: 'Our advanced AI identifies and categorizes materials, making them instantly discoverable by students.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    const OnboardingPage(
      title: 'Campus Sustainability',
      subtitle: 'Build a greener future',
      description: 'Every reused material saves CO₂ and reduces waste. Join your campus sustainability movement.',
      imagePath: 'assets/images/onboarding_3.png',
    ),
    const OnboardingPage(
      title: 'Get Started',
      subtitle: 'Ready to make an impact?',
      description: 'Join thousands of students and labs creating a circular economy on campus.',
      imagePath: 'assets/images/onboarding_4.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth > 600;
    final maxWidth = isDesktop ? 600.0 : screenWidth;
    
    // Responsive sizing
    final horizontalPadding = isDesktop ? 48.0 : 24.0;
    final imageSize = isDesktop ? 280.0 : screenWidth * 0.6;
    final iconSize = isDesktop ? 120.0 : imageSize * 0.42;
    final titleSize = isDesktop ? 32.0 : 28.0;
    final subtitleSize = isDesktop ? 18.0 : 16.0;
    final bodySize = isDesktop ? 16.0 : 14.0;
    final buttonHeight = isDesktop ? 56.0 : 50.0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
                    child: TextButton(
                      onPressed: () => context.go('/auth'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24.0 : 16.0,
                          vertical: isDesktop ? 12.0 : 8.0,
                        ),
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: isDesktop ? 16.0 : 15.0,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: isDesktop ? 40.0 : 20.0),
                              
                              // Image placeholder
                              Container(
                                width: imageSize,
                                height: imageSize,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(isDesktop ? 24.0 : 20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 20,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.eco_outlined,
                                  size: iconSize,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              
                              SizedBox(height: isDesktop ? 48.0 : 32.0),
                              
                              // Title
                              Text(
                                _pages[index].title,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: isDesktop ? 16.0 : 12.0),
                              
                              // Subtitle
                              Text(
                                _pages[index].subtitle,
                                style: TextStyle(
                                  fontSize: subtitleSize,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: isDesktop ? 20.0 : 16.0),
                              
                              // Description
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 24.0 : 8.0,
                                ),
                                child: Text(
                                  _pages[index].description,
                                  style: TextStyle(
                                    fontSize: bodySize,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              
                              SizedBox(height: isDesktop ? 40.0 : 24.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Page indicators
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isDesktop ? 24.0 : 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _currentPage == index 
                            ? (isDesktop ? 32.0 : 24.0) 
                            : (isDesktop ? 10.0 : 8.0),
                        height: isDesktop ? 10.0 : 8.0,
                        margin: EdgeInsets.symmetric(horizontal: isDesktop ? 6.0 : 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isDesktop ? 5.0 : 4.0),
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    isDesktop ? 40.0 : 24.0,
                  ),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: SizedBox(
                            height: buttonHeight,
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(isDesktop ? 16.0 : 12.0),
                                ),
                              ),
                              child: Text(
                                'Previous',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16.0 : 15.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      
                      if (_currentPage > 0) SizedBox(width: isDesktop ? 20.0 : 16.0),
                      
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                context.go('/auth');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(isDesktop ? 16.0 : 12.0),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                              style: TextStyle(
                                fontSize: isDesktop ? 16.0 : 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  });
}