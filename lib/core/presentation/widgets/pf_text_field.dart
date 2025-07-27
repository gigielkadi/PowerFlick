import 'package:flutter/material.dart';
import 'package:tabler_icons/tabler_icons.dart';

class PFTextField extends StatefulWidget {
  const PFTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  State<PFTextField> createState() => _PFTextFieldState();
}

class _PFTextFieldState extends State<PFTextField> {
  late bool _hide = widget.obscure;
  String? _errorText;

  void _validate(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hide,
      keyboardType: widget.keyboardType,
      onChanged: _validate,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        errorText: _errorText,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black54,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: Icon(
          widget.icon,
          size: 18,
          color: Colors.black54,
        ),
        suffixIcon: widget.obscure
            ? IconButton(
                icon: Icon(
                  _hide ? TablerIcons.eye : TablerIcons.eye_off,
                  size: 18,
                  color: Colors.black54,
                ),
                onPressed: () => setState(() => _hide = !_hide),
                iconSize: 18,
                visualDensity: VisualDensity.compact,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black26,
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black54,
            width: 1,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
      ),
    );
  }
} 