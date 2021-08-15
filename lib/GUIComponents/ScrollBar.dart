import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Source code from:
// https://stackoverflow.com/questions/61010841/how-to-make-scrollbar-visible-all-time/61011354

const double _kScrollbarThickness = 6.0;

class CustomScrollbar extends StatefulWidget {
  var builder;
  var scrollController;

  CustomScrollbar({
    Key? key,
    this.scrollController,
    @required this.builder,
  })  : assert(builder != null),
        super(key: key);

  @override
  _CustomScrollbarState createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends State<CustomScrollbar> {
  var _scrollbarPainter;
  var _scrollController;
  var _orientation;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _updateScrollPainter(_scrollController!.position);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollbarPainter = _buildMaterialScrollbarPainter();
  }

  @override
  void dispose() {
    _scrollbarPainter.dispose();
    super.dispose();
  }

  ScrollbarPainter _buildMaterialScrollbarPainter() {
    return ScrollbarPainter(
      color: Theme.of(context).highlightColor.withOpacity(1.0),
      textDirection: Directionality.of(context),
      thickness: _kScrollbarThickness,
      fadeoutOpacityAnimation: const AlwaysStoppedAnimation<double>(1.0),
      padding: MediaQuery.of(context).padding,
    );
  }

  bool _updateScrollPainter(ScrollMetrics position) {
    _scrollbarPainter.update(
      position,
      position.axisDirection,
    );
    return false;
  }

  @override
  void didUpdateWidget(CustomScrollbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateScrollPainter(_scrollController.position);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        _orientation ??= orientation;
        if (orientation != _orientation) {
          _orientation = orientation;
          _updateScrollPainter(_scrollController.position);
        }
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) =>
              _updateScrollPainter(notification.metrics),
          child: CustomPaint(
            painter: _scrollbarPainter,
            child: widget.builder(context, _scrollController),
          ),
        );
      },
    );
  }
}
