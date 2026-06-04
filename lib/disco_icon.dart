import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DiscoIcon extends StatelessWidget {
  final int index;
  final double height;
  final double width;
  final double margin;

  const DiscoIcon({super.key, required this.index, this.height = 60, this.width = 60, this.margin = 2});

  @override
  Widget build(BuildContext context) {
    List<int> fallbackColors = [
       0xFF0F4C5C, // Azul Petróleo
       0xFF4A148C, // Roxo
       0xFF7F1D1D, // Bordô
       0xFF1B4332, // Verde Musgo
       0xFF78350F, // Ocre
    ];

    int dynamicFallbackColor = (fallbackColors[index % fallbackColors.length]);

    return Padding(
    padding: EdgeInsets.all(margin), 
    child: SizedBox(
      height: height,
      width: width,
      child: Stack(
      children: [
        SvgPicture.asset(
        'assets/images/disco_full.svg',
        height: height,
        width: width,
        colorFilter: ColorFilter.mode(Color(dynamicFallbackColor), BlendMode.srcIn),
      ),
      SvgPicture.asset(
        'assets/images/disco_without.svg',
        height: height,
        width: width
      ),
      ]
    )
    )
    );
  }
}