import 'package:flutter/material.dart';

class StyledButton extends StatefulWidget {
  final GestureTapCallback onPressed;
  final String title;
  final Widget icon;

  final List<BoxShadow> boxShadow;

  StyledButton({
    Key key,
    @required this.onPressed,
    @required this.title,
    this.icon,
    this.boxShadow = const [],
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

  @override
  void initState() {
    _color = Colors.yellow[600];
    _highlightColor = Colors.yellow[700];
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
    List<Widget> buttonWidgets =
        widget.icon != null ? [widget.icon, SizedBox(width: 10)] : [];
    buttonWidgets.add(
      Text(
        widget.title.toUpperCase(),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w800,
          fontSize: 16.0,
          letterSpacing: 1.125,
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTapUp: _onTapUp,
      onTap: widget.onPressed,
      child: Container(
        width: widget.title.length > 12 ? 250 : 200,
        height: 44,
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
}
