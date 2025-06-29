import 'package:flutter/material.dart';
import 'video_stream_player.dart';
import 'full_screen_video_stream.dart';
import '../../utils/profile_image.dart';

class CameraPreviewPager extends StatelessWidget {
  final List<Map<String, dynamic>> activeCameras;

  const CameraPreviewPager({Key? key, required this.activeCameras})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: activeCameras.length,
      controller: PageController(viewportFraction: 0.8),
      itemBuilder: (context, index) {
        final cam = activeCameras[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueGrey[50],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenVideoStream(
                                streamUrl: 'http://${cam['ip']}:80/stream',
                                title: '${cam['name']} - ${cam['type']} Camera',
                              ),
                            ),
                          );
                        },
                        child: VideoStreamPlayer(
                          streamUrl: 'http://${cam['ip']}:80/stream',
                          isActive: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              getProfileImageProvider(cam['profilePicture']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cam['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cam['type']} Camera',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
