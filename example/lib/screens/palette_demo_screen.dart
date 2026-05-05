import 'package:flutter_adaptive_text/flutter_adaptive_text.dart';
import 'package:flutter/material.dart';

class PaletteDemoScreen extends StatefulWidget {
  const PaletteDemoScreen({super.key});

  @override
  State<PaletteDemoScreen> createState() => _PaletteDemoScreenState();
}

class _PaletteDemoScreenState extends State<PaletteDemoScreen> {
  Color _bg = const Color(0xFF1B5E20);

  static const List<Color> _swatches = [
    Color(0xFF1B5E20),
    Color(0xFF1A237E),
    Color(0xFF4A148C),
    Color(0xFF880E4F),
    Color(0xFF263238),
    Color(0xFFE65100),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
  ];

  static const Map<String, List<Color>> _palettes = {
    'Brand': [
      Color(0xFFFF6F00),
      Color(0xFFFFFFFF),
      Color(0xFF80DEEA),
      Color(0xFFFFCDD2),
    ],
    'Pastel': [
      Color(0xFFFFD1DC),
      Color(0xFFC1F0C1),
      Color(0xFFD1E8FF),
      Color(0xFFFFF3B0),
    ],
    'Material': [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.indigo,
      Colors.blue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.yellow,
      Colors.orange,
    ],
  };

  String _activePalette = 'Brand';

  @override
  Widget build(BuildContext context) {
    final adaptive = getAdaptiveColor(_bg);
    final palette = _palettes[_activePalette]!;
    final chosen = getAdaptiveColor(_bg, palette: palette);
    final ratio = getContrastRatio(chosen, _bg);
    final hex =
        '#${chosen.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: adaptive, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AdaptiveText(
          'Palette-Aware',
          backgroundColor: _bg,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultHero(adaptive, chosen, hex, ratio),
            const SizedBox(height: 28),
            _buildDivider(adaptive),
            _buildPaletteSelector(adaptive, palette, chosen),
            const SizedBox(height: 28),
            _buildDivider(adaptive),
            _buildBgPicker(adaptive),
            const SizedBox(height: 28),
            _buildDivider(adaptive),
            _buildLiveSample(palette, adaptive),
          ],
        ),
      ),
    );
  }

  Widget _buildResultHero(
      Color adaptive, Color chosen, String hex, double ratio) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          'Best palette color for this background.',
          backgroundColor: _bg,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: adaptive.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: adaptive.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: chosen,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdaptiveText(
                      hex,
                      backgroundColor: _bg,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StatChip(
                          bg: _bg,
                          label: '${ratio.toStringAsFixed(1)}:1',
                          sublabel: 'ratio',
                        ),
                        const SizedBox(width: 8),
                        _StatChip(
                          bg: _bg,
                          label: meetsWcag(chosen, _bg) ? 'AA ✓' : 'AA ✗',
                          sublabel: 'WCAG',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaletteSelector(
      Color adaptive, List<Color> palette, Color chosen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(textColor: adaptive, label: 'PALETTE'),
        const SizedBox(height: 14),
        Row(
          children: _palettes.keys.map((name) {
            final isActive = name == _activePalette;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _activePalette = name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? adaptive : adaptive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isActive ? _bg : adaptive,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: palette.map((c) {
            final isChosen = c == chosen;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isChosen ? 48 : 36,
              height: isChosen ? 48 : 36,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isChosen ? adaptive : Colors.transparent,
                  width: 2.5,
                ),
                boxShadow: [
                  if (isChosen)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: isChosen
                  ? Icon(Icons.check_rounded,
                      size: 16, color: c.adaptiveTextColor)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBgPicker(Color adaptive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(textColor: adaptive, label: 'BACKGROUND COLOR'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _swatches.map((c) {
            final isSelected = c == _bg;
            return GestureDetector(
              onTap: () => setState(() => _bg = c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? adaptive : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLiveSample(List<Color> palette, Color adaptive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(textColor: adaptive, label: 'LIVE SAMPLE'),
        const SizedBox(height: 12),
        AdaptiveText(
          'This text uses the highest-contrast color from the selected palette. Try switching palettes and backgrounds.',
          backgroundColor: _bg,
          palette: palette,
          style: const TextStyle(fontSize: 15, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildDivider(Color adaptive) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 28),
      color: adaptive.withOpacity(0.1),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.bg, required this.label, required this.sublabel});
  final Color bg;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final adaptive = getAdaptiveColor(bg);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: adaptive.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: adaptive,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              color: adaptive.withOpacity(0.5),
              fontSize: 9,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.textColor, required this.label});
  final Color textColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: textColor.withOpacity(0.4),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}
