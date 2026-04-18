import 'package:flutter/material.dart';

class EcommerceBackdrop extends StatelessWidget {
  final Widget child;
  final String imageUrl;

  const EcommerceBackdrop({
    super.key,
    required this.child,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF06120E), Color(0xFF0B2018), Color(0xFF143529)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xDE081712), Color(0xC40B1F18), Color(0xE3122D23)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFFE9C46A).withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -160,
          left: -90,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFF52B788).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
