import 'dart:async';
import 'package:flutter/material.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class AutoBannerSlider extends StatefulWidget {
  const AutoBannerSlider({super.key});

  @override
  State<AutoBannerSlider> createState() => _AutoBannerSliderState();
}

class _AutoBannerSliderState extends State<AutoBannerSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _timer;

  final List<String> images = [
    "assets/images/diu_2.jpg",
    "assets/images/diu_3.jpg",
    "assets/images/diu_4.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _currentIndex = (_currentIndex + 1) % images.length;
      if (_controller.hasClients) {
        _controller.animateToPage(_currentIndex, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (_, index) => _banner(images[index]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            images.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 14 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentIndex == index ? primaryTeal : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _banner(String image) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
    );
  }
}
