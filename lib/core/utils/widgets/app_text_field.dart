import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
  });

  final String label;
  final Widget? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool obscure = true;

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fillColor = scheme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.035);
    final mutedIcon =
        widget.prefixIcon is Icon ? (widget.prefixIcon as Icon).color : null;

    return TextFormField(
      controller: widget.controller,
      validator:
          widget.validator ?? (value) => value!.isEmpty ? 'Required' : null,
      obscureText: widget.isPassword ? obscure : false,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      cursorColor: scheme.primary,
      cursorWidth: 1.6,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 17, horizontal: 18),
        filled: true,
        fillColor: fillColor,
        labelText: widget.label,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface.withOpacity(0.55),
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: scheme.primary,
        ),
        prefixIcon: widget.prefixIcon,
        prefixIconColor: mutedIcon ?? scheme.onSurface.withOpacity(0.45),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => obscure = !obscure),
                splashRadius: 22,
                icon: Icon(
                  obscure ? Iconsax.eye_slash : Iconsax.eye,
                  size: 20,
                ),
              )
            : null,
        suffixIconColor: scheme.onSurface.withOpacity(0.45),
        border: _border(Colors.transparent, 1),
        enabledBorder: _border(scheme.onSurface.withOpacity(0.08), 1),
        focusedBorder: _border(scheme.primary, 1.5),
        errorBorder: _border(scheme.error.withOpacity(0.55), 1),
        focusedErrorBorder: _border(scheme.error, 1.5),
      ),
    );
  }
}
