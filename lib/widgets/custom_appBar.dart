import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;

  const CustomAppBar({super.key, this.showBackButton = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    const Color brandColor = Color(0xFFFC882F);

    final user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? "MantiCollector";
    if (displayName == "MantiCollector" && user?.email != null) {
      displayName = user!.email!.split('@')[0];
    }

    return AppBar(
      // 1. FIXED: Changed from 'lightOrangeBg' to 'white' to match your Scaffold body
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent, // Ensures it stays white even when scrolling
      elevation: 0,
      scrolledUnderElevation: 2,
      
      // 2. FIXED: Aligns the title with your body content (usually 20px or 24px)
      titleSpacing: 24, 
      
      automaticallyImplyLeading: showBackButton,

      title: Row(
        children: [
          SvgPicture.asset(
            'assets/icons/ucollect_logo.svg',
            height: 32,
            colorFilter: const ColorFilter.mode(brandColor, BlendMode.srcIn),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MantiCol",
                style: TextStyle(
                  color: brandColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "$displayName",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: brandColor, size: 28),
          onPressed: () {},
        ),
        // Added a bit more margin to the right icon too
        const SizedBox(width: 16), 
      ],
    );
  }
}