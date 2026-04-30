import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prescription_navigator/core/index.dart';

import '../../../pharmacy_map/presentation/screens/map_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../scanner/presentation/screens/scanner_screen.dart';
import '../../../prescriptions/presentation/providers/prescriptions_provider.dart';
import '../../../prescriptions/data/models/prescription_model.dart';

class BentoHomeScreen extends StatelessWidget {
  const BentoHomeScreen({super.key});

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            sliver: SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120F172A),
                      blurRadius: 26,
                      offset: Offset(0, 14),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.warning.withValues(alpha: 0.95),
                                      const Color(0xFFFFD966),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Good Morning, Daniel',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Your command center is ready. Start a scan and route patients to nearby pharmacies faster.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            scheme.primary.withValues(alpha: 0.9),
                            scheme.tertiary.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.65),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 360;
                  return Container(
                    constraints: const BoxConstraints(minHeight: 264),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          scheme.primary,
                          const Color(0xFF5B6CFA),
                          const Color(0xFF7C4DFF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.36),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x332563EB),
                          blurRadius: 28,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -8,
                          bottom: -14,
                          child: Icon(
                            Icons.document_scanner_outlined,
                            size: 132,
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hero Scan',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scan Prescription',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: isNarrow ? 26 : 30,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 340),
                              child: Text(
                                'Capture labels in one tap, extract medicine names, and jump directly to pharmacies.',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accent.withValues(
                                      alpha: 0.42,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: AppButton.primary(
                                label: 'Launch Scanner',
                                leadingIcon: Icons.camera_alt_rounded,
                                onPressed: () =>
                                    _openScreen(context, const ScannerScreen()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            sliver: SliverToBoxAdapter(
              child: AnimationLimiter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final gap = 14.0;
                    final itemWidth = (width - gap) / 2;
                    final shortHeight = itemWidth * 0.76;
                    final tallHeight = itemWidth * 1.02;

                    final tiles = [
                      _FeatureTile(
                        height: tallHeight,
                        title: 'Nearby Pharmacies',
                        subtitle:
                            'Locate the best-matched pharmacies near your current location.',
                        icon: Icons.local_pharmacy_rounded,
                        iconGradient: [AppTheme.secondary, AppTheme.accent],
                        buttonLabel: 'Open Map',
                        onPressed: () =>
                            _openScreen(context, const MapScreen()),
                      ),
                      _QuickStatsTile(height: shortHeight),
                      _FeatureTile(
                        height: shortHeight,
                        title: 'My Profile',
                        subtitle: 'Health details and preferences.',
                        icon: Icons.person_rounded,
                        iconGradient: [
                          AppTheme.primary,
                          const Color(0xFF7C4DFF),
                        ],
                        buttonLabel: 'Open Profile',
                        onPressed: () =>
                            _openScreen(context, const ProfileScreen()),
                      ),
                      // Prescriptions section (patient)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverToBoxAdapter(
                          child: Consumer(
                            builder: (context, ref, _) {
                              final state = ref.watch(prescriptionsProvider);
                              final theme = Theme.of(context);

                              Widget body;
                              switch (state.status) {
                                case PrescriptionsStatus.loading:
                                  body = const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                  break;
                                case PrescriptionsStatus.error:
                                  body = Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'Error: ${state.errorMessage ?? 'Unknown error'}',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  );
                                  break;
                                case PrescriptionsStatus.empty:
                                  body = Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(
                                        'No prescriptions found.',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                  );
                                  break;
                                case PrescriptionsStatus.loaded:
                                  body = Column(
                                    children: state.items.map((p) {
                                      return Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.border,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Prescription • ${p.createdAt.toLocal().toString().split(' ').first}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              p.medications
                                                  .map((m) => m.name)
                                                  .take(3)
                                                  .join(', '),
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            if (p.notes != null)
                                              Text(
                                                p.notes!,
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  );
                                  break;
                                default:
                                  body = const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Prescriptions',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  body,
                                  const SizedBox(height: 24),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                      _FeatureTile(
                        height: tallHeight,
                        title: 'Scan History',
                        subtitle:
                            'Recent OCR timelines and medicine lookup context.',
                        icon: Icons.history_toggle_off_rounded,
                        iconGradient: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                        buttonLabel: 'View Recent',
                        onPressed: () =>
                            _openScreen(context, const ScannerScreen()),
                      ),
                    ];

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              AnimationConfiguration.staggeredList(
                                position: 0,
                                duration: const Duration(milliseconds: 380),
                                child: SlideAnimation(
                                  verticalOffset: 26,
                                  child: FadeInAnimation(child: tiles[0]),
                                ),
                              ),
                              const SizedBox(height: 14),
                              AnimationConfiguration.staggeredList(
                                position: 1,
                                duration: const Duration(milliseconds: 380),
                                child: SlideAnimation(
                                  verticalOffset: 26,
                                  child: FadeInAnimation(child: tiles[1]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            children: [
                              AnimationConfiguration.staggeredList(
                                position: 2,
                                duration: const Duration(milliseconds: 380),
                                child: SlideAnimation(
                                  verticalOffset: 26,
                                  child: FadeInAnimation(child: tiles[2]),
                                ),
                              ),
                              const SizedBox(height: 14),
                              AnimationConfiguration.staggeredList(
                                position: 3,
                                duration: const Duration(milliseconds: 380),
                                child: SlideAnimation(
                                  verticalOffset: 26,
                                  child: FadeInAnimation(child: tiles[3]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconGradient,
    required this.buttonLabel,
    required this.height,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> iconGradient;
  final String buttonLabel;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: iconGradient),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: iconGradient.last.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: constraints.maxHeight < 180 ? 2 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AppButton.outlined(
                label: buttonLabel,
                onPressed: onPressed,
                fullWidth: true,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickStatsTile extends StatelessWidget {
  const _QuickStatsTile({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Stats',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '3 Saved Pharmacies',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Last scan: 2h ago',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'System Healthy',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
