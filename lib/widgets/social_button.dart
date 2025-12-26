import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

class SocialButton extends StatelessWidget {
  final String text;
  final IconData? icon;           
  final String? svgPath;          
  final VoidCallback onPressed;
  final Color? iconColor;

  const SocialButton({
    super.key,
    required this.text,
    this.icon,                    
    this.svgPath,                 
    required this.onPressed,
    this.iconColor,
  }) : assert(icon != null || svgPath != null, 'You must provide either an icon OR an svgPath'),
       assert(!(icon != null && svgPath != null), 'Cannot provide both icon and svgPath');

  @override
  Widget build(BuildContext context) {
    Widget leadingIcon;
    if (svgPath != null) {
      leadingIcon = SvgPicture.asset(
        svgPath!,
        height: 24,
        width: 24,
      );
    } else {
      leadingIcon = Icon(icon, size: 24, color: iconColor ?? Colors.black);
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leadingIcon,
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}