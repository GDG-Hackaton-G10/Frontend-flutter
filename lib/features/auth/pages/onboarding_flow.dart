import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:smart_prescription_navigator/core/index.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Scan with Confidence',
      subtitle:
          'Use AI-powered scanning to extract medicine labels with speed and precision.',
      icon: Icons.document_scanner_rounded,
      gradient: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    ),
    _OnboardingPageData(
      title: 'Nearby Pharmacies, Real-time Stock',
      subtitle:
          'Discover nearby pharmacies through a live geospatial map built for urgent care decisions.',
      icon: Icons.map_rounded,
      gradient: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    ),
    _OnboardingPageData(
      title: 'Your Smart Care Command Center',
      subtitle:
          'Track scans, route patients, and streamline workflows from one premium dashboard.',
      icon: Icons.rocket_launch_rounded,
      gradient: [Color(0xFF2563EB), Color(0xFF7C4DFF)],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) {
                    setState(() {
                      _currentIndex = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _OnboardingPage(
                      data: _pages[index],
                      active: index == _currentIndex,
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  spacing: 10,
                  activeDotColor: AppTheme.primary,
                  dotColor: AppTheme.border,
                ),
              ),
              const SizedBox(height: 18),
              AppButton.primary(
                label: isLast ? 'Get Started' : 'Continue',
                leadingIcon: isLast
                    ? Icons.arrow_forward_rounded
                    : Icons.chevron_right_rounded,
                onPressed: _next,
              ),
              const SizedBox(height: 10),
              if (!isLast)
                TextButton(
                  onPressed: widget.onFinished,
                  child: const Text('Skip'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
}

class _OnboardingPage extends StatefulWidget {
  const _OnboardingPage({required this.data, required this.active});

  final _OnboardingPageData data;
  final bool active;

  @override
  State<_OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<_OnboardingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.active) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _OnboardingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) {
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    final subtitleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.85, curve: Curves.easeOut),
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.textPrimary.withValues(alpha: 0.08),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x160F172A),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.data.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -14,
                      bottom: -8,
                      child: Icon(
                        widget.data.icon,
                        size: 180,
                        color: Colors.white.withValues(alpha: 0.22),
                      ),
                    ),
                    Center(
                      child: Icon(
                        widget.data.icon,
                        size: 76,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AnimatedBuilder(
                animation: titleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: titleAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 22 * (1 - titleAnimation.value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.data.title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: subtitleAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: subtitleAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - subtitleAnimation.value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  widget.data.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
