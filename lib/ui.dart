import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'data.dart';
import 'sfx.dart';
import 'theme.dart';

/// Page background: deep midnight gradient with a soft violet glow at the top.
class LuxBackground extends StatelessWidget {
  final Widget child;
  const LuxBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [C.bgTop, C.bg, C.bg],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            right: -80,
            child: IgnorePointer(
              child: Container(
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [C.violet.withValues(alpha: 0.28), Colors.transparent]),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Frosted glass panel.
class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? border;
  final Color fill;
  const Glass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 22,
    this.border,
    this.fill = C.glass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? C.glassBorder),
      ),
      child: child,
    );
  }
}

/// A box with a gradient hairline border and optional glow.
class GradientFrame extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final double radius;
  final double width;
  final Color fill;
  final Color? glow;
  final EdgeInsetsGeometry padding;
  const GradientFrame({
    super.key,
    required this.child,
    required this.gradient,
    this.radius = 22,
    this.width = 1.6,
    this.fill = C.surface,
    this.glow,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: glow == null ? null : [BoxShadow(color: glow!.withValues(alpha: 0.35), blurRadius: 24, spreadRadius: -4)],
      ),
      padding: EdgeInsets.all(width),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(radius - width)),
        child: child,
      ),
    );
  }
}

/// Text painted with a gradient.
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? align;
  const GradientText(this.text, {super.key, required this.style, this.gradient = C.goldGrad, this.align});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (r) => gradient.createShader(Rect.fromLTWH(0, 0, r.width, r.height)),
      child: Text(text, style: style, textAlign: align),
    );
  }
}

/// Big gradient call-to-action button.
class LuxButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final Color textColor;
  final double height;
  const LuxButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.gradient = C.goldGrad,
    this.textColor = C.ink,
    this.height = 58,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [BoxShadow(color: gradient.colors[1].withValues(alpha: 0.38), blurRadius: 22, offset: const Offset(0, 8), spreadRadius: -6)]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onPressed,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Text(icon!, style: const TextStyle(fontSize: 20)), const SizedBox(width: 10)],
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined glass button (secondary action).
class GlassButton extends StatelessWidget {
  final String label;
  final String? icon;
  final VoidCallback? onPressed;
  final Color color;
  final double height;
  const GlassButton({super.key, required this.label, this.icon, required this.onPressed, this.color = C.gold, this.height = 54});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: C.glass,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: color.withValues(alpha: 0.55)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: SizedBox(
            height: height,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Text(icon!, style: const TextStyle(fontSize: 18)), const SizedBox(width: 8)],
                  Flexible(
                    child: Text(label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small round icon button with glass fill.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const GlassIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.glass,
      shape: const CircleBorder(side: BorderSide(color: C.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 22, color: Colors.white)),
      ),
    );
  }
}

/// Speaker on/off toggle.
class SoundButton extends StatelessWidget {
  const SoundButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: Sfx.on,
      builder: (_, on, __) => GlassIconButton(
        icon: on ? Icons.volume_up_rounded : Icons.volume_off_rounded,
        onPressed: Sfx.toggle,
      ),
    );
  }
}

final bool _isTest = (() {
  try {
    return Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return false;
  }
})();

/// A card's real photo (cached), falling back to its emoji.
class CardPic extends StatelessWidget {
  final CardItem card;
  final double size;
  final double? radius;
  const CardPic(this.card, {super.key, required this.size, this.radius});

  @override
  Widget build(BuildContext context) {
    final emoji = SizedBox(
      width: size,
      height: size,
      child: Center(child: Text(card.emoji, style: TextStyle(fontSize: size * 0.62, height: 1.1))),
    );
    final path = card.img;
    if (path == null && card.tint != null) {
      // no photo (e.g. anime, copyrighted): a themed badge with the symbol
      final col = Color(card.tint!);
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? size * 0.22),
          gradient: RadialGradient(colors: [col.withValues(alpha: 0.85), col.withValues(alpha: 0.25)], radius: 0.9),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: size > 60 ? 2 : 1),
        ),
        child: Center(child: Text(card.emoji, style: TextStyle(fontSize: size * 0.5, height: 1.1))),
      );
    }
    if (path == null || _isTest) return emoji;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size * 0.22),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => emoji,
      ),
    );
  }
}

/// "Change cards" pill: shows how many changes are left this round.
class RerollChip extends StatelessWidget {
  final int left;
  final VoidCallback onTap;
  const RerollChip({super.key, required this.left, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final on = left > 0;
    return Opacity(
      opacity: on ? 1 : 0.35,
      child: Material(
        color: C.glass,
        shape: StadiumBorder(side: BorderSide(color: on ? C.violet.withValues(alpha: 0.7) : C.glassBorder)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: on ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text('🔄 $left', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ),
      ),
    );
  }
}
