
import 'package:flutter/material.dart';
import '../models/avatar.dart';

class AvatarProvider with ChangeNotifier {
  Avatar? _avatar;

  Avatar? get avatar => _avatar;

  void setAvatar(Avatar avatar) {
    _avatar = avatar;
    notifyListeners();
  }

  void updateAudioUrl(String url) {
    if (_avatar != null) {
      _avatar = _avatar!.copyWith(audioUrl: url);
      notifyListeners();
    }
  }

  void updateImageUrl(String url) {
    if (_avatar != null) {
      _avatar = _avatar!.copyWith(imageUrl: url);
      notifyListeners();
    }
  }

  void updateVideoInfo(String talkId, String videoUrl) {
    if (_avatar != null) {
      _avatar = _avatar!.copyWith(talkId: talkId, videoUrl: videoUrl);
      notifyListeners();
    }
  }

  void reset() {
    _avatar = null;
    notifyListeners();
  }
}
