import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class MyRoundedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  const MyRoundedImage({super.key, required this.imageUrl, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // Điều chỉnh bán kính góc tròn ở đây
          child: FadeInImage.memoryNetwork(
            width: width,
            height: height,
            placeholder: kTransparentImage,
            image: imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
