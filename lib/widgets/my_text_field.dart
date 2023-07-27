import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final InputDecoration decoration;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const MyTextField({
    Key? key,
    this.hintText = '',
    this.decoration = const InputDecoration(),
    this.onChanged,
    this.controller
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _passwordVisible = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: TextField(
        onChanged: widget.onChanged,
        controller: widget.controller,
        obscureText: !_passwordVisible,
        decoration: widget.decoration.copyWith(
          suffixIcon: Visibility(
            visible: _isHovered || _passwordVisible,
            child: IconButton(
              icon: Icon(
                _passwordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
