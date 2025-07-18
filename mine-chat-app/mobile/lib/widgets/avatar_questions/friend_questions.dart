import 'package:flutter/material.dart';

class FriendQuestions extends StatefulWidget {
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic> initialData;
  const FriendQuestions({super.key, required this.onChanged, required this.initialData});

  @override
  State<FriendQuestions> createState() => _FriendQuestionsState();
}

class _FriendQuestionsState extends State<FriendQuestions> {
  late String _avatarName;
  late String _relationshipOrRole;
  String? _customRelationshipOrRole;
  late String _userReference;
  String? _customUserReference;
  List<String> _selectedTone = [];
  List<String> _selectedTopics = [];
  List<String> _favoritePhrases = [];
  int _slider1 = 3;
  bool _extra1 = false;

  final _relationshipOptions = [
    'Amig@ de toda la vida', 'Compañer@', 'Parcer@', 'Bro', 'Otro'
  ];
  final _referenceOptions = [
    'Amig@', 'Bro', 'Hermano/a', 'Parcer@', 'Por tu nombre', 'Otro'
  ];
  final _tones = ['Divertido', 'Motivador', 'Sincero', 'Empático'];
  final _topics = ['Consejos', 'Conversaciones casuales', 'Juegos', 'Motivación'];
  final _phrases = [
    'Cuenta conmigo', 'Siempre a tu lado', '¡Vamos por más!', 'Te entiendo', 'No te rindas'
  ];

  @override
  void initState() {
    super.initState();
    _avatarName = widget.initialData['avatarName'] ?? '';
    _relationshipOrRole = widget.initialData['relationshipOrRole'] ?? '';
    _userReference = widget.initialData['userReference'] ?? '';
    _selectedTone = List<String>.from(widget.initialData['tone'] ?? []);
    _selectedTopics = List<String>.from(widget.initialData['topics'] ?? []);
    _favoritePhrases = List<String>.from(widget.initialData['favoritePhrases'] ?? []);
    _slider1 = widget.initialData['slider1'] ?? 3;
    _extra1 = widget.initialData['extra1'] ?? false;
    _customUserReference = widget.initialData['customUserReference'];
  }

  void _updateParent() {
    widget.onChanged({
      'avatarName': _avatarName,
      'relationshipOrRole': (_relationshipOrRole == 'Otro' )
        ? _customRelationshipOrRole ?? ''
        : _relationshipOrRole,
      'userReference': (_userReference == 'Otro' || _userReference == 'Por tu nombre')
        ? _customUserReference ?? ''
        : _userReference,
      'tone': _selectedTone,
      'topics': _selectedTopics,
      'favoritePhrases': _favoritePhrases,
      'slider1': _slider1,
      'extra1': _extra1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nombre del avatar'),
          initialValue: _avatarName,
          onChanged: (val) { setState(() { _avatarName = val; _updateParent(); }); },
          validator: (val) => val == null || val.isEmpty ? 'Obligatorio' : null,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Tipo de amistad'),
          value: _relationshipOrRole.isNotEmpty ? _relationshipOrRole : null,
          items: _relationshipOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() { _relationshipOrRole = val ?? ''; _updateParent(); });
            if (val != 'Otro') {
              setState(() { _customRelationshipOrRole = null; });
            }
          },
          validator: (val) {
            if (val == null || val.isEmpty) return 'Obligatorio';
            if ((val == 'Otro') && (_customRelationshipOrRole == null || _customRelationshipOrRole!.isEmpty)) {
              return 'Por favor, especifica el tipo de amistad';
            }
            return null;
          },
        ),
        if (_relationshipOrRole == 'Otro')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Escribe aquí tu referencia preferida'),
              onChanged: (val) => setState(() { _customRelationshipOrRole = val; _updateParent(); }),
              validator: (val) {
                if ((_relationshipOrRole == 'Otro') && (val == null || val.isEmpty)) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '¿Cómo quieres que te llame?'),
          value: _userReference.isNotEmpty ? _userReference : null,
          items: _referenceOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (val) {
            setState(() { _userReference = val ?? ''; _updateParent(); });
            if (val != 'Otro' && val != 'Por tu nombre') {
              setState(() { _customUserReference = null; });
            }
          },
          validator: (val) {
            if (val == null || val.isEmpty) return 'Obligatorio';
            if ((val == 'Otro' || val == 'Por tu nombre') && (_customUserReference == null || _customUserReference!.isEmpty)) {
              return 'Por favor, especifica cómo quieres que te llame';
            }
            return null;
          },
        ),
        if (_userReference == 'Otro' || _userReference == 'Por tu nombre')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Escribe aquí tu referencia preferida'),
              onChanged: (val) => setState(() { _customUserReference = val; _updateParent(); }),
              validator: (val) {
                if ((_userReference == 'Otro' || _userReference == 'Por tu nombre') && (val == null || val.isEmpty)) {
                  return 'Este campo es obligatorio';
                }
                return null;
              },
            ),
          ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 4),
          child: Text('Tono de conversación (elige al menos uno):'),
        ),
        Wrap(
          spacing: 6,
          children: _tones.map((tone) {
            final selected = _selectedTone.contains(tone);
            return FilterChip(
              label: Text(tone),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedTone.add(tone);
                  } else {
                    _selectedTone.remove(tone);
                  }
                  _updateParent();
                });
              },
            );
          }).toList(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 4),
          child: Text('Temas preferidos (elige al menos uno):'),
        ),
        Wrap(
          spacing: 6,
          children: _topics.map((topic) {
            final selected = _selectedTopics.contains(topic);
            return FilterChip(
              label: Text(topic),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _selectedTopics.add(topic);
                  } else {
                    _selectedTopics.remove(topic);
                  }
                  _updateParent();
                });
              },
            );
          }).toList(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 4),
          child: Text('Frases favoritas (elige al menos una):'),
        ),
        Wrap(
          spacing: 6,
          children: _phrases.map((phrase) {
            final selected = _favoritePhrases.contains(phrase);
            return FilterChip(
              label: Text(phrase),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _favoritePhrases.add(phrase);
                  } else {
                    _favoritePhrases.remove(phrase);
                  }
                  _updateParent();
                });
              },
            );
          }).toList(),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10),
          child: Text('Nivel de confianza (1 = formal, 5 = como familia):'),
        ),
        Slider(
          value: _slider1.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _slider1.toString(),
          onChanged: (value) {
            setState(() {
              _slider1 = value.round();
              _updateParent();
            });
          },
        ),
        SwitchListTile(
          title: const Text('¿Tu avatar debe recordarte fechas importantes?'),
          value: _extra1,
          onChanged: (val) => setState(() { _extra1 = val; _updateParent(); }),
        ),
      ],
    );
  }
}
