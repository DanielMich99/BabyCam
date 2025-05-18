import 'package:flutter/material.dart';
import '../../models/baby_profile.dart';

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
      height: 210,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: babies.length,
        itemBuilder: (context, index) {
          final baby = babies[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => onBabySelected(index),
              child: Card(
                elevation: baby.isSelected ? 6 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: baby.isSelected ? Colors.blue : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Container(
                  width: 120,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: baby.isSelected
                                ? Colors.blue[50]
                                : Colors.grey[200],
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: AssetImage(baby.imageUrl),
                              backgroundColor: Colors.white,
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
                      const SizedBox(height: 8),
                      Text(
                        baby.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: baby.isSelected ? Colors.blue : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
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
                              size: 20,
                            ),
                            tooltip: 'Camera 1',
                            onPressed: onCameraToggle != null
                                ? () => onCameraToggle!(index, 1)
                                : null,
                            padding: const EdgeInsets.all(4),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.videocam,
                              color:
                                  baby.camera2On ? Colors.green : Colors.grey,
                              size: 20,
                            ),
                            tooltip: 'Camera 2',
                            onPressed: onCameraToggle != null
                                ? () => onCameraToggle!(index, 2)
                                : null,
                            padding: const EdgeInsets.all(4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
