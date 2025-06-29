import 'dart:convert';
import 'package:flutter/material.dart';

ImageProvider getProfileImageProvider(String? profilePicture) {
  if (profilePicture != null && profilePicture.isNotEmpty) {
    if (profilePicture.startsWith('http')) {
      return NetworkImage(profilePicture);
    } else if (profilePicture.startsWith('/9j/') ||
        profilePicture.startsWith('iVBOR') ||
        profilePicture.startsWith('data:image')) {
      try {
        final base64Str = profilePicture.contains(',')
            ? profilePicture.split(',').last
            : profilePicture;
        return MemoryImage(base64Decode(base64Str));
      } catch (_) {}
    } else {
      return AssetImage(profilePicture);
    }
  }
  return const AssetImage('assets/images/default_baby.jpg');
}
