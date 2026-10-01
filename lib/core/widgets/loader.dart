import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 55,
        width: 55,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation(
            Pallete.gradient2,
          ),
        ),
      ),
    );
  }
}