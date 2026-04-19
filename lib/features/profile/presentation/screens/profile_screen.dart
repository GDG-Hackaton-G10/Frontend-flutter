import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_prescription_navigator/core/index.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            children: [
              _IdentityCard(theme: theme),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final gap = 12.0;
                    final tileSize = (width - gap) / 2;
                    return AnimationLimiter(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: List.generate(5, (index) {
                            final tiles = [
                              _ActivityTile(
                                size: tileSize,
                                title: 'Scan History',
                                subtitle: '24 records',
                                icon: Icons.history_rounded,
                                gradient: [
                                  AppTheme.primary,
                                  const Color(0xFF5B6CFA),
                                ],
                              ),
                              _ActivityTile(
                                size: tileSize,
                                title: 'Saved Meds',
                                subtitle: '7 tracked',
                                icon: Icons.medication_rounded,
                                gradient: [
                                  AppTheme.secondary,
                                  const Color(0xFF2DD4BF),
                                ],
                              ),
                              _ActivityTile(
                                size: tileSize,
                                title: 'Health Settings',
                                subtitle: 'Updated',
                                icon: Icons.monitor_heart_rounded,
                                gradient: [
                                  const Color(0xFF6366F1),
                                  const Color(0xFF8B5CF6),
                                ],
                              ),
                              _ActivityTile(
                                size: tileSize,
                                title: 'Support',
                                subtitle: '24/7 online',
                                icon: Icons.support_agent_rounded,
                                gradient: [
                                  const Color(0xFFFB7185),
                                  const Color(0xFFF97316),
                                ],
                              ),
                              _ThemeToggleTile(
                                size: tileSize,
                                isDark: isDark,
                                onChanged: (value) {
                                  ref
                                      .read(themeModeProvider.notifier)
                                      .setDarkMode(value);
                                },
                              ),
                            ];

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 360),
                              child: SlideAnimation(
                                verticalOffset: 24,
                                child: FadeInAnimation(child: tiles[index]),
                              ),
                            );
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Theme(
                data: theme.copyWith(
                  outlinedButtonTheme: OutlinedButtonThemeData(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: BorderSide(
                        color: AppTheme.error.withValues(alpha: 0.45),
                      ),
                      foregroundColor: AppTheme.error,
                      backgroundColor: AppTheme.error.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                child: AppButton.outlined(
                  label: 'Log Out',
                  leadingIcon: Icons.logout_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logout action triggered.')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332563EB),
            blurRadius: 24,
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
                Text(
                  'Health Command Center',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Daniel Abebe',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _Badge(text: 'Blood Type: O+'),
                    _Badge(text: 'Member since 2026'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.size,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  final double size;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile({
    required this.size,
    required this.isDark,
    required this.onChanged,
  });

  final double size;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF334155), Color(0xFF0F172A)]
                    : const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Dark Mode',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const Spacer(),
          Switch(value: isDark, onChanged: onChanged),
        ],
      ),
    );
  }
}
