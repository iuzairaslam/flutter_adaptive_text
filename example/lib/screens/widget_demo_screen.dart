import 'package:adaptive_text/adaptive_text.dart';
import 'package:flutter/material.dart';

class WidgetDemoScreen extends StatefulWidget {
  const WidgetDemoScreen({super.key});

  @override
  State<WidgetDemoScreen> createState() => _WidgetDemoScreenState();
}

class _WidgetDemoScreenState extends State<WidgetDemoScreen> {
  Color _bg = const Color(0xFF1A237E);

  static const List<Color> _swatches = [
    Color(0xFF1A237E),
    Color(0xFFB71C1C),
    Color(0xFF1B5E20),
    Color(0xFF4A148C),
    Color(0xFF263238),
    Color(0xFFE65100),
    Color(0xFF000000),
    Color(0xFF37474F),
    Color(0xFFFFFFFF),
    Color(0xFFFFF176),
    Color(0xFF80CBC4),
    Color(0xFFFFCDD2),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor = getAdaptiveColor(_bg);
    final ratio = getContrastRatio(textColor, _bg);
    final meetsAa = meetsWcag(textColor, _bg);
    final meetsAaa = meetsWcag(textColor, _bg, level: WcagLevel.aaa);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AdaptiveText(
          'AdaptiveText Widget',
          backgroundColor: _bg,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShowcase(textColor, ratio, meetsAa, meetsAaa),
            const SizedBox(height: 28),
            _buildSwatchPicker(textColor),
            const SizedBox(height: 32),
            _buildDivider(textColor),
            _buildSection(
              textColor: textColor,
              label: 'DIFFERENT TEXT SIZES',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdaptiveText('Heading',
                      backgroundColor: _bg,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 6),
                  AdaptiveText('Body text — always legible on any background.',
                      backgroundColor: _bg,
                      style: const TextStyle(fontSize: 15, height: 1.5)),
                  const SizedBox(height: 6),
                  AdaptiveText('Caption text — even at small sizes.',
                      backgroundColor: _bg,
                      style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildDivider(textColor),
            _buildSection(
              textColor: textColor,
              label: 'ADAPTIVE TEXT THEME',
              child: AdaptiveTextTheme(
                backgroundColor: _bg,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withOpacity(0.12)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AdaptiveText(
                        'Set backgroundColor once on the theme.',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 4),
                      AdaptiveText(
                        'All child AdaptiveText widgets inherit it — no prop needed.',
                        style: TextStyle(fontSize: 12, height: 1.4),
                      ),
                      SizedBox(height: 4),
                      AdaptiveText(
                        'Perfect for entire screens or sections.',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildDivider(textColor),
            _buildSection(
              textColor: textColor,
              label: 'CONTEXT EXTENSION',
              child: AdaptiveTextTheme(
                backgroundColor: _bg,
                palette: const [Colors.amberAccent, Colors.white],
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor.withOpacity(0.12)),
                  ),
                  child: Row(
                    children: [
                      Builder(
                        builder: (ctx) => Icon(
                          Icons.auto_fix_high_rounded,
                          color: ctx.adaptiveForegroundColor(),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: AdaptiveText(
                          'context.adaptiveForegroundColor() works on icons and custom widgets too.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowcase(Color textColor, double ratio, bool meetsAa, bool meetsAaa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdaptiveText(
          'Readable on every background.',
          backgroundColor: _bg,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        AdaptiveText(
          'The color of this text is calculated automatically — no hardcoded values needed.',
          backgroundColor: _bg,
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 16),
        _buildContrastBadge(textColor, ratio, meetsAa, meetsAaa),
      ],
    );
  }

  Widget _buildContrastBadge(Color textColor, double ratio, bool meetsAa, bool meetsAaa) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _badge(
          textColor: textColor,
          label: '${ratio.toStringAsFixed(1)}:1',
          sublabel: 'contrast',
        ),
        _badge(
          textColor: textColor,
          label: meetsAa ? 'AA ✓' : 'AA ✗',
          sublabel: 'WCAG AA',
          highlight: meetsAa,
        ),
        _badge(
          textColor: textColor,
          label: meetsAaa ? 'AAA ✓' : 'AAA ✗',
          sublabel: 'WCAG AAA',
          highlight: meetsAaa,
        ),
        _badge(
          textColor: textColor,
          label: _bg.isLight ? 'Light' : 'Dark',
          sublabel: 'background',
        ),
      ],
    );
  }

  Widget _badge({
    required Color textColor,
    required String label,
    required String sublabel,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: textColor.withOpacity(highlight ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: textColor.withOpacity(highlight ? 0.3 : 0.12),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            sublabel,
            style: TextStyle(
              color: textColor.withOpacity(0.55),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwatchPicker(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BACKGROUND COLOR',
          style: TextStyle(
            color: textColor.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
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
                    color: isSelected ? textColor : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSection({
    required Color textColor,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.4),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDivider(Color textColor) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(bottom: 28),
      color: textColor.withOpacity(0.1),
    );
  }
}
