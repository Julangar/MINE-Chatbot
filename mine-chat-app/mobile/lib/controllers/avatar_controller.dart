// controllers/avatar_controller.dart
import 'package:flutter/material.dart';
import '../services/avatar_service.dart';

class AvatarController extends ChangeNotifier {
  String? avatarId;
  bool isLoading = false;

  Future<void> crearAvatar(Map<String, dynamic> data) async {
    isLoading = true;
    notifyListeners();
    avatarId = await AvatarService.createAvatar(data);
    isLoading = false;
    notifyListeners();
  }

  Future<void> subirFotos(List<String> filePaths) async {
    if (avatarId == null) return;
    isLoading = true;
    notifyListeners();
    await AvatarService.uploadPhotos(avatarId!, filePaths);
    isLoading = false;
    notifyListeners();
  }

  // Lo mismo para subir audio y personalidad
}
