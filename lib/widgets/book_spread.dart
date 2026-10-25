import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// How a page turn is animated.
enum BookTurnStyle { curl, flip, slide, fade }

/// Drives a [BookSpreadView] from outside (buttons, sliders, audio follow).
class BookSpreadController {
  _BookSpreadViewState? _state;

  int get spread => _state?._spread ?? 0;

  Future<void> next() async => _state?._turn(1);
  Future<void> previous() async => _state?._turn(-1);

  /// Jumps without the page-turn animation.
  void jumpTo(int spread) => _state?._jumpTo(spread);

  /// Turns one leaf at a time until [spread] is reached (at most three turns,
  /// then jumps the rest of the way).
  Future<void> animateTo(int spread) async => _state?._animateTo(spread);
}

/// An open book with two facing pages. Spread `k` shows [rightPage]`(k)` on
/// the right and [leftPage]`(k)` on the left, as in an Arabic book where the
/// odd page sits on the right. Turning forward lifts the left leaf and lays it
/// over the right page, revealing the next spread underneath; its back face is
/// the next spread's right page. Swipe, tap a page, or use the controller.
///
/// When [cover] is given, spread `-1` is the closed book: the cover sits on
/// the left half and opens with the first turn.
class BookSpreadView extends StatefulWidget {
  const BookSpreadView({
    super.key,
    required this.spreadCount,
    required this.leftPage,
    required this.rightPage,
    this.cover,
    this.initialSpread = 0,
    this.pageAspect = 0.68,
    this.gap = 6,
    this.style = BookTurnStyle.curl,
    this.onSpreadChanged,
    this.controller,
  });

  final int spreadCount;
  final Widget? Function(int spread) leftPage;
  final Widget? Function(int spread) rightPage;
  final Widget? cover;
  final int initialSpread;
  final double pageAspect;
  final double gap;
  final BookTurnStyle style;
  final ValueChanged<int>? onSpreadChanged;
  final BookSpreadController? controller;

  @override
  State<BookSpreadView> createState() => _BookSpreadViewState();
}

class _BookSpreadViewState extends State<BookSpreadView> with SingleTickerProviderStateMixin {
  late int _spread = widget.initialSpread;
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  int _direction = 0; // +1 forward (left leaf to the right), -1 backward
  bool _dragging = false;
  double _pageWidth = 1;

  // Curl textures: the two faces of the turning leaf.
  final _frontKey = GlobalKey();
  final _backKey = GlobalKey();
  ui.Image? _frontImage;
  ui.Image? _backImage;
  bool _capturing = false;

  int get _minSpread => widget.cover == null ? 0 : -1;
  int get _maxSpread => widget.spreadCount - 1;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _spread += _direction;
          _direction = 0;
          _anim.value = 0;
          _disposeTextures();
        });
        widget.onSpreadChanged?.call(_spread);
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _direction = 0;
          _disposeTextures();
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant BookSpreadView old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    widget.controller?._state = null;
    _disposeTextures();
    _anim.dispose();
    super.dispose();
  }

  void _disposeTextures() {
    _frontImage?.dispose();
    _backImage?.dispose();
    _frontImage = null;
    _backImage = null;
    _capturing = false;
  }

  bool get _busy => _anim.isAnimating || _dragging;

  /// Starts a turn in [direction]; for the curl style, first captures the two
  /// faces of the leaf as images (they are painted hidden under the pages).
  Future<bool> _begin(int direction) async {
    final target = _spread + direction;
    if (target < _minSpread || target > _maxSpread) return false;
    setState(() => _direction = direction);
    if (widget.style == BookTurnStyle.curl) {
      setState(() => _capturing = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return false;
      try {
        final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);
        final f = _frontKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        final b = _backKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        _frontImage = f == null ? null : await f.toImage(pixelRatio: dpr);
        _backImage = b == null ? null : await b.toImage(pixelRatio: dpr);
      } catch (_) {
        _frontImage = null;
        _backImage = null;
      }
      if (mounted) setState(() => _capturing = false);
    }
    return mounted;
  }

  Future<void> _turn(int direction) async {
    if (_busy || _direction != 0) return;
    if (!await _begin(direction)) return;
    await _anim.forward(from: 0);
  }

  void _jumpTo(int spread) {
    if (_busy) return;
    final s = spread.clamp(_minSpread, _maxSpread);
    if (s == _spread) return;
    setState(() => _spread = s);
    widget.onSpreadChanged?.call(_spread);
  }

  Future<void> _animateTo(int spread) async {
    final s = spread.clamp(_minSpread, _maxSpread);
    var turns = 0;
    while (_spread != s && turns < 3 && mounted) {
      await _turn(s > _spread ? 1 : -1);
      turns++;
    }
    if (mounted && _spread != s) _jumpTo(s);
  }

  // ---- gestures ----------------------------------------------------------

  void _onDragStart(DragStartDetails d) {
    if (_anim.isAnimating || _capturing) return;
    _dragging = true;
  }

  Future<void> _onDragUpdate(DragUpdateDetails d) async {
    if (!_dragging) return;
    final dx = d.primaryDelta ?? 0;
    if (_direction == 0) {
      final dir = dx > 0 ? 1 : -1;
      if (!await _begin(dir)) {
        _dragging = false;
        return;
      }
    }
    if (!_dragging) return;
    final delta = dx / (_pageWidth * 1.6) * _direction;
    _anim.value = (_anim.value + delta).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_dragging) return;
    _dragging = false;
    if (_direction == 0) return;
    final v = (d.primaryVelocity ?? 0) * _direction;
    if (_anim.value > 0.4 || v > 300) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
  }

  void _onTapUp(TapUpDetails d, double width) {
    if (_busy || _capturing) return;
    final onLeft = d.localPosition.dx < width / 2;
    _turn(onLeft ? 1 : -1);
  }

  // ---- rendering ---------------------------------------------------------

  Widget? _left(int s) => s == -1 ? widget.cover : (s < 0 || s > _maxSpread ? null : widget.leftPage(s));
  Widget? _right(int s) => s < 0 || s > _maxSpread ? null : widget.rightPage(s);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final maxPageW = (c.maxWidth - widget.gap) / 2;
        final pageH = math.min(c.maxHeight, maxPageW / widget.pageAspect);
        final pageW = pageH * widget.pageAspect;
        _pageWidth = pageW;
        final bookW = pageW * 2 + widget.gap;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTapUp: (d) => _onTapUp(d, c.maxWidth),
          child: Center(
            child: SizedBox(
              width: bookW,
              height: pageH,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, _) => _buildBook(pageW, pageH),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBook(double w, double h) {
    final t = _anim.value;
    final dir = _direction;
    final target = _spread + dir;
    final curlReady = widget.style == BookTurnStyle.curl && _frontImage != null && _backImage != null;

    Widget slot(Widget? page, {required bool left, Key? key}) {
      return Positioned(
        left: left ? 0 : w + widget.gap,
        top: 0,
        width: w,
        height: h,
        child: page == null ? const SizedBox.shrink() : RepaintBoundary(key: key, child: page),
      );
    }

    // Faces of the turning leaf.
    final Widget? frontFace = dir == 1 ? _left(_spread) : (dir == -1 ? _right(_spread) : null);
    final Widget? backFace = dir == 1 ? _right(target) : (dir == -1 ? _left(target) : null);

    // What is visible underneath the moving leaf.
    Widget? leftUnder = dir == 1 ? _left(target) : _left(_spread);
    Widget? rightUnder = dir == -1 ? _right(target) : _right(_spread);

    final children = <Widget>[];

    // Hidden layer (painted first, i.e. underneath): the faces to capture.
    if (dir != 0 && _capturing) {
      children.add(slot(frontFace ?? const SizedBox.shrink(), left: dir == 1, key: _frontKey));
      children.add(slot(backFace ?? const SizedBox.shrink(), left: dir != 1, key: _backKey));
    }

    if (widget.style == BookTurnStyle.slide || widget.style == BookTurnStyle.fade) {
      children.addAll(_simpleTransition(w, h, t, dir, target, slot));
      return Stack(clipBehavior: Clip.none, children: children);
    }

    children.add(slot(leftUnder, left: true));
    children.add(slot(rightUnder, left: false));
    children.add(_spineShadow(w, h));

    if (dir != 0 && t > 0 && !_capturing) {
      if (curlReady) {
        children.add(Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _CurlPainter(
                front: _frontImage!,
                back: _backImage!,
                t: t,
                forward: dir == 1,
                pageWidth: w,
                pageHeight: h,
                gap: widget.gap,
              ),
            ),
          ),
        ));
      } else {
        children.addAll(_flipLeaf(w, h, t, dir, frontFace, backFace));
      }
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _spineShadow(double w, double h) => Positioned(
        left: w - 10,
        top: 0,
        width: widget.gap + 20,
        height: h,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      );

  /// Slide / fade: both spreads shown, the new one coming in.
  List<Widget> _simpleTransition(
    double w,
    double h,
    double t,
    int dir,
    int target,
    Widget Function(Widget?, {required bool left, Key? key}) slot,
  ) {
    Widget spreadOf(int s) => Stack(children: [slot(_left(s), left: true), slot(_right(s), left: false), _spineShadow(w, h)]);
    if (dir == 0 || t == 0) return [Positioned.fill(child: spreadOf(_spread))];
    final bookW = 2 * w + widget.gap;
    if (widget.style == BookTurnStyle.fade) {
      return [
        Positioned.fill(child: spreadOf(_spread)),
        Positioned.fill(child: Opacity(opacity: Curves.easeInOut.transform(t), child: spreadOf(target))),
      ];
    }
    // Slide: forward moves content to the right (Arabic reading order).
    final shift = Curves.easeInOutCubic.transform(t) * bookW * dir;
    return [
      Positioned(left: shift, top: 0, width: bookW, height: h, child: spreadOf(_spread)),
      Positioned(left: shift - bookW * dir, top: 0, width: bookW, height: h, child: spreadOf(target)),
    ];
  }

  /// The rigid "card flip" leaf.
  List<Widget> _flipLeaf(double w, double h, double t, int dir, Widget? frontFace, Widget? backFace) {
    final firstHalf = t < 0.5;
    Widget? face;
    bool onLeftSlot;
    double angle;
    if (dir == 1) {
      if (firstHalf) {
        face = frontFace;
        onLeftSlot = true;
        angle = -t * math.pi;
      } else {
        face = backFace;
        onLeftSlot = false;
        angle = (1 - t) * math.pi;
      }
    } else {
      if (firstHalf) {
        face = frontFace;
        onLeftSlot = false;
        angle = t * math.pi;
      } else {
        face = backFace;
        onLeftSlot = true;
        angle = -(1 - t) * math.pi;
      }
    }
    final lift = math.sin(t * math.pi);
    final shadowOnLeft = dir == 1 ? !firstHalf : firstHalf;
    return [
      Positioned(
        left: onLeftSlot ? 0 : w + widget.gap,
        top: 0,
        width: w,
        height: h,
        child: IgnorePointer(
          child: Transform(
            alignment: onLeftSlot ? Alignment.centerRight : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0014)
              ..rotateY(angle),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (face != null) RepaintBoundary(child: face) else const ColoredBox(color: Color(0xFFFDF6E3)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: onLeftSlot ? Alignment.centerRight : Alignment.centerLeft,
                      end: onLeftSlot ? Alignment.centerLeft : Alignment.centerRight,
                      colors: [Colors.black.withValues(alpha: 0.45 * lift), Colors.black.withValues(alpha: 0.05 * lift)],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: shadowOnLeft ? 0 : w + widget.gap,
        top: 0,
        width: w,
        height: h,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: shadowOnLeft ? Alignment.centerRight : Alignment.centerLeft,
                end: shadowOnLeft ? Alignment.centerLeft : Alignment.centerRight,
                colors: [Colors.black.withValues(alpha: 0.35 * lift), Colors.transparent],
                stops: const [0, 0.6],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

/// Paints the turning leaf bent around a cylinder whose radius grows then
/// shrinks as the fold travels from the outer edge, over the spine, onto the
/// facing page. The front face shows until the paper passes over the top;
/// the back face lands mirrored in its final place. Shading follows the
/// curvature and a soft shadow is cast on the page beneath the fold.
class _CurlPainter extends CustomPainter {
  _CurlPainter({
    required this.front,
    required this.back,
    required this.t,
    required this.forward,
    required this.pageWidth,
    required this.pageHeight,
    required this.gap,
  });

  final ui.Image front;
  final ui.Image back;
  final double t;
  final bool forward;
  final double pageWidth;
  final double pageHeight;
  final double gap;

  static const strips = 56;

  @override
  void paint(Canvas canvas, Size size) {
    final w = pageWidth, h = pageHeight;
    // Work in a frame where the leaf starts on the left and lands on the
    // right; mirror the whole canvas for a backward turn.
    canvas.save();
    if (!forward) {
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }
    final spine = w; // x of the hinge (left page's right edge)
    final landSpine = w + gap; // x where the landed page starts

    final e = Curves.easeInOut.transform(t);
    final r0 = w * 0.22;
    final radius = math.max(1.0, r0 * math.sin(math.pi * e)); // 0 -> r0 -> 0
    final fold = w * (1 - e); // distance from the spine where the paper leaves the table

    // Positions along the paper, u = 0 at the spine .. w at the outer edge.
    // Returns (x, z, onBack).
    (double, double, bool) place(double u) {
      if (u <= fold) return (spine - u, 0, false);
      final arc = u - fold;
      final theta = arc / radius;
      if (theta < math.pi) {
        final x = spine - fold - radius * math.sin(theta);
        final z = radius * (1 - math.cos(theta));
        return (x, z, theta > math.pi / 2);
      }
      // Flat again, travelling back toward and past the spine on top.
      final flat = arc - math.pi * radius;
      final x = spine - fold + flat;
      return (x, 2 * radius, true);
    }

    final frontScaleX = front.width / w, frontScaleY = front.height / h;
    final backScaleX = back.width / w, backScaleY = back.height / h;

    // Shadow under the fold on the page beneath.
    final shadowX = spine - fold;
    final shade = Paint()
      ..shader = ui.Gradient.linear(
        Offset(shadowX, 0),
        Offset(shadowX - radius * 2.2, 0),
        [Colors.black.withValues(alpha: 0.32 * (radius / r0)), Colors.transparent],
      );
    canvas.drawRect(Rect.fromLTWH(shadowX - radius * 2.2, 0, radius * 2.2, h), shade);

    // Build strips for the front and back faces separately.
    final frontPos = <Offset>[], frontTex = <Offset>[], frontCol = <Color>[];
    final backPos = <Offset>[], backTex = <Offset>[], backCol = <Color>[];
    final du = w / strips;
    for (var i = 0; i <= strips; i++) {
      final u = i * du;
      final (x, z, onBack) = place(u);
      final lightness = (1 - (z / (2 * r0)).clamp(0.0, 1.0) * 0.45);
      final color = Color.fromRGBO((255 * lightness).round(), (255 * lightness).round(), (255 * lightness).round(), 1);
      // Front texture column: the left page's local x = w - u.
      final fx = (w - u) * frontScaleX;
      // Back texture column: the landed right page's local x = x - landSpine.
      final bxLocal = (x - landSpine).clamp(0.0, w);
      final bx = bxLocal * backScaleX;
      if (!onBack) {
        frontPos.addAll([Offset(x, 0), Offset(x, h)]);
        frontTex.addAll([Offset(fx, 0), Offset(fx, front.height.toDouble())]);
        frontCol.addAll([color, color]);
      } else {
        // Where the back face is still over the left page (x < landSpine) it
        // shows the mirrored edge of the landing page.
        backPos.addAll([Offset(x, 0), Offset(x, h)]);
        backTex.addAll([Offset(bx, 0), Offset(bx, back.height.toDouble())]);
        backCol.addAll([color, color]);
      }
    }

    void drawStrip(ui.Image img, List<Offset> pos, List<Offset> tex, List<Color> col, double sy) {
      if (pos.length < 4) return;
      final paint = Paint()
        ..shader = ui.ImageShader(img, TileMode.clamp, TileMode.clamp, Matrix4.identity().storage)
        ..filterQuality = FilterQuality.medium;
      final vertices = ui.Vertices(ui.VertexMode.triangleStrip, pos, textureCoordinates: tex, colors: col);
      canvas.drawVertices(vertices, BlendMode.modulate, paint);
    }

    // Clip the back face to the right side so the "mirrored edge" never paints
    // over the left page's content beyond the fold.
    drawStrip(front, frontPos, frontTex, frontCol, frontScaleY);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(spine - fold - radius, -2, size.width, h + 4));
    drawStrip(back, backPos, backTex, backCol, backScaleY);
    canvas.restore();

    // Soft edge shadow on the landing page ahead of the leaf's edge.
    if (backPos.isNotEmpty) {
      final edgeX = backPos.last.dx;
      final edge = Paint()
        ..shader = ui.Gradient.linear(
          Offset(edgeX, 0),
          Offset(edgeX + radius * 1.5 + 8, 0),
          [Colors.black.withValues(alpha: 0.28 * (0.3 + radius / r0)), Colors.transparent],
        );
      canvas.drawRect(Rect.fromLTWH(edgeX, 0, radius * 1.5 + 8, h), edge);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CurlPainter old) =>
      old.t != t || old.front != front || old.back != back || old.forward != forward;
}

/// A few offset page edges on the outer sides, suggesting the thickness of
/// the block of pages still to be read on each side.
class BookEdges extends StatelessWidget {
  const BookEdges({super.key, required this.child, required this.leftFraction, this.color});
  final Widget child;
  final double leftFraction;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final edge = color ?? Theme.of(context).colorScheme.outline.withValues(alpha: 0.35);
    final remaining = (1 - leftFraction).clamp(0.0, 1.0);
    final read = leftFraction.clamp(0.0, 1.0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (var i = 1; i <= 4; i++)
          Positioned.fill(
            left: -i * 2.0 * read,
            right: -i * 2.0 * remaining,
            top: i * 1.2,
            bottom: -i * 1.2,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: edge.withValues(alpha: edge.a * (1 - i / 5))),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}
