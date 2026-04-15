import 'package:flutter/material.dart';

/// Widget that renders the immersive 3D avatar scene using CustomPainter.
/// This gives us zero-dependency 60fps rendering without needing
/// webview_flutter or any native plugin.
///
/// The avatar responds to [mood] changes and shows breathing animation
/// via the ambient animation controller.
class ArAvatarWebView extends StatefulWidget {
  final double progress;
  final String mood;

  const ArAvatarWebView({
    super.key,
    required this.progress,
    required this.mood,
  });

  @override
  State<ArAvatarWebView> createState() => _ArAvatarWebViewState();
}

class _ArAvatarWebViewState extends State<ArAvatarWebView>
    with TickerProviderStateMixin {
  late final AnimationController _ambientController;
  late final AnimationController _blinkController;
  late final AnimationController _swayController;

  @override
  void initState() {
    super.initState();

    // Primary breathing / ambient loop
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Eye blink loop — quick blink every ~3.5s
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _startBlinkLoop();

    // Subtle idle body sway
    _swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  void _startBlinkLoop() async {
    while (mounted) {
      await Future.delayed(
          Duration(milliseconds: 2800 + (DateTime.now().millisecond % 1500)));
      if (!mounted) return;
      await _blinkController.forward();
      if (!mounted) return;
      await _blinkController.reverse();
    }
  }

  @override
  void dispose() {
    _ambientController.dispose();
    _blinkController.dispose();
    _swayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_ambientController, _blinkController, _swayController]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _AvatarScenePainter(
                mood: widget.mood,
                progress: widget.progress,
                ambientT: _ambientController.value,
                blinkT: _blinkController.value,
                swayT: _swayController.value,
              ),
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
              ),
            );
          }
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// High-fidelity custom painter — cinematic 3D-style avatar
// ═══════════════════════════════════════════════════════════════
class _AvatarScenePainter extends CustomPainter {
  final String mood;
  final double progress;
  final double ambientT;
  final double blinkT;
  final double swayT;

  _AvatarScenePainter({
    required this.mood,
    required this.progress,
    required this.ambientT,
    required this.blinkT,
    required this.swayT,
  });

  // ── Palette ──
  static const _skinBase = Color(0xFFF5D0A9);
  static const _skinShadow = Color(0xFFD4A574);
  static const _skinHighlight = Color(0xFFFEE8CC);
  static const _hairDark = Color(0xFF1A0E05);
  static const _hairMid = Color(0xFF2E1B0E);
  static const _eyeWhite = Color(0xFFFAFAFA);
  static const _irisColor = Color(0xFF3B7A57);
  static const _pupilColor = Color(0xFF0D0D0D);
  static const _lipColor = Color(0xFFCC7A6E);
  static const _pantsColor = Color(0xFF1C1C30);
  static const _shoeColor = Color(0xFF1A1A1A);
  static const _shoeSole = Color(0xFF333333);
  static const _beltColor = Color(0xFF2A2A42);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // ── MASSIVE SCALE FIX ──
    // Force the avatar to be extremely large.
    final sW = size.width / 130;
    final sH = size.height / 300;
    final s = sW < sH ? sW : sH;

    // Center Y precisely pushed down to accommodate top-heavy UI
    final cy = size.height * 0.65 - 13.5 * s;
    final groundY = cy + 121 * s;

    // ── Background ──
    _paintBackground(canvas, size, cx, cy);

    // ── Volumetric light rays ──
    _paintLightRays(canvas, size, cx, cy - 60 * s);

    // ── Perspective grid floor ──
    _paintPerspectiveGrid(canvas, size, groundY);

    // ── Ground plane with reflection ──
    _paintGroundPlane(canvas, size, cx, groundY, s);

    // ── Aura / rim backlight ──
    _paintAura(canvas, size, cx, cy, s);

    // ── Ambient particles ──
    _paintParticles(canvas, size);

    // ── Avatar (the main event) ──
    _paintAvatar(canvas, size, cx, cy, groundY, s);

    // ── Floating energy orbs ──
    _paintFloatingOrbs(canvas, size, cx, cy, s);

    // ── Cinematic vignette ──
    _paintVignette(canvas, size);
  }

  // ─────────────────────────────────────────────────────────
  // Background
  // ─────────────────────────────────────────────────────────
  void _paintBackground(Canvas canvas, Size size, double cx, double cy) {
    final bgColors = _bgColors();
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.2),
        radius: 1.4,
        colors: bgColors,
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Subtle secondary ambient glow
    final ambientGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.3),
        radius: 0.8,
        colors: [
          _primaryColor().withValues(alpha: 0.03 + ambientT * 0.02),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), ambientGlow);
  }

  // ─────────────────────────────────────────────────────────
  // Volumetric light rays from above
  // ─────────────────────────────────────────────────────────
  void _paintLightRays(Canvas canvas, Size size, double cx, double originY) {
    final moodColor = _primaryColor();
    final rayPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 5; i++) {
      final angle = -0.4 + i * 0.2 + _sinApprox(ambientT * 3.14 + i) * 0.03;
      final width = 30.0 + i * 8;
      final alpha = 0.015 + ambientT * 0.008;

      final path = Path()
        ..moveTo(cx + _sinApprox(angle) * 20, 0)
        ..lineTo(cx + _sinApprox(angle) * width - width * 0.5, originY + 200)
        ..lineTo(cx + _sinApprox(angle) * width + width * 0.5, originY + 200)
        ..close();

      rayPaint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          moodColor.withValues(alpha: alpha),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, rayPaint);
    }
  }

  // ─────────────────────────────────────────────────────────
  // Perspective grid
  // ─────────────────────────────────────────────────────────
  void _paintPerspectiveGrid(Canvas canvas, Size size, double groundY) {
    final moodColor = _primaryColor();
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = moodColor.withValues(alpha: 0.05);

    // Horizontal lines receding
    for (int i = 0; i < 10; i++) {
      final t = i / 9.0;
      final y = groundY + t * t * (size.height - groundY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical converging lines
    final cx = size.width / 2;
    for (int i = -5; i <= 5; i++) {
      final baseX = cx + i * (size.width * 0.13);
      canvas.drawLine(
        Offset(cx + (baseX - cx) * 0.08, groundY),
        Offset(baseX, size.height),
        gridPaint,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // Ground plane with glow + rings
  // ─────────────────────────────────────────────────────────
  void _paintGroundPlane(
      Canvas canvas, Size size, double cx, double groundY, double s) {
    final moodColor = _primaryColor();

    // Main ground glow
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          moodColor.withValues(alpha: 0.18 + ambientT * 0.08),
          moodColor.withValues(alpha: 0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, groundY),
        width: size.width * 0.75,
        height: 90,
      ));
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, groundY), width: size.width * 0.7, height: 70),
      shadowPaint,
    );

    // Pulsing energy rings
    for (int i = 0; i < 3; i++) {
      final ringScale = 0.40 + i * 0.14 + ambientT * 0.02;
      final ringAlpha = (0.14 - i * 0.035 + ambientT * 0.04).clamp(0.0, 1.0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, groundY),
          width: size.width * ringScale,
          height: 28 + i * 12.0,
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = moodColor.withValues(alpha: ringAlpha),
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // Aura / back-glow
  // ─────────────────────────────────────────────────────────
  void _paintAura(Canvas canvas, Size size, double cx, double cy, double s) {
    final moodColor = _primaryColor();

    // Large diffuse aura
    final auraR = 140.0 * s + ambientT * 25;
    canvas.drawCircle(
      Offset(cx, cy - 10 * s),
      auraR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            moodColor.withValues(alpha: 0.07 + ambientT * 0.03),
            moodColor.withValues(alpha: 0.02),
            Colors.transparent,
          ],
        ).createShader(
            Rect.fromCircle(center: Offset(cx, cy - 10 * s), radius: auraR)),
    );

    // Tight rim-light halo behind head
    final headY = cy - 60 * s;
    canvas.drawCircle(
      Offset(cx, headY),
      42 * s,
      Paint()
        ..shader = RadialGradient(
          colors: [
            moodColor.withValues(alpha: 0.12),
            moodColor.withValues(alpha: 0.03),
            Colors.transparent,
          ],
          stops: const [0.6, 0.85, 1.0],
        ).createShader(
            Rect.fromCircle(center: Offset(cx, headY), radius: 42 * s)),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Particles
  // ─────────────────────────────────────────────────────────
  void _paintParticles(Canvas canvas, Size size) {
    final particleColor = _particleColor();
    final prng = _SeededRandom(42);

    for (int i = 0; i < 80; i++) {
      final px = prng.nextDouble() * size.width;
      final baseY = prng.nextDouble() * size.height;
      final speed = 0.4 + prng.nextDouble() * 1.8;
      final py = (baseY - ambientT * speed * 90) % size.height;
      final radius = 0.8 + prng.nextDouble() * 2.2;
      final alpha = 0.06 + prng.nextDouble() * 0.3;

      canvas.drawCircle(
        Offset(px, py),
        radius,
        Paint()..color = particleColor.withValues(alpha: alpha),
      );

      // Halo on every 4th particle
      if (i % 4 == 0) {
        canvas.drawCircle(
          Offset(px, py),
          radius * 3.5,
          Paint()
            ..color = particleColor.withValues(alpha: alpha * 0.12)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  // Avatar body — the main rendering
  // ─────────────────────────────────────────────────────────
  void _paintAvatar(Canvas canvas, Size size, double cx, double cy,
      double groundY, double s) {
    // Animate
    final breathOffset = _sin01(ambientT) * 3.5 * s;
    final swaySin = _sinApprox(swayT * 3.14159 * 2);
    final swayOffset = swaySin * 2.0 * s;
    final headTilt = swaySin * 0.03;

    final aCy = cy + breathOffset; // avatar center Y (breathing)

    // ── Drop shadow ──
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, groundY + 2 * s),
        width: 95 * s,
        height: 20 * s,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // ── Shirt color from mood ──
    final shirtColor = _primaryColor();
    final shirtShadow = Color.lerp(shirtColor, Colors.black, 0.3)!;
    final shirtHighlight = Color.lerp(shirtColor, Colors.white, 0.2)!;

    // ════════════════════════════════════════
    // SHOES
    // ════════════════════════════════════════
    // Left shoe
    _drawRR(
        canvas, cx - 26 * s, aCy + 100 * s, 23 * s, 16 * s, 6 * s, _shoeColor);
    _drawRR(
        canvas, cx - 26 * s, aCy + 112 * s, 25 * s, 5 * s, 3 * s, _shoeSole);
    // Shoe highlight
    _drawRR(canvas, cx - 22 * s, aCy + 102 * s, 10 * s, 3 * s, 2 * s,
        Colors.white.withValues(alpha: 0.06));

    // Right shoe
    _drawRR(
        canvas, cx + 3 * s, aCy + 100 * s, 23 * s, 16 * s, 6 * s, _shoeColor);
    _drawRR(canvas, cx + 1 * s, aCy + 112 * s, 25 * s, 5 * s, 3 * s, _shoeSole);
    _drawRR(canvas, cx + 7 * s, aCy + 102 * s, 10 * s, 3 * s, 2 * s,
        Colors.white.withValues(alpha: 0.06));

    // ════════════════════════════════════════
    // LEGS (slightly tapered)
    // ════════════════════════════════════════
    // Left leg
    _drawTrapezoid(
        canvas, cx - 20 * s, aCy + 48 * s, 17 * s, 15 * s, 56 * s, _pantsColor);
    // Left leg shadow
    _drawRR(canvas, cx - 20 * s, aCy + 48 * s, 5 * s, 56 * s, 4 * s,
        Colors.black.withValues(alpha: 0.12));
    // Left leg highlight
    _drawRR(canvas, cx - 12 * s, aCy + 50 * s, 4 * s, 40 * s, 3 * s,
        Colors.white.withValues(alpha: 0.04));

    // Right leg
    _drawTrapezoid(
        canvas, cx + 3 * s, aCy + 48 * s, 17 * s, 15 * s, 56 * s, _pantsColor);
    _drawRR(canvas, cx + 16 * s, aCy + 48 * s, 5 * s, 56 * s, 4 * s,
        Colors.black.withValues(alpha: 0.12));
    _drawRR(canvas, cx + 8 * s, aCy + 50 * s, 4 * s, 40 * s, 3 * s,
        Colors.white.withValues(alpha: 0.04));

    // ════════════════════════════════════════
    // BELT
    // ════════════════════════════════════════
    _drawRR(
        canvas, cx - 23 * s, aCy + 40 * s, 46 * s, 10 * s, 4 * s, _beltColor);
    // Belt buckle
    _drawRR(canvas, cx - 4 * s, aCy + 42 * s, 8 * s, 6 * s, 2 * s,
        Colors.white.withValues(alpha: 0.15));

    // ════════════════════════════════════════
    // TORSO (shaped with gradients)
    // ════════════════════════════════════════
    // Main torso
    final torsoRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(cx - 28 * s, aCy - 25 * s, 56 * s, 68 * s),
      topLeft: Radius.circular(16 * s),
      topRight: Radius.circular(16 * s),
      bottomLeft: Radius.circular(8 * s),
      bottomRight: Radius.circular(8 * s),
    );
    canvas.drawRRect(
      torsoRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [shirtHighlight, shirtColor, shirtShadow],
          stops: const [0.0, 0.4, 1.0],
        ).createShader(torsoRect.outerRect),
    );

    // Left torso shadow (3D depth)
    _drawRR(canvas, cx - 28 * s, aCy - 20 * s, 10 * s, 60 * s, 8 * s,
        Colors.black.withValues(alpha: 0.10));
    // Right torso highlight
    _drawRR(canvas, cx + 12 * s, aCy - 15 * s, 8 * s, 40 * s, 6 * s,
        Colors.white.withValues(alpha: 0.06));

    // Collar / V-neck
    final collarPath = Path()
      ..moveTo(cx - 12 * s, aCy - 25 * s)
      ..quadraticBezierTo(cx, aCy - 10 * s, cx + 12 * s, aCy - 25 * s);
    canvas.drawPath(
      collarPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s
        ..strokeCap = StrokeCap.round
        ..color = _skinBase.withValues(alpha: 0.35),
    );
    // Inner skin visible at neckline
    final collarFill = Path()
      ..moveTo(cx - 10 * s, aCy - 25 * s)
      ..quadraticBezierTo(cx, aCy - 14 * s, cx + 10 * s, aCy - 25 * s)
      ..close();
    canvas.drawPath(
        collarFill, Paint()..color = _skinBase.withValues(alpha: 0.5));

    // ════════════════════════════════════════
    // ARMS with mood-based animation
    // ════════════════════════════════════════
    final armSwing = mood == 'happy'
        ? 0.30 + _sin01(ambientT) * 0.20
        : mood == 'sad'
            ? -0.06 + _sin01(ambientT) * 0.02
            : 0.10 + _sin01(ambientT) * 0.05;

    // ── Left arm ──
    canvas.save();
    canvas.translate(cx - 28 * s, aCy - 12 * s);
    canvas.rotate(-armSwing);

    // Upper arm
    final leftUpperArm = RRect.fromRectAndRadius(
      Rect.fromLTWH(-14 * s, 0, 14 * s, 36 * s),
      Radius.circular(7 * s),
    );
    canvas.drawRRect(leftUpperArm, Paint()..color = shirtColor);
    // Arm shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-14 * s, 0, 4 * s, 36 * s),
        Radius.circular(7 * s),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    // Forearm (skin)
    _drawRR(canvas, -12 * s, 34 * s, 12 * s, 28 * s, 6 * s, _skinBase);
    _drawRR(canvas, -12 * s, 34 * s, 4 * s, 28 * s, 4 * s,
        _skinShadow.withValues(alpha: 0.3));

    // Hand
    canvas.drawCircle(
      Offset(-6 * s, 64 * s),
      8.5 * s,
      Paint()..color = _skinBase,
    );
    // Hand highlight
    canvas.drawCircle(
      Offset(-5 * s, 62 * s),
      4 * s,
      Paint()..color = _skinHighlight.withValues(alpha: 0.25),
    );
    // Fingers hint
    for (int f = 0; f < 4; f++) {
      final fx = -10 * s + f * 3 * s;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(fx, 68 * s, 2.5 * s, 5 * s),
          Radius.circular(1.5 * s),
        ),
        Paint()..color = _skinBase,
      );
    }
    // Thumb
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 63 * s, 4 * s, 6 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = _skinBase,
    );

    canvas.restore();

    // ── Right arm ──
    canvas.save();
    canvas.translate(cx + 28 * s, aCy - 12 * s);
    canvas.rotate(armSwing);

    // Upper arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, 14 * s, 36 * s),
        Radius.circular(7 * s),
      ),
      Paint()..color = shirtColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10 * s, 0, 4 * s, 36 * s),
        Radius.circular(7 * s),
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.08),
    );

    // Forearm (skin)
    _drawRR(canvas, 1 * s, 34 * s, 12 * s, 28 * s, 6 * s, _skinBase);
    _drawRR(canvas, 9 * s, 34 * s, 4 * s, 28 * s, 4 * s,
        _skinShadow.withValues(alpha: 0.3));

    // Hand
    canvas.drawCircle(
      Offset(7 * s, 64 * s),
      8.5 * s,
      Paint()..color = _skinBase,
    );
    canvas.drawCircle(
      Offset(8 * s, 62 * s),
      4 * s,
      Paint()..color = _skinHighlight.withValues(alpha: 0.25),
    );
    for (int f = 0; f < 4; f++) {
      final fx = 1 * s + f * 3 * s;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(fx, 68 * s, 2.5 * s, 5 * s),
          Radius.circular(1.5 * s),
        ),
        Paint()..color = _skinBase,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-3 * s, 63 * s, 4 * s, 6 * s),
        Radius.circular(2 * s),
      ),
      Paint()..color = _skinBase,
    );

    canvas.restore();

    // ════════════════════════════════════════
    // NECK
    // ════════════════════════════════════════
    final neckLeft = cx - 10 * s;
    final neckTop = aCy - 36 * s;

    _drawRR(canvas, neckLeft, neckTop, 20 * s, 16 * s, 6 * s, _skinBase);
    // Neck shadow (under jaw)
    _drawRR(canvas, neckLeft, neckTop, 20 * s, 6 * s, 4 * s,
        _skinShadow.withValues(alpha: 0.25));
    // Neck side shadow
    _drawRR(canvas, neckLeft, neckTop + 2 * s, 4 * s, 12 * s, 3 * s,
        _skinShadow.withValues(alpha: 0.15));

    // ════════════════════════════════════════
    // HEAD (with tilt)
    // ════════════════════════════════════════
    canvas.save();
    canvas.translate(cx + swayOffset, aCy - 58 * s);
    canvas.rotate(headTilt);

    const headCx = 0.0;
    const headCy = 0.0;
    final headRx = 28 * s;
    final headRy = 32 * s;

    // Head shape — oval
    final headRect = Rect.fromCenter(
      center: Offset(headCx, headCy),
      width: headRx * 2,
      height: headRy * 2,
    );

    // Head base with gradient
    canvas.drawOval(
      headRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          radius: 1.0,
          colors: [_skinHighlight, _skinBase, _skinShadow],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(headRect),
    );

    // Subtle rim light on right side of face
    final rimPath = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(headCx, headCy),
          width: headRx * 2,
          height: headRy * 2,
        ),
        -1.2,
        1.0,
      );
    canvas.drawPath(
      rimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * s
        ..color = _primaryColor().withValues(alpha: 0.12),
    );

    // ── Ears ──
    // Left ear
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCx - headRx + 2 * s, headCy + 2 * s),
        width: 10 * s,
        height: 16 * s,
      ),
      Paint()..color = _skinBase,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCx - headRx + 3 * s, headCy + 2 * s),
        width: 5 * s,
        height: 9 * s,
      ),
      Paint()..color = _skinShadow.withValues(alpha: 0.3),
    );

    // Right ear
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCx + headRx - 2 * s, headCy + 2 * s),
        width: 10 * s,
        height: 16 * s,
      ),
      Paint()..color = _skinBase,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(headCx + headRx - 3 * s, headCy + 2 * s),
        width: 5 * s,
        height: 9 * s,
      ),
      Paint()..color = _skinShadow.withValues(alpha: 0.3),
    );

    // ── Hair ──
    _paintHair(canvas, headCx, headCy, headRx, headRy, s);

    // ── Eyebrows ──
    _paintEyebrows(canvas, headCx, headCy, s);

    // ── Eyes ──
    _paintEyes(canvas, headCx, headCy, s);

    // ── Nose ──
    _paintNose(canvas, headCx, headCy, s);

    // ── Mouth ──
    _paintMouth(canvas, headCx, headCy + 16 * s, s);

    // ── Mood extras (blush / tears / sparkles) ──
    _paintMoodExtras(canvas, headCx, headCy, s);

    canvas.restore(); // end head tilt
  }

  // ─────────────────────────────────────────────────────────
  // Hair
  // ─────────────────────────────────────────────────────────
  void _paintHair(
      Canvas canvas, double hx, double hy, double rx, double ry, double s) {
    // Top hair volume
    final topHairPath = Path()
      ..moveTo(hx - rx - 2 * s, hy - 6 * s)
      ..quadraticBezierTo(hx - rx, hy - ry - 10 * s, hx, hy - ry - 12 * s)
      ..quadraticBezierTo(
          hx + rx, hy - ry - 10 * s, hx + rx + 2 * s, hy - 6 * s)
      ..quadraticBezierTo(hx + rx + 1 * s, hy - ry + 4 * s, hx, hy - ry + 2 * s)
      ..quadraticBezierTo(
          hx - rx - 1 * s, hy - ry + 4 * s, hx - rx - 2 * s, hy - 6 * s)
      ..close();

    canvas.drawPath(
      topHairPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_hairMid, _hairDark],
        ).createShader(Rect.fromCenter(
          center: Offset(hx, hy - ry),
          width: rx * 2.5,
          height: ry * 1.5,
        )),
    );

    // Hair shine streak
    final shinePath = Path()
      ..moveTo(hx - 8 * s, hy - ry - 6 * s)
      ..quadraticBezierTo(
          hx - 2 * s, hy - ry - 10 * s, hx + 6 * s, hy - ry - 5 * s);
    canvas.drawPath(
      shinePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * s
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.08),
    );

    // Side hair — left
    final leftSidePath = Path()
      ..moveTo(hx - rx - 2 * s, hy - 6 * s)
      ..quadraticBezierTo(
          hx - rx - 5 * s, hy + 4 * s, hx - rx - 1 * s, hy + 14 * s)
      ..quadraticBezierTo(
          hx - rx + 4 * s, hy + 8 * s, hx - rx + 3 * s, hy - 2 * s)
      ..close();
    canvas.drawPath(leftSidePath, Paint()..color = _hairDark);

    // Side hair — right
    final rightSidePath = Path()
      ..moveTo(hx + rx + 2 * s, hy - 6 * s)
      ..quadraticBezierTo(
          hx + rx + 5 * s, hy + 4 * s, hx + rx + 1 * s, hy + 14 * s)
      ..quadraticBezierTo(
          hx + rx - 4 * s, hy + 8 * s, hx + rx - 3 * s, hy - 2 * s)
      ..close();
    canvas.drawPath(rightSidePath, Paint()..color = _hairDark);
  }

  // ─────────────────────────────────────────────────────────
  // Eyebrows
  // ─────────────────────────────────────────────────────────
  void _paintEyebrows(Canvas canvas, double hx, double hy, double s) {
    final browY = hy - 12 * s;
    final browOffset = mood == 'happy'
        ? -2.5 * s
        : mood == 'sad'
            ? 1.0 * s
            : 0.0;
    final browAngle = mood == 'sad'
        ? 0.12
        : mood == 'happy'
            ? -0.06
            : 0.0;

    final browPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8 * s
      ..strokeCap = StrokeCap.round
      ..color = _hairDark.withValues(alpha: 0.85);

    // Left brow
    canvas.save();
    canvas.translate(hx - 10 * s, browY + browOffset);
    canvas.rotate(-browAngle);
    final leftBrow = Path()
      ..moveTo(-8 * s, 0)
      ..quadraticBezierTo(0, -3 * s, 8 * s, 0);
    canvas.drawPath(leftBrow, browPaint);
    canvas.restore();

    // Right brow
    canvas.save();
    canvas.translate(hx + 10 * s, browY + browOffset);
    canvas.rotate(browAngle);
    final rightBrow = Path()
      ..moveTo(-8 * s, 0)
      ..quadraticBezierTo(0, -3 * s, 8 * s, 0);
    canvas.drawPath(rightBrow, browPaint);
    canvas.restore();
  }

  // ─────────────────────────────────────────────────────────
  // Eyes (detailed: sclera → iris → pupil → reflections)
  // ─────────────────────────────────────────────────────────
  void _paintEyes(Canvas canvas, double hx, double hy, double s) {
    final eyeY = hy - 4 * s;
    final eyeSpacing = 11 * s;
    final blinkSquash = 1.0 - blinkT * 0.85; // 1 = open, 0.15 = closed

    for (final side in [-1.0, 1.0]) {
      final ex = hx + side * eyeSpacing;

      // Eye socket shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(ex, eyeY + 1 * s),
          width: 14 * s,
          height: 11 * s * blinkSquash,
        ),
        Paint()..color = _skinShadow.withValues(alpha: 0.15),
      );

      // Sclera (white)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(ex, eyeY),
          width: 13 * s,
          height: 10 * s * blinkSquash,
        ),
        Paint()..color = _eyeWhite,
      );

      if (blinkSquash > 0.3) {
        // Iris
        final irisR = 5.0 * s;
        canvas.drawCircle(
          Offset(ex, eyeY),
          irisR,
          Paint()
            ..shader = RadialGradient(
              colors: [
                _irisColor,
                Color.lerp(_irisColor, Colors.black, 0.4)!,
              ],
            ).createShader(
                Rect.fromCircle(center: Offset(ex, eyeY), radius: irisR)),
        );

        // Iris detail ring
        canvas.drawCircle(
          Offset(ex, eyeY),
          irisR,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8 * s
            ..color = Colors.black.withValues(alpha: 0.15),
        );

        // Pupil
        canvas.drawCircle(
          Offset(ex, eyeY),
          2.8 * s,
          Paint()..color = _pupilColor,
        );

        // Primary reflection (large)
        canvas.drawCircle(
          Offset(ex - 2 * s, eyeY - 2 * s),
          2.0 * s,
          Paint()..color = Colors.white.withValues(alpha: 0.92),
        );

        // Secondary reflection (small)
        canvas.drawCircle(
          Offset(ex + 1.5 * s, eyeY + 1.5 * s),
          1.0 * s,
          Paint()..color = Colors.white.withValues(alpha: 0.5),
        );
      }

      // Upper eyelid line
      final lidPath = Path()
        ..moveTo(ex - 7 * s, eyeY - 1 * s)
        ..quadraticBezierTo(
            ex, eyeY - 5 * s * blinkSquash, ex + 7 * s, eyeY - 1 * s);
      canvas.drawPath(
        lidPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 * s
          ..strokeCap = StrokeCap.round
          ..color = _hairDark.withValues(alpha: 0.6),
      );

      // Eyelashes (subtle)
      if (blinkSquash > 0.5) {
        for (int l = 0; l < 3; l++) {
          final lx = ex - 4 * s + l * 4 * s;
          final ly = eyeY - 5 * s * blinkSquash;
          canvas.drawLine(
            Offset(lx, ly),
            Offset(lx + (l - 1) * 0.8 * s, ly - 2 * s),
            Paint()
              ..strokeWidth = 1.0 * s
              ..strokeCap = StrokeCap.round
              ..color = _hairDark.withValues(alpha: 0.35),
          );
        }
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  // Nose
  // ─────────────────────────────────────────────────────────
  void _paintNose(Canvas canvas, double hx, double hy, double s) {
    final noseY = hy + 7 * s;

    // Nose bridge shadow (subtle)
    final bridgePath = Path()
      ..moveTo(hx - 1.5 * s, hy - 2 * s)
      ..quadraticBezierTo(hx - 2 * s, noseY, hx - 4 * s, noseY + 3 * s);
    canvas.drawPath(
      bridgePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s
        ..strokeCap = StrokeCap.round
        ..color = _skinShadow.withValues(alpha: 0.25),
    );

    // Nose tip highlight
    canvas.drawCircle(
      Offset(hx, noseY + 1 * s),
      2.8 * s,
      Paint()..color = _skinHighlight.withValues(alpha: 0.18),
    );

    // Nostrils
    canvas.drawCircle(
      Offset(hx - 3 * s, noseY + 3 * s),
      1.2 * s,
      Paint()..color = _skinShadow.withValues(alpha: 0.3),
    );
    canvas.drawCircle(
      Offset(hx + 3 * s, noseY + 3 * s),
      1.2 * s,
      Paint()..color = _skinShadow.withValues(alpha: 0.3),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Mouth
  // ─────────────────────────────────────────────────────────
  void _paintMouth(Canvas canvas, double mx, double my, double s) {
    switch (mood) {
      case 'happy':
        // Big warm smile
        final smilePath = Path()
          ..moveTo(mx - 12 * s, my)
          ..quadraticBezierTo(mx, my + 12 * s, mx + 12 * s, my);
        canvas.drawPath(
          smilePath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * s
            ..strokeCap = StrokeCap.round
            ..color = _lipColor,
        );

        // Upper lip fill
        final lipFill = Path()
          ..moveTo(mx - 10 * s, my + 1 * s)
          ..quadraticBezierTo(mx, my + 10 * s, mx + 10 * s, my + 1 * s)
          ..quadraticBezierTo(mx, my + 4 * s, mx - 10 * s, my + 1 * s);
        canvas.drawPath(
            lipFill, Paint()..color = _lipColor.withValues(alpha: 0.25));

        // Teeth hint
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(mx, my + 4 * s), width: 10 * s, height: 4 * s),
            Radius.circular(2 * s),
          ),
          Paint()..color = Colors.white.withValues(alpha: 0.3),
        );
        break;

      case 'sad':
        // Slight frown
        final frownPath = Path()
          ..moveTo(mx - 8 * s, my + 4 * s)
          ..quadraticBezierTo(mx, my - 2 * s, mx + 8 * s, my + 4 * s);
        canvas.drawPath(
          frownPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5 * s
            ..strokeCap = StrokeCap.round
            ..color = const Color(0xFFAA8888),
        );

        // Lower lip
        final lowerLip = Path()
          ..moveTo(mx - 6 * s, my + 5 * s)
          ..quadraticBezierTo(mx, my + 8 * s, mx + 6 * s, my + 5 * s);
        canvas.drawPath(
          lowerLip,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 * s
            ..strokeCap = StrokeCap.round
            ..color = _lipColor.withValues(alpha: 0.4),
        );
        break;

      default:
        // Relaxed neutral
        final neutralPath = Path()
          ..moveTo(mx - 7 * s, my + 1 * s)
          ..quadraticBezierTo(mx, my + 3 * s, mx + 7 * s, my + 1 * s);
        canvas.drawPath(
          neutralPath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.2 * s
            ..strokeCap = StrokeCap.round
            ..color = _lipColor.withValues(alpha: 0.7),
        );
    }

    // Lip highlight
    canvas.drawCircle(
      Offset(mx - 2 * s, my + 1 * s),
      1.5 * s,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Mood extras
  // ─────────────────────────────────────────────────────────
  void _paintMoodExtras(Canvas canvas, double hx, double hy, double s) {
    if (mood == 'happy') {
      // Rosy blush cheeks
      for (final side in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(hx + side * 20 * s, hy + 10 * s),
            width: 12 * s,
            height: 8 * s,
          ),
          Paint()
            ..color = const Color(0xFFFF9999).withValues(alpha: 0.20)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * s),
        );
      }

      // Sparkle stars
      _drawSparkle(canvas, hx - 38 * s, hy - 25 * s, 5 * s, Colors.white);
      _drawSparkle(canvas, hx + 42 * s, hy + 5 * s, 4 * s, Colors.white);
      _drawSparkle(canvas, hx + 30 * s, hy - 38 * s, 3 * s, _primaryColor());
    }

    if (mood == 'sad') {
      // Teardrop
      final tearY = hy - 1 * s + ambientT * 8 * s;
      canvas.drawCircle(
        Offset(hx - 14 * s, tearY),
        2 * s,
        Paint()
          ..color =
              const Color(0xFF88CCFF).withValues(alpha: 0.4 - ambientT * 0.2),
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // Floating orbs
  // ─────────────────────────────────────────────────────────
  void _paintFloatingOrbs(
      Canvas canvas, Size size, double cx, double cy, double s) {
    final moodColor = _primaryColor();
    final prng = _SeededRandom(99);

    for (int i = 0; i < 6; i++) {
      final angle = (i / 6.0) * 3.14159 * 2 + ambientT * 1.2;
      final radius = 110 * s + prng.nextDouble() * 50 * s;
      final orbX = cx + _cosApprox(angle) * radius;
      final orbY = cy - 20 * s + _sinApprox(angle) * radius * 0.4;
      final orbSize = (3 + prng.nextDouble() * 4) * s;

      // Outer glow
      canvas.drawCircle(
        Offset(orbX, orbY),
        orbSize * 3.5,
        Paint()
          ..color = moodColor.withValues(alpha: 0.05)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Core
      canvas.drawCircle(
        Offset(orbX, orbY),
        orbSize,
        Paint()..color = moodColor.withValues(alpha: 0.25),
      );
      // Hot center
      canvas.drawCircle(
        Offset(orbX, orbY),
        orbSize * 0.4,
        Paint()..color = Colors.white.withValues(alpha: 0.15),
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // Vignette overlay
  // ─────────────────────────────────────────────────────────
  void _paintVignette(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.35),
          ],
          stops: const [0.6, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Utility methods
  // ═══════════════════════════════════════════════════════════

  void _drawRR(Canvas canvas, double x, double y, double w, double h, double r,
      Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
      Paint()..color = color,
    );
  }

  /// Draw a trapezoid (wider at top, narrower at bottom) — for legs.
  void _drawTrapezoid(Canvas canvas, double x, double y, double topW,
      double botW, double h, Color color) {
    final cx = x + topW / 2;
    final path = Path()
      ..moveTo(cx - topW / 2, y)
      ..lineTo(cx + topW / 2, y)
      ..lineTo(cx + botW / 2, y + h)
      ..lineTo(cx - botW / 2, y + h)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSparkle(
      Canvas canvas, double x, double y, double size, Color color) {
    final alpha = 0.6 + ambientT * 0.4;
    final paint = Paint()..color = color.withValues(alpha: alpha);
    final path = Path()
      ..moveTo(x, y - size)
      ..lineTo(x + size * 0.25, y - size * 0.25)
      ..lineTo(x + size, y)
      ..lineTo(x + size * 0.25, y + size * 0.25)
      ..lineTo(x, y + size)
      ..lineTo(x - size * 0.25, y + size * 0.25)
      ..lineTo(x - size, y)
      ..lineTo(x - size * 0.25, y - size * 0.25)
      ..close();
    canvas.drawPath(path, paint);
  }

  List<Color> _bgColors() {
    switch (mood) {
      case 'happy':
        return [
          const Color(0xFF0a1a10),
          const Color(0xFF040d08),
          const Color(0xFF000000)
        ];
      case 'sad':
        return [
          const Color(0xFF1a1408),
          const Color(0xFF0d0a04),
          const Color(0xFF000000)
        ];
      default:
        return [
          const Color(0xFF0d0d1a),
          const Color(0xFF08081a),
          const Color(0xFF000000)
        ];
    }
  }

  Color _primaryColor() {
    switch (mood) {
      case 'happy':
        return const Color(0xFF10B981);
      case 'sad':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  Color _particleColor() {
    switch (mood) {
      case 'happy':
        return const Color(0xFF6EE7B7);
      case 'sad':
        return const Color(0xFFFDE68A);
      default:
        return const Color(0xFFA5B4FC);
    }
  }

  double _sin01(double t) => (1 + _sinApprox(t * 3.14159 * 2)) / 2;

  double _sinApprox(double x) {
    x = x % (3.14159 * 2);
    if (x > 3.14159) x -= 3.14159 * 2;
    final x3 = x * x * x;
    final x5 = x3 * x * x;
    return x - x3 / 6 + x5 / 120;
  }

  double _cosApprox(double x) => _sinApprox(x + 3.14159 / 2);

  @override
  bool shouldRepaint(_AvatarScenePainter oldDelegate) {
    return oldDelegate.mood != mood ||
        oldDelegate.progress != progress ||
        oldDelegate.ambientT != ambientT ||
        oldDelegate.blinkT != blinkT ||
        oldDelegate.swayT != swayT;
  }
}

/// Simple seeded PRNG for deterministic particle positions.
class _SeededRandom {
  int _state;
  _SeededRandom(this._state);

  double nextDouble() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return _state / 0x7fffffff;
  }
}
