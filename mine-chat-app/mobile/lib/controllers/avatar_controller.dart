
import 'package:flutter/material.dart';

import '../models/avatar.dart';

class AvatarController extends ChangeNotifier {
  String userId = '';
  String avatarType = '';
  String name = '';
  String country = '';
  String phoneNumber = '';
  String userReference = '';
  String relationshipOrRole = '';
  List<String> interests = [];
  String speakingStyle = '';
  String userLanguage = '';
  List<String> commonPhrases = [];
  Map<String, double> traits = {};

  String? imageUrl;
  String? audioUrl;

  void setBasicInfo({
    required String user,
    required String type,
    required String displayName,
  }) {
    userId = user;
    avatarType = type;
    name = displayName;
  }

  void setPersonality({
    required List<String> interestsInput,
    required String style,
    required List<String> phrases,
    required Map<String, double> traitMap,
  }) {
    interests = interestsInput;
    speakingStyle = style;
    commonPhrases = phrases;
    traits = traitMap;
  }

  void saveAvatarImage(String url) {
    imageUrl = url;
  }

  void saveAvatarVoice(String url) {
    audioUrl = url;
  }

  Avatar toAvatar() {
    return Avatar(
      userId: userId,
      avatarType: avatarType,
      name: name,
      country: country,
      phoneNumber: phoneNumber,
      userReference: userReference,
      relationshipOrRole: relationshipOrRole,
      interests: interests,
      speakingStyle: speakingStyle,
      commonPhrases: commonPhrases,
      traits: traits,
      userLanguage: userLanguage,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
    );
  }
}
