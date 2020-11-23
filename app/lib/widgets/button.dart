import 'package:flutter/material.dart';
import 'package:wfhmovement/style.dart';

class StyledButton extends StatefulWidget {
  final GestureTapCallback onPressed;
  final String title;
  final IconData icon;
  final bool small;
  final bool tiny;
  final bool secondary;
  final bool danger;
  final Widget iconWidget;

  final List<BoxShadow> boxShadow;

  StyledButton({
    Key key,
    @required this.onPressed,
    @required this.title,
    this.icon,
    this.boxShadow = const [],
    this.small = false,
    this.tiny = false,
    this.secondary = false,
    this.danger = false,
    this.iconWidget,
  }) : super(key: key);

  @override
  _OutlinedButtonState createState() => _OutlinedButtonState();
}

class _OutlinedButtonState extends State<StyledButton>
    with SingleTickerProviderStateMixin {
  Color _color;
  Color _highlightColor;
  AnimationController _controller;
  Animation _colorTween;

  Color _backgroundColor(bool highlight) {
    if (widget.danger) {
      return highlight ? AppColors.dangerPressed : AppColors.danger;
    }
    if (widget.secondary) {
      return highlight ? AppColors.secondaryPressed : AppColors.secondary;
    }
    return highlight ? AppColors.mainPressed : AppColors.main;
  }

  @override
  void initState() {
    _color = _backgroundColor(false);
    _highlightColor = _backgroundColor(true);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
      value: 1.0,
    );
    _colorTween =
        ColorTween(begin: _highlightColor, end: _color).animate(_controller);
    _controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (_colorTween.value != _color.value) {
      _controller.reverse();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_colorTween.value != _color.value) {
      _controller.forward();
    }
  }

  void _onTapCancel() {
    if (_colorTween.value != _color.value) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttonWidgets = widget.icon != null
        ? [
            widget.iconWidget != null
                ? widget.iconWidget
                : Icon(
                    widget.icon,
                    color: widget.secondary || widget.danger
                        ? Colors.white
                        : Colors.black,
                    size: widget.tiny ? 16 : 24,
                  ),
            SizedBox(width: widget.tiny ? 2 : 10)
          ]
        : [];
    buttonWidgets.add(
      Text(
        widget.title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
              widget.secondary || widget.danger ? Colors.white : Colors.black,
          fontWeight: widget.secondary || widget.danger
              ? FontWeight.w400
              : FontWeight.w800,
          fontSize: widget.tiny ? 10 : 16,
          letterSpacing: 1.125,
        ),
      ),
    );

    double width = _widthForSize();

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTapUp: _onTapUp,
      onTap: widget.onPressed,
      child: Container(
        width: width,
        height: widget.tiny ? 30 : 44,
        decoration: BoxDecoration(
          color: _colorTween.value,
          borderRadius: BorderRadius.circular(50),
          boxShadow: widget.boxShadow,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: buttonWidgets,
          ),
        ),
      ),
    );
  }

  double _widthForSize() {
    double _width = widget.title.length > 12 ? 250 : 200;
    if (widget.small) {
      _width = 130;
    }
    if (widget.tiny) {
      _width = 75;
    }
    return _width;
  }
}
