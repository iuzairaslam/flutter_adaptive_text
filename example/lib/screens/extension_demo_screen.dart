import 'package:flutter_adaptive_text/flutter_adaptive_text.dart';
import 'package:flutter/material.dart';

class ExtensionDemoScreen extends StatefulWidget {
  const ExtensionDemoScreen({super.key});

  @override
  State<ExtensionDemoScreen> createState() => _ExtensionDemoScreenState();
}

class _ExtensionDemoScreenState extends State<ExtensionDemoScreen> {
  Color _bg = const Color(0xFF4A148C);

  static const List<Color> _swatches = [
    Color(0xFF4A148C),
    Color(0xFF880E4F),
    Color(0xFF1A237E),
    Color(0xFF1B5E20),
    Color(0xFF263238),
    Color(0xFFE65100),
    Color(0xFF000000),
    Color(0xFF37474F),
    Color(0xFFFFFFFF),
    Color(0xFFF9A825),
    Color(0xFF546E7A),
    Color(0xFF6D4C41),
  ];

  @override
  Widget build(BuildContext context) {
    final textColor = _bg.adaptiveTextColor;
    final lum = _bg.relativeLuminance;
    final ratio = _bg.contrastRatioWith(textColor);
    final meetsAa = _bg.meetsWcagWith(textColor);
    final meetsAaa = _bg.meetsWcagWith(textColor, level: WcagLevel.aaa);
    final hex =
        '#${textColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

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
        title: Text(
          'Color Extension',
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHero(textColor, hex),
            const SizedBox(height: 28),
            _buildDivider(textColor),
            _buildProperties(textColor, lum, ratio, meetsAa, meetsAaa),
            const SizedBox(height: 28),
            _buildDivider(textColor),
            _buildColorPicker(textColor),
            const SizedBox(height: 28),
            _buildDivider(textColor),
            _buildCodeSnippet(textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(Color textColor, String hex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Extension API',
          style: TextStyle(
            color: textColor,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Every Color gets adaptive superpowers.',
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textColor.withOpacity(0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hex,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'adaptiveTextColor result',
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProperties(
    Color textColor,
    double lum,
    double ratio,
    bool meetsAa,
    bool meetsAaa,
  ) {
    final adaptiveLabel =
        _bg.adaptiveTextColor == Colors.white ? 'White' : 'Black';
    final props = [
      _Prop('.adaptiveTextColor', adaptiveLabel, highlight: true),
      _Prop('.isLight', '${_bg.isLight}'),
      _Prop('.isDark', '${_bg.isDark}'),
      _Prop('.relativeLuminance', lum.toStringAsFixed(4)),
      _Prop('.contrastRatioWith(…)', '${ratio.toStringAsFixed(2)}:1'),
      _Prop('.meetsWcagWith(…, AA)', '$meetsAa'),
      _Prop('.meetsWcagWith(…, AAA)', '$meetsAaa'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(textColor: textColor, label: 'EXTENSION PROPERTIES'),
        const SizedBox(height: 12),
        ...props.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PropRow(bg: _bg, prop: p),
            )),
      ],
    );
  }

  Widget _buildColorPicker(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(textColor: textColor, label: 'PICK A BACKGROUND'),
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

  Widget _buildCodeSnippet(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(textColor: textColor, label: 'USAGE'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textColor.withOpacity(0.12)),
          ),
          child: Text(
            'final color  = bg.adaptiveTextColor;\nfinal ratio  = bg.contrastRatioWith(other);\nfinal passes = bg.meetsWcagWith(other);\nfinal lum    = bg.relativeLuminance;\nfinal isLight = bg.isLight;\nfinal isDark  = bg.isDark;',
            style: TextStyle(
              color: textColor.withOpacity(0.85),
              fontFamily: 'monospace',
              fontSize: 12.5,
              height: 1.8,
            ),
          ),
        ),
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

class _Prop {
  const _Prop(this.label, this.value, {this.highlight = false});
  final String label;
  final String value;
  final bool highlight;
}

class _PropRow extends StatelessWidget {
  const _PropRow({required this.bg, required this.prop});
  final Color bg;
  final _Prop prop;

  @override
  Widget build(BuildContext context) {
    final textColor = bg.adaptiveTextColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: textColor.withOpacity(prop.highlight ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: textColor.withOpacity(prop.highlight ? 0.2 : 0.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prop.label,
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            prop.value,
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
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
