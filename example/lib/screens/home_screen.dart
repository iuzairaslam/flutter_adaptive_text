import 'package:adaptive_text/adaptive_text.dart';
import 'package:flutter/material.dart';

import 'apca_demo_screen.dart';
import 'extension_demo_screen.dart';
import 'palette_demo_screen.dart';
import 'widget_demo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _darkTiles = [
    Color(0xFF1A237E),
    Color(0xFF1B5E20),
    Color(0xFF4A148C),
  ];

  static const _lightTiles = [
    Color(0xFFFFD600),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
  ];

  static const _demos = [
    _DemoEntry(
      title: 'AdaptiveText Widget',
      subtitle: 'Drop-in Text replacement. Auto black or white on any background.',
      icon: Icons.text_fields_rounded,
      color: Color(0xFF1A237E),
    ),
    _DemoEntry(
      title: 'Palette-Aware',
      subtitle: 'Pick the highest-contrast color from your design system palette.',
      icon: Icons.palette_rounded,
      color: Color(0xFF1B5E20),
    ),
    _DemoEntry(
      title: 'Color Extension',
      subtitle: 'Call .adaptiveTextColor directly on any Color object.',
      icon: Icons.extension_rounded,
      color: Color(0xFF4A148C),
    ),
    _DemoEntry(
      title: 'APCA Algorithm',
      subtitle: 'Perceptual contrast — the WCAG 3.0 standard with Lc values.',
      icon: Icons.science_rounded,
      color: Color(0xFF263238),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHero(),
              const SizedBox(height: 40),
              _buildPreviewSection(),
              const SizedBox(height: 40),
              _buildDemoSection(context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF6D28D9).withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF6D28D9).withOpacity(0.4)),
          ),
          child: const Text(
            'FLUTTER PACKAGE',
            style: TextStyle(
              color: Color(0xFFA78BFA),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'adaptive_text',
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Smart text color that always stays readable —\nWCAG 2.1 & APCA, zero dependencies.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _Pill(label: 'WCAG 2.1'),
            const SizedBox(width: 8),
            _Pill(label: 'APCA'),
            const SizedBox(width: 8),
            _Pill(label: 'Zero deps'),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'ADAPTS TO ANY BACKGROUND'),
        const SizedBox(height: 14),
        _buildTileRow(_darkTiles),
        const SizedBox(height: 8),
        _buildTileRow(_lightTiles),
        const SizedBox(height: 12),
        Text(
          'Black or white chosen automatically based on WCAG luminance.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.35),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTileRow(List<Color> colors) {
    return Row(
      children: colors.map((c) {
        return Expanded(
          child: Container(
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: AdaptiveText(
              'Aa',
              backgroundColor: c,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDemoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: 'DEMOS'),
        const SizedBox(height: 14),
        ...List.generate(_demos.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _DemoCard(
              entry: _demos[i],
              onTap: () => _navigate(context, i),
            ),
          );
        }),
      ],
    );
  }

  void _navigate(BuildContext context, int index) {
    final screens = [
      const WidgetDemoScreen(),
      const PaletteDemoScreen(),
      const ExtensionDemoScreen(),
      const ApcaDemoScreen(),
    ];
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => screens[index]),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.3),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.entry, required this.onTap});
  final _DemoEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF13131A),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: entry.color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: entry.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry.icon,
                  color: entry.color.adaptiveTextColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withOpacity(0.2),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoEntry {
  const _DemoEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
