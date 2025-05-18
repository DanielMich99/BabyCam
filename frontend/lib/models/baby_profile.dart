class BabyProfile {
  final String name;
  final String imageUrl;
  final bool isSelected;
  final bool camera1On;
  final bool camera2On;

  BabyProfile({
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
    this.camera1On = false,
    this.camera2On = false,
  });

  BabyProfile copyWith(
      {String? name,
      String? imageUrl,
      bool? isSelected,
      bool? camera1On,
      bool? camera2On}) {
    return BabyProfile(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
      camera1On: camera1On ?? this.camera1On,
      camera2On: camera2On ?? this.camera2On,
    );
  }
}
