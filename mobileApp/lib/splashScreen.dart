import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CIMAGE HACKATHON 2026 — SPLASH SCREEN
// Pure vector + text. No image assets required.
// Drop-in replacement: change context.go('/webview') to your route.
// ═══════════════════════════════════════════════════════════════════════════

class CimageHackathonSplash extends StatefulWidget {
  const CimageHackathonSplash({Key? key}) : super(key: key);

  @override
  State<CimageHackathonSplash> createState() => _CimageHackathonSplashState();
}

class _CimageHackathonSplashState extends State<CimageHackathonSplash>
    with TickerProviderStateMixin {

  // ── Brand palette ──────────────────────────────────────────────────────────
  static const Color _bg         = Color(0xFF07080F);
  static const Color _violet     = Color(0xFF7C3AED);
  static const Color _violetLt   = Color(0xFFA78BFA);
  static const Color _cyan       = Color(0xFF06B6D4);
  static const Color _white      = Color(0xFFFFFFFF);

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _orbCtrl;     // bg orbs breathe
  late AnimationController _hexCtrl;     // hex decorations draw-on
  late AnimationController _iconCtrl;    // </> icon enter
  late AnimationController _ringCtrl;    // sweep ring (infinite)
  late AnimationController _glowCtrl;    // inner glow pulse (infinite)
  late AnimationController _titleCtrl;   // CIMAGE title
  late AnimationController _badgeCtrl;   // badges + tagline
  late AnimationController _loaderCtrl;  // bottom dots (infinite)

  // orbs
  late Animation<double> _orbScale;
  late Animation<double> _orbOpacity;

  // hex
  late Animation<double> _hexProgress;

  // icon
  late Animation<double> _iconFade;
  late Animation<double> _iconScale;

  // ring + glow
  late Animation<double> _ringAngle;
  late Animation<double> _glowPulse;

  // title
  late Animation<double> _titleFade;
  late Animation<double> _titleScale;

  // badges + tagline
  late Animation<double> _badgeFade;
  late Animation<Offset>  _badgeSlide;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    // ── Orb breathe ─────────────────────────────────────────────────────────
    _orbCtrl = AnimationController(
      duration: const Duration(milliseconds: 3400), vsync: this,
    )..repeat(reverse: true);
    _orbScale   = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));
    _orbOpacity = Tween<double>(begin: 0.28, end: 0.48).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    // ── Hex draw-on ─────────────────────────────────────────────────────────
    _hexCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600), vsync: this,
    );
    _hexProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hexCtrl, curve: Curves.easeOut));

    // ── Icon enter ──────────────────────────────────────────────────────────
    _iconCtrl = AnimationController(
      duration: const Duration(milliseconds: 800), vsync: this,
    );
    _iconFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOut));
    _iconScale = Tween<double>(begin: 0.60, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeOutBack));

    // ── Sweep ring (infinite) ────────────────────────────────────────────────
    _ringCtrl = AnimationController(
      duration: const Duration(milliseconds: 2600), vsync: this,
    )..repeat();
    _ringAngle = Tween<double>(begin: 0.0, end: 1.0).animate(_ringCtrl);

    // ── Glow pulse (infinite) ────────────────────────────────────────────────
    _glowCtrl = AnimationController(
      duration: const Duration(milliseconds: 2000), vsync: this,
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Title enter ──────────────────────────────────────────────────────────
    _titleCtrl = AnimationController(
      duration: const Duration(milliseconds: 700), vsync: this,
    );
    _titleFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOut));
    _titleScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(parent: _titleCtrl, curve: Curves.easeOutCubic));

    // ── Badges + tagline ─────────────────────────────────────────────────────
    _badgeCtrl = AnimationController(
      duration: const Duration(milliseconds: 700), vsync: this,
    );
    _badgeFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeCtrl,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut)));
    _badgeSlide = Tween<Offset>(
      begin: const Offset(0, 0.5), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeOutCubic));
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _badgeCtrl,
          curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    // ── Bottom loader ────────────────────────────────────────────────────────
    _loaderCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200), vsync: this,
    )..repeat();

    // ── Sequence ─────────────────────────────────────────────────────────────
    //  100ms → hex decorations start drawing
    //  600ms → </> icon enters
    // 1200ms → CIMAGE title enters
    // 1800ms → badges + tagline enter
    // 3800ms → navigate

    Future.delayed(const Duration(milliseconds: 100),  () { if (mounted) _hexCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 600),  () { if (mounted) _iconCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 1200), () { if (mounted) _titleCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 1800), () { if (mounted) _badgeCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 3800), () { if (mounted) context.go('/webview'); });
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _hexCtrl.dispose();
    _iconCtrl.dispose();
    _ringCtrl.dispose();
    _glowCtrl.dispose();
    _titleCtrl.dispose();
    _badgeCtrl.dispose();
    _loaderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [

          // ── 1. Breathing background orbs ────────────────────────────────
          AnimatedBuilder(
            animation: _orbCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _OrbPainter(
                scale:   _orbScale.value,
                opacity: _orbOpacity.value,
              ),
            ),
          ),

          // ── 2. Static dot grid ───────────────────────────────────────────
          const Positioned.fill(child: _DotGrid()),

          // ── 3. Hex decorations ───────────────────────────────────────────
          AnimatedBuilder(
            animation: _hexCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _HexDecorPainter(progress: _hexProgress.value),
            ),
          ),

          // ── 4. Main content ──────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // ── </> Icon ────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _iconCtrl, _ringCtrl, _glowCtrl,
                    ]),
                    builder: (_, __) => FadeTransition(
                      opacity: _iconFade,
                      child: ScaleTransition(
                        scale: _iconScale,
                        child: SizedBox(
                          width: 144,
                          height: 144,
                          child: CustomPaint(
                            painter: _CodeIconPainter(
                              ringAngle: _ringAngle.value,
                              glow:      _glowPulse.value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── CIMAGE ───────────────────────────────────────────────
                  FadeTransition(
                    opacity: _titleFade,
                    child: ScaleTransition(
                      scale: _titleScale,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [_violetLt, _white, _cyan],
                          stops: [0.0, 0.5, 1.0],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                        child: const Text(
                          'CIMAGE',
                          style: TextStyle(
                            fontSize: 54,
                            fontWeight: FontWeight.w900,
                            color: _white,
                            letterSpacing: 12,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ── Divider line ─────────────────────────────────────────
                  FadeTransition(
                    opacity: _titleFade,
                    child: Container(
                      width: 220,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            _violet.withOpacity(0.7),
                            _cyan.withOpacity(0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── HACKATHON 2026 badge ─────────────────────────────────
                  FadeTransition(
                    opacity: _badgeFade,
                    child: SlideTransition(
                      position: _badgeSlide,
                      child: Column(
                        children: [
                          // Main badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _violet.withOpacity(0.45),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                colors: [
                                  _violet.withOpacity(0.14),
                                  _cyan.withOpacity(0.08),
                                ],
                              ),
                            ),
                            child: const Text(
                              'HACKATHON  2026',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _violetLt,
                                letterSpacing: 4.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Category pills
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              _Pill(label: 'WEB', color: _violet),
                              SizedBox(width: 10),
                              _Pill(label: 'APP', color: _cyan),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Tagline
                          FadeTransition(
                            opacity: _taglineFade,
                            child: Text(
                              'Code  ·  Innovate  ·  Get Hired',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _white.withOpacity(0.35),
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── 5. Bottom: dots loader + venue ──────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: FadeTransition(
                opacity: _taglineFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _loaderCtrl,
                        builder: (_, __) => _DotsLoader(
                          value: _loaderCtrl.value,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CIMAGE Professional College  ·  Patna, Bihar',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: _white.withOpacity(0.20),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.11),
        border: Border.all(color: color.withOpacity(0.35), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

class _DotsLoader extends StatelessWidget {
  const _DotsLoader({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final phase = ((value - i * 0.16) % 1.0).clamp(0.0, 1.0);
        final opacity = (phase < 0.5 ? phase * 2 : (1.0 - phase) * 2)
            .clamp(0.12, 1.0);
        final isViolet = i.isEven;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isViolet
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF06B6D4))
                .withOpacity(opacity),
          ),
        );
      }),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PAINTERS
// ═══════════════════════════════════════════════════════════════════════════

// ── Background orbs ──────────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  const _OrbPainter({required this.scale, required this.opacity});
  final double scale;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawCircle(
      Offset(cx - 90, cy - 170),
      130 * scale,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 95)
        ..color = const Color(0xFF7C3AED).withOpacity(opacity * 0.9),
    );

    canvas.drawCircle(
      Offset(cx + 100, cy + 190),
      110 * scale,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100)
        ..color = const Color(0xFF06B6D4).withOpacity(opacity * 0.6),
    );

    // subtle center glow
    canvas.drawCircle(
      Offset(cx, cy),
      60 * scale,
      Paint()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60)
        ..color = const Color(0xFF7C3AED).withOpacity(opacity * 0.15),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.scale != scale || old.opacity != opacity;
}

// ── Dot grid ─────────────────────────────────────────────────────────────────
class _DotGrid extends StatelessWidget {
  const _DotGrid();
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DotGridPainter(),
        child: const SizedBox.expand(),
      );
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 26.0;
    final paint = Paint()
      ..color = const Color(0x0DFFFFFF)
      ..style = PaintingStyle.fill;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.85, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Hex decorations ───────────────────────────────────────────────────────────
class _HexDecorPainter extends CustomPainter {
  const _HexDecorPainter({required this.progress});
  final double progress;

  void _hex(Canvas canvas, Offset c, double r, Paint p) {
    if (progress <= 0) return;
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = math.pi / 180 * (60 * i - 30);
      final pt = Offset(c.dx + r * math.cos(a), c.dy + r * math.sin(a));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final pv = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7
      ..color = const Color(0xFF7C3AED).withOpacity(0.09 * progress);
    final pc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = const Color(0xFF06B6D4).withOpacity(0.07 * progress);

    _hex(canvas, Offset(cx - 145, cy - 210), 78, pv);
    _hex(canvas, Offset(cx + 155, cy - 175), 52, pv);
    _hex(canvas, Offset(cx + 125, cy + 230), 68, pc);
    _hex(canvas, Offset(cx - 125, cy + 195), 46, pc);
    _hex(canvas, Offset(cx - 40,  cy - 300), 32, pv);
    _hex(canvas, Offset(cx + 55,  cy + 305), 26, pc);
  }

  @override
  bool shouldRepaint(_HexDecorPainter old) => old.progress != progress;
}

// ── </> Code icon ─────────────────────────────────────────────────────────────
class _CodeIconPainter extends CustomPainter {
  const _CodeIconPainter({required this.ringAngle, required this.glow});
  final double ringAngle;
  final double glow;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2 - 5;

    // ── Outer glow ────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
        ..color = const Color(0xFF7C3AED).withOpacity(0.20 * glow),
    );

    // ── Background fill ───────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()..color = const Color(0xFF0D0D1A),
    );

    // ── Dim track ─────────────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xFF7C3AED).withOpacity(0.13),
    );

    // ── Animated sweep arc ────────────────────────────────────────────────
    final arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(
      arcRect,
      ringAngle * 2 * math.pi - math.pi / 2,
      math.pi * 1.15,
      false,
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap  = StrokeCap.round
        ..shader     = SweepGradient(
          colors: [
            const Color(0xFF06B6D4),
            const Color(0xFFA78BFA),
            const Color(0xFF7C3AED),
            const Color(0xFF06B6D4),
          ],
          transform: GradientRotation(ringAngle * 2 * math.pi),
        ).createShader(arcRect),
    );

    // ── Dot riding the arc ────────────────────────────────────────────────
    final dotAngle = ringAngle * 2 * math.pi - math.pi / 2;
    canvas.drawCircle(
      Offset(cx + r * math.cos(dotAngle), cy + r * math.sin(dotAngle)),
      4,
      Paint()..color = const Color(0xFF06B6D4),
    );

    // ── Inner ring accent ─────────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy), r - 12,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..color = const Color(0xFF7C3AED).withOpacity(0.08),
    );

    // ── < left bracket ────────────────────────────────────────────────────
    final bPaint = Paint()
      ..style      = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap  = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color      = const Color(0xFFA78BFA);

    canvas.drawPath(
      Path()
        ..moveTo(cx - 18, cy - 20)
        ..lineTo(cx - 36, cy)
        ..lineTo(cx - 18, cy + 20),
      bPaint,
    );

    // ── > right bracket ───────────────────────────────────────────────────
    canvas.drawPath(
      Path()
        ..moveTo(cx + 18, cy - 20)
        ..lineTo(cx + 36, cy)
        ..lineTo(cx + 18, cy + 20),
      bPaint,
    );

    // ── / slash ───────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(cx + 9, cy - 22),
      Offset(cx - 9, cy + 22),
      Paint()
        ..style      = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap  = StrokeCap.round
        ..color      = const Color(0xFF06B6D4),
    );

    // ── Corner accent dots ────────────────────────────────────────────────
    for (int i = 0; i < 4; i++) {
      final a  = ringAngle * 2 * math.pi + i * math.pi / 2;
      final dx = cx + r * math.cos(a);
      final dy = cy + r * math.sin(a);
      canvas.drawCircle(
        Offset(dx, dy),
        i == 0 ? 3.5 : 1.6,
        Paint()
          ..color = (i == 0
              ? const Color(0xFF06B6D4)
              : const Color(0xFFA78BFA))
              .withOpacity(i == 0 ? 1.0 : 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_CodeIconPainter old) =>
      old.ringAngle != ringAngle || old.glow != glow;
}