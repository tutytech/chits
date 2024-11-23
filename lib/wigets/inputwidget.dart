import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final String? hintText;
  final double height;
  final String topLabel;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixWidget;

  final bool readOnly; // Added readOnly to ensure it can handle read-only mode
  final ValueChanged<String>? onChanged; // Added onChanged for input changes

  InputWidget({
    this.hintText,
    this.height = 48.0,
    this.topLabel = "",
    this.obscureText = false,
    this.controller,
    this.prefixIcon,
    this.suffixWidget,
    this.readOnly = false, // Default to false for normal text input
    this.onChanged,
    required String label,
    bool? isDropdown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topLabel != null) // Check if topLabel is provided
          Text(
            topLabel,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        const SizedBox(height: 10.0),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                if (prefixIcon != null) prefixIcon!,
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    obscureText: obscureText,
                    readOnly: readOnly, // Use the readOnly property here
                    onChanged:
                        onChanged, // Trigger onChanged when input changes
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        fontSize: 14.0,
                        color: Color.fromRGBO(105, 108, 121, 0.7),
                      ),
                    ),
                  ),
                ),
                if (suffixWidget != null) suffixWidget!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
