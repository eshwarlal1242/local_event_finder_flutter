import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../homepages.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/event_3.jpg',
      'title': 'Event Finder',
      'description': 'Welcome to Event Finder! Discover the best events near you.'
    },
    {
      'image': 'assets/event_2.jpg',
      'title': 'Find Events Near You',
      'description': 'Explore music fests, food carnivals, tech talks and more.'
    },
    {
      'image': 'assets/event_1.jpg',
      'title': 'Get Notified Instantly',
      'description': 'Never miss out on events with real-time updates.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [

              const SizedBox(height: 8),

              const SizedBox(height: 30),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          onboardingData[index]['image']!,
                          height: 280,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        onboardingData[index]['title']!,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,

                      ),
                      const SizedBox(height: 14),
                      Text(
                        onboardingData[index]['description']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SmoothPageIndicator(
                controller: _controller,
                count: onboardingData.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: Colors.orange.shade700,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                  expansionFactor: 3,
                ),
              ),
              const SizedBox(height: 30),
              _currentPage == onboardingData.length - 1
                  ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => EventFinderHomePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
                  : const SizedBox(height: 60),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
