import 'dart:math' as math;

import 'package:flutter/material.dart';

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
  final ValueChanged<int>? onSpreadChanged;
  final BookSpreadController? controller;

  @override
  State<BookSpreadView> createState() => _BookSpreadViewState();
}

class _BookSpreadViewState extends State<BookSpreadView> with SingleTickerProviderStateMixin {
  late int _spread = widget.initialSpread;
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  int _direction = 0; // +1 forward (left leaf to the right), -1 backward
  bool _dragging = false;
  double _pageWidth = 1;

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
        });
        widget.onSpreadChanged?.call(_spread);
      } else if (status == AnimationStatus.dismissed) {
        setState(() => _direction = 0);
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
    _anim.dispose();
    super.dispose();
  }

  bool get _busy => _anim.isAnimating || _dragging;

  Future<void> _turn(int direction) async {
    if (_busy || _direction != 0 && !_dragging) return;
    final target = _spread + direction;
    if (target < _minSpread || target > _maxSpread) return;
    setState(() => _direction = direction);
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
    if (_anim.isAnimating) return;
    _dragging = true;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_dragging) return;
    final dx = d.primaryDelta ?? 0;
    if (_direction == 0) {
      // Dragging to the right turns the left leaf forward; to the left, backward.
      final dir = dx > 0 ? 1 : -1;
      final target = _spread + dir;
      if (target < _minSpread || target > _maxSpread) return;
      setState(() => _direction = dir);
    }
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
    if (_busy) return;
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

    // Static layers: what is visible underneath the moving leaf.
    final Widget? leftUnder = dir == 1 ? _left(target) : _left(_spread);
    final Widget? rightUnder = dir == -1 ? _right(target) : _right(_spread);

    Widget slot(Widget? page, {required bool left}) {
      return Positioned(
        left: left ? 0 : w + widget.gap,
        top: 0,
        width: w,
        height: h,
        child: page == null ? const SizedBox.shrink() : RepaintBoundary(child: page),
      );
    }

    final children = <Widget>[
      slot(leftUnder, left: true),
      slot(rightUnder, left: false),
      // Spine shadow.
      Positioned(
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
      ),
    ];

    if (dir != 0 && t > 0) {
      // The moving leaf. First half shows its front face, second half its back.
      final firstHalf = t < 0.5;
      Widget? face;
      bool onLeftSlot;
      double angle; // rotation around the spine
      if (dir == 1) {
        // Left leaf turning to the right.
        if (firstHalf) {
          face = _left(_spread);
          onLeftSlot = true;
          angle = -t * math.pi; // 0 -> -pi/2 (edge lifts toward the viewer)
        } else {
          face = _right(target);
          onLeftSlot = false;
          angle = (1 - t) * math.pi; // pi/2 -> 0
        }
      } else {
        // Right leaf turning to the left.
        if (firstHalf) {
          face = _right(_spread);
          onLeftSlot = false;
          angle = t * math.pi; // 0 -> pi/2
        } else {
          face = _left(target);
          onLeftSlot = true;
          angle = -(1 - t) * math.pi; // -pi/2 -> 0
        }
      }
      final lift = math.sin(t * math.pi); // 0..1..0 shading as the leaf stands up
      children.add(
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
                  // Shade the leaf as it turns, darkest near the spine.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: onLeftSlot ? Alignment.centerRight : Alignment.centerLeft,
                        end: onLeftSlot ? Alignment.centerLeft : Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.45 * lift),
                          Colors.black.withValues(alpha: 0.05 * lift),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      // Shadow cast on the page the leaf is landing on / lifting from.
      final shadowOnLeft = dir == 1 ? !firstHalf : firstHalf;
      children.add(
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
      );
    }

    return Stack(clipBehavior: Clip.none, children: children);
  }
}

/// A few offset page edges on the outer sides, suggesting the thickness of
/// the block of pages still to be read on each side.
class BookEdges extends StatelessWidget {
  const BookEdges({super.key, required this.child, required this.leftFraction, this.color});
  final Widget child;

  /// 0..1: how far into the book we are (controls the stack on each side).
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
