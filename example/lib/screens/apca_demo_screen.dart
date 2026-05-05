import 'package:flutter_adaptive_text/flutter_adaptive_text.dart';
import 'package:flutter/material.dart';

class ApcaDemoScreen extends StatefulWidget {
  const ApcaDemoScreen({super.key});

  @override
  State<ApcaDemoScreen> createState() => _ApcaDemoScreenState();
}

class _ApcaDemoScreenState extends State<ApcaDemoScreen> {
  Color _bg = const Color(0xFF263238); // blue-grey 900

  static const List<Color> _swatches = [
    Color(0xFF263238),
    Color(0xFF1A237E),
    Color(0xFF880E4F),
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFF4CAF50),
    Color(0xFFF9A825),
    Color(0xFF00ACC1),
    Color(0xFF78909C),
  ];

  @override
  Widget build(BuildContext context) {
    final wcagColor = getAdaptiveColor(_bg, algorithm: ContrastAlgorithm.wcag);
    final apcaColor = getAdaptiveColor(_bg, algorithm: ContrastAlgorithm.apca);

    final wcagRatio = getContrastRatio(wcagColor, _bg);
    final apcaLc = getApcaContrast(apcaColor, _bg);

    final sameResult = wcagColor == apcaColor;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_rounded, color: getAdaptiveColor(_bg)),
          onPressed: () => Navigator.pop(context),
        ),
        title: AdaptiveText(
          'APCA Algorithm',
          backgroundColor: _bg,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Swatch picker
            AdaptiveText('Background:',
                backgroundColor: _bg,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _swatches
                  .map((c) => GestureDetector(
                        onTap: () => setState(() => _bg = c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c == _bg
                                  ? getAdaptiveColor(_bg)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4)
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 28),

            // Side-by-side comparison
            Row(
              children: [
                Expanded(
                    child: _AlgoCard(
                  bg: _bg,
                  label: 'WCAG 2.1',
                  sublabel: 'Contrast ratio',
                  textColor: wcagColor,
                  metricLabel: 'Ratio',
                  metricValue: '${wcagRatio.toStringAsFixed(1)}:1',
                  passBadge: wcagRatio >= 4.5 ? 'AA ✓' : 'Fails AA',
                  passColor: wcagRatio >= 4.5
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                )),
                const SizedBox(width: 10),
                Expanded(
                    child: _AlgoCard(
                  bg: _bg,
                  label: 'APCA',
                  sublabel: 'Lc (perceptual)',
                  textColor: apcaColor,
                  metricLabel: 'Lc',
                  metricValue: apcaLc.toStringAsFixed(1),
                  passBadge: apcaLc.abs() >= 60 ? 'Readable ✓' : 'Low Lc',
                  passColor: apcaLc.abs() >= 60
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                )),
              ],
            ),
            const SizedBox(height: 20),

            // Same/different result notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getAdaptiveColor(_bg).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AdaptiveText(
                sameResult
                    ? 'Both algorithms chose the same color for this background.'
                    : 'The algorithms disagreed on this background — APCA is more perceptually accurate.',
                backgroundColor: _bg,
                style: const TextStyle(fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // APCA explanation
            AdaptiveText(
              'About APCA',
              backgroundColor: _bg,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            AdaptiveText(
              'The Advanced Perceptual Contrast Algorithm (APCA) is proposed for WCAG 3.0. Unlike the WCAG 2.1 ratio, it accounts for spatial frequency, polarity (light-on-dark vs dark-on-light), and human visual perception.\n\nA |Lc| value of ≥ 60 is generally considered readable for body text.',
              backgroundColor: _bg,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 24),

            // Code usage
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getAdaptiveColor(_bg).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: getAdaptiveColor(_bg).withOpacity(0.15)),
              ),
              child: Text(
                '// Opt-in to APCA\nAdaptiveText(\n  \'Hello\',\n  backgroundColor: myBg,\n  algorithm: ContrastAlgorithm.apca,\n)\n\n// Or with the function\ngetAdaptiveColor(myBg, algorithm: ContrastAlgorithm.apca);\n\n// Raw Lc value\ngetApcaContrast(textColor, bgColor);',
                style: TextStyle(
                  color: getAdaptiveColor(_bg).withOpacity(0.8),
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.7,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AlgoCard extends StatelessWidget {
  const _AlgoCard({
    required this.bg,
    required this.label,
    required this.sublabel,
    required this.textColor,
    required this.metricLabel,
    required this.metricValue,
    required this.passBadge,
    required this.passColor,
  });

  final Color bg;
  final String label;
  final String sublabel;
  final Color textColor;
  final String metricLabel;
  final String metricValue;
  final String passBadge;
  final Color passColor;

  @override
  Widget build(BuildContext context) {
    final adaptive = getAdaptiveColor(bg);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: adaptive.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: adaptive.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: adaptive, fontSize: 13, fontWeight: FontWeight.w800)),
          Text(sublabel,
              style: TextStyle(color: adaptive.withOpacity(0.5), fontSize: 10)),
          const SizedBox(height: 12),
          // Sample text using this algo's color
          Text('Sample text',
              style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Text(metricLabel,
              style: TextStyle(color: adaptive.withOpacity(0.5), fontSize: 10)),
          Text(metricValue,
              style: TextStyle(
                  color: adaptive, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: passColor.withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(passBadge,
                style: TextStyle(
                    color: passColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
