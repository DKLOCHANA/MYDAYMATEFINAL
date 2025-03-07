import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;

  const ActionButton({super.key, this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text!),
        style: Theme.of(context).elevatedButtonTheme.style,
      ),
    );
  }
}
