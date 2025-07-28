enum AvatarType { love, friend, relative, myself }

class AvatarPersonality {
  final AvatarType type;
  final String avatarName;
  final String userReference; // cómo te llama el avatar
  final String relationshipOrRole; // relación, rol o propósito
  final List<String> tone;
  final List<String> topics;
  final List<String> favoritePhrases;
  final int slider1; // Para niveles de confianza, bromas, frecuencia, etc.
  final bool extra1; // mensajes espontáneos, memes, etc.
  final List<String> habitsOrGoals; // para 'Myself'
  // Puedes agregar más campos si necesitas

  AvatarPersonality({
    required this.type,
    required this.avatarName,
    required this.userReference,
    required this.relationshipOrRole,
    required this.tone,
    required this.topics,
    required this.favoritePhrases,
    required this.slider1,
    required this.extra1,
    required this.habitsOrGoals,
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'avatarName': avatarName,
        'userReference': userReference,
        'relationshipOrRole': relationshipOrRole,
        'tone': tone,
        'topics': topics,
        'favoritePhrases': favoritePhrases,
        'slider1': slider1,
        'extra1': extra1,
        'habitsOrGoals': habitsOrGoals,
      };
}
