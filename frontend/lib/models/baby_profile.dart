class BabyProfile {
  final int id;
  final String name;
  final int? age;
  final String? gender;
  final int? weight;
  final int? height;
  final String? medicalCondition;
  final String? profilePicture;
  final String? headCameraIp;
  final String? staticCameraIp;

  // UI fields (optional, for selection/camera toggles)
  final bool isSelected;
  final bool camera1On;
  final bool camera2On;
  final bool isConnectingCamera1;
  final bool isConnectingCamera2;

  BabyProfile({
    required this.id,
    required this.name,
    this.age,
    this.gender,
    this.weight,
    this.height,
    this.medicalCondition,
    this.profilePicture,
    this.headCameraIp,
    this.staticCameraIp,
    this.isSelected = false,
    this.camera1On = false,
    this.camera2On = false,
    this.isConnectingCamera1 = false,
    this.isConnectingCamera2 = false,
  });

  factory BabyProfile.fromJson(Map<String, dynamic> json) {
    return BabyProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      weight: json['weight'],
      height: json['height'],
      medicalCondition: json['medical_condition'],
      profilePicture: json['profile_picture'],
      headCameraIp: json['head_camera_ip'],
      staticCameraIp: json['static_camera_ip'],
      camera1On: json['camera1_on'] ?? false,
      camera2On: json['camera2_on'] ?? false,
      isConnectingCamera1: false,
      isConnectingCamera2: false,
    );
  }

  BabyProfile copyWith({
    int? id,
    String? name,
    int? age,
    String? gender,
    int? weight,
    int? height,
    String? medicalCondition,
    String? profilePicture,
    String? headCameraIp,
    String? staticCameraIp,
    bool? isSelected,
    bool? camera1On,
    bool? camera2On,
    bool? isConnectingCamera1,
    bool? isConnectingCamera2,
  }) {
    return BabyProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      medicalCondition: medicalCondition ?? this.medicalCondition,
      profilePicture: profilePicture ?? this.profilePicture,
      headCameraIp: headCameraIp ?? this.headCameraIp,
      staticCameraIp: staticCameraIp ?? this.staticCameraIp,
      isSelected: isSelected ?? this.isSelected,
      camera1On: camera1On ?? this.camera1On,
      camera2On: camera2On ?? this.camera2On,
      isConnectingCamera1: isConnectingCamera1 ?? this.isConnectingCamera1,
      isConnectingCamera2: isConnectingCamera2 ?? this.isConnectingCamera2,
    );
  }
}
