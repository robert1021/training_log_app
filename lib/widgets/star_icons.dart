import 'package:flutter/material.dart';

class StarIcons extends StatelessWidget {
  final int stars;

  const StarIcons({
    super.key,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    if (stars == 1) {
      return const Wrap(
        spacing: 5,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star_border_outlined,
            color: Colors.grey,
          ),
          Icon(
            Icons.star_border_outlined,
            color: Colors.grey,
          ),
        ],
      );
    } else if (stars == 2) {
      return const Wrap(
        spacing: 5,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star_border_outlined,
            color: Colors.grey,
          ),
        ],
      );
    } else if (stars == 3) {
      return const Wrap(
        spacing: 5,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
        ],
      );
    } else {
      return const Wrap(
        spacing: 5,
        children: [
          Icon(
            Icons.star_border_outlined,
            color: Colors.grey,
          ),
          Icon(
            Icons.star_border_outlined,
            color: Colors.grey,
          ),
          Icon(
            Icons.star_border_outlined,
            color: Colors.grey,
          ),
        ],
      );
    }
  }
}
