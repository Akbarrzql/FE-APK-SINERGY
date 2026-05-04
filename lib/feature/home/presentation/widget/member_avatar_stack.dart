import 'package:flutter/material.dart';
import '../../../../core/common/color_value.dart';
import 'category_chip.dart';
import 'skill_tag.dart';

class MemberAvatarStack extends StatelessWidget {
  final List<String> images;
  final int extra;

  const MemberAvatarStack({required this.images, required this.extra});

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 28;
    const double overlap = 10;

    return SizedBox(
      width: images.length * (avatarSize - overlap) + overlap + (extra > 0 ? avatarSize : 0),
      height: avatarSize,
      child: Stack(
        children: [
          ...List.generate(images.length, (i) {
            return Positioned(
              left: i * (avatarSize - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: CircleAvatar(
                  radius: avatarSize / 2,
                  backgroundImage: NetworkImage(images[i]),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            );
          }),
          if (extra > 0)
            Positioned(
              left: images.length * (avatarSize - overlap),
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  color: ColorValue.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$extra+',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}