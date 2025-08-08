
class Avatar {
  final String userId;
  final String avatarType;
  final String name;
  final String country;
  final String phoneNumber;
  final String userReference;
  final String relationshipOrRole;
  final List<String> interests;
  final String speakingStyle;
  final List<String> commonPhrases;
  final Map<String, double> traits;
  final String? userLanguage;
  final String? imageUrl;
  final String? audioUrl;
  final String? videoUrl;
  final String? talkId;

  Avatar({
    required this.userId,
    required this.avatarType,
    required this.name,
    required this.country,
    required this.phoneNumber,
    required this.userReference,
    required this.relationshipOrRole,
    required this.interests,
    required this.speakingStyle,
    required this.commonPhrases,
    required this.traits,
    required this.userLanguage,
    this.imageUrl,
    this.audioUrl,
    this.videoUrl,
    this.talkId,
  });

  Avatar copyWith({
    String? imageUrl,
    String? audioUrl,
    String? videoUrl,
    String? talkId,
  }) {
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
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      talkId: talkId ?? this.talkId,
    );
  }

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      userId: json['userId'],
      avatarType: json['avatarType'],
      name: json['name'],
      country: json['country'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      userReference: json['userReference'] ?? '',
      relationshipOrRole: json['relationshipOrRole'] ?? '',
      interests: List<String>.from(json['interests'] ?? []),
      speakingStyle: json['speakingStyle'] ?? '',
      commonPhrases: List<String>.from(json['commonPhrases'] ?? []),
      traits: Map<String, double>.from(json['traits'] ?? {}),
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      talkId: json['talkId'],
      userLanguage: json['userLanguage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'avatarType': avatarType,
      'name': name,
      'country': country,
      'phoneNumber': phoneNumber,
      'userReference': userReference,
      'relationshipOrRole': relationshipOrRole,
      'interests': interests,
      'speakingStyle': speakingStyle,
      'commonPhrases': commonPhrases,
      'traits': traits,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'talkId': talkId,
      'userLanguage': userLanguage,
    };
  }
}
