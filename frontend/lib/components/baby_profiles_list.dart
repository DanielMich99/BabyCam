import 'package:flutter/material.dart';
import '../models/baby_profile.dart';

typedef BabyOptionSelected = void Function(int index, String option);
typedef CameraToggle = void Function(int index, int cameraNumber);

class BabyProfilesList extends StatelessWidget {
  final List<BabyProfile> babies;
  final Function(int) onBabySelected;
  final BabyOptionSelected? onOptionSelected;
  final CameraToggle? onCameraToggle;

  const BabyProfilesList({
    Key? key,
    required this.babies,
    required this.onBabySelected,
    this.onOptionSelected,
    this.onCameraToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
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
                      Stack(
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
                          Positioned(
                            right: 0,
                            top: 0,
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (option) {
                                if (onOptionSelected != null) {
                                  onOptionSelected!(index, option);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'remove',
                                  child: Text('Remove Child'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        baby.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.videocam,
                              color:
                                  baby.camera1On ? Colors.green : Colors.grey,
                            ),
                            tooltip: 'Camera 1',
                            onPressed: onCameraToggle != null
                                ? () => onCameraToggle!(index, 1)
                                : null,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.videocam,
                              color:
                                  baby.camera2On ? Colors.green : Colors.grey,
                            ),
                            tooltip: 'Camera 2',
                            onPressed: onCameraToggle != null
                                ? () => onCameraToggle!(index, 2)
                                : null,
                          ),
                        ],
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
