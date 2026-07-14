import 'package:flutter/material.dart';
import '../utils/colors.dart';

class BsuHeader extends StatelessWidget {
  final String subtitle;

  const BsuHeader({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: bsuRed,
          padding: const EdgeInsets.only(bottom: 20),
          child: Center(
            child: Text(
              subtitle,
              style: const TextStyle(
                color: bsuWhite,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        Container(
          height: 24,
          decoration: const BoxDecoration(
            color: bsuWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}