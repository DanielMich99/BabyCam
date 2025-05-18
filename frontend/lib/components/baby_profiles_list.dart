import 'package:flutter/material.dart';
import '../models/baby_profile.dart';

class BabyProfilesList extends StatelessWidget {
  final List<BabyProfile> babies;
  final Function(int) onBabySelected;

  const BabyProfilesList({
    Key? key,
    required this.babies,
    required this.onBabySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: babies.length,
              itemBuilder: (context, index) {
                final baby = babies[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => onBabySelected(index),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: baby.isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(baby.imageUrl),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        baby.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
