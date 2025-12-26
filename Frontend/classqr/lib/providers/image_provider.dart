import 'dart:typed_data';
import 'package:flutter_riverpod/legacy.dart';

final profileImageProvider =
    StateNotifierProvider<ProfileImageNotifier, Uint8List?>(
      (ref) => ProfileImageNotifier(),
    );

class ProfileImageNotifier extends StateNotifier<Uint8List?> {
  ProfileImageNotifier() : super(null);

  void setImage(Uint8List bytes) {
    state = bytes;
  }

  void clear() {
    state = null;
  }
}
