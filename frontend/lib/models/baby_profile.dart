class BabyProfile {
  final String name;
  final String imageUrl;
  final bool isSelected;

  BabyProfile({
    required this.name,
    required this.imageUrl,
    this.isSelected = false,
  });

  BabyProfile copyWith({String? name, String? imageUrl, bool? isSelected}) {
    return BabyProfile(
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
