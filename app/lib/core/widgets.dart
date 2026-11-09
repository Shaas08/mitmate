import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

/// Five-segment progress bar and label shown on onboarding screens.
class StepHeader extends StatelessWidget {
  const StepHeader({super.key, required this.step, required this.total, required this.label, required this.title, this.subtitle});
  final int step, total;
  final String label, title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (var i = 1; i <= total; i++)
          Expanded(child: Container(
            height: 5,
            margin: EdgeInsets.only(right: i == total ? 0 : 6),
            decoration: BoxDecoration(color: i <= step ? MC.pri : MC.line, borderRadius: BorderRadius.circular(3)),
          )),
      ]),
      const SizedBox(height: 10),
      Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: .8, color: MC.pri)),
      const SizedBox(height: 8),
      Text(title, style: serif(size: 30, weight: FontWeight.w600, height: 1.2)),
      if (subtitle != null) ...[
        const SizedBox(height: 8),
        Text(subtitle!, style: const TextStyle(fontSize: 16, height: 1.5, color: MC.mute)),
      ],
    ]);
  }
}

/// A selectable pill, used for single and multiple choice answers.
class Pill extends StatelessWidget {
  const Pill({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? MC.pri : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: selected ? MC.pri : MC.line, width: 1.5),
          ),
          child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: selected ? Colors.white : MC.ink)),
        ),
      ),
    );
  }
}

/// Single-choice row of pills.
class SinglePills extends StatelessWidget {
  const SinglePills({super.key, required this.options, required this.value, required this.onChanged});
  final Map<String, String> options; // value -> label
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(spacing: 8, runSpacing: 8, children: [
        for (final e in options.entries) Pill(label: e.value, selected: e.key == value, onTap: () => onChanged(e.key)),
      ]);
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      );
}

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: MC.line)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(height: 20), children[i]],
        ]),
      );
}

/// Mitmate wordmark: the first M is a house, the second M is plain coral.
class MitmateWordmark extends StatelessWidget {
  const MitmateWordmark({super.key});
  @override
  Widget build(BuildContext context) {
    final s = GoogleFonts.fraunces(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.0);
    return Semantics(
      label: 'Mitmate',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Stack(clipBehavior: Clip.none, children: [
              Text('M', style: s.copyWith(color: MC.priDeep)),
              const Positioned(left: 1, top: -11, child: CustomPaint(size: Size(32, 12), painter: _RoofPainter())),
            ]),
            Text('it', style: s.copyWith(color: MC.priDeep)),
            Text('M', style: s.copyWith(color: MC.coral)),
            Text('ate', style: s.copyWith(color: MC.coral)),
          ]),
        ),
      ),
    );
  }
}

class _RoofPainter extends CustomPainter {
  const _RoofPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = MC.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(2, size.height - 1)
      ..lineTo(size.width / 2, 2)
      ..lineTo(size.width - 2, size.height - 1);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Looping hero: a profile card swipes right (green YES) then left (red NO).
class SwipeHero extends StatefulWidget {
  const SwipeHero({super.key});
  @override
  State<SwipeHero> createState() => _SwipeHeroState();
}

class _SwipeHeroState extends State<SwipeHero> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 6));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final calm = MediaQuery.of(context).disableAnimations;
    if (calm) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double t, double a, double b) => Curves.easeInOut.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'A profile card swiped right for yes in green, then left for no in red',
      child: SizedBox(
        height: 150,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final dx = 62 * (_seg(t, .06, .22) - _seg(t, .34, .46)) - 62 * (_seg(t, .54, .70) - _seg(t, .82, .94));
            final yes = (_seg(t, .14, .22) - _seg(t, .34, .42)).clamp(0.0, 1.0);
            final no = (_seg(t, .62, .70) - _seg(t, .82, .90)).clamp(0.0, 1.0);
            return Stack(alignment: Alignment.center, children: [
              Positioned(left: 0, top: 35, child: _pill(MC.no, const Color(0xFFF6DCDC), Icons.close_rounded, 1 + .14 * no)),
              Positioned(right: 0, top: 35, child: _pill(MC.yes, const Color(0xFFD9EFE2), Icons.check_rounded, 1 + .14 * yes)),
              Transform.translate(
                offset: Offset(dx, 0),
                child: Transform.rotate(angle: dx / 62 * math.pi / 20, child: _card(yes, no)),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _pill(Color c, Color bg, IconData icon, double scale) => Transform.scale(
        scale: scale,
        child: Container(
          width: 72, height: 80,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: c, width: 2)),
          child: Icon(icon, color: c, size: 36),
        ),
      );

  Widget _card(double yes, double no) => Container(
        width: 144, height: 134,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: MC.line, width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x241B2B26), blurRadius: 16, offset: Offset(0, 6))],
        ),
        child: Stack(children: [
          Column(children: [
            Container(width: 56, height: 56, decoration: const BoxDecoration(color: MC.priSoft, shape: BoxShape.circle), child: const Icon(Icons.person, color: MC.pri, size: 32)),
            const SizedBox(height: 10),
            Container(width: 92, height: 9, decoration: BoxDecoration(color: MC.line, borderRadius: BorderRadius.circular(5))),
            const SizedBox(height: 10),
            Container(width: 68, height: 9, decoration: BoxDecoration(color: MC.line, borderRadius: BorderRadius.circular(5))),
          ]),
          Positioned(left: -4, top: -4, child: Opacity(opacity: yes, child: Transform.rotate(angle: -.17, child: _stamp('YES', MC.yes)))),
          Positioned(right: -4, top: -4, child: Opacity(opacity: no, child: Transform.rotate(angle: .17, child: _stamp('NO', MC.no)))),
        ]),
      );

  Widget _stamp(String t, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: c, width: 2.5)),
        child: Text(t, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c)),
      );
}
