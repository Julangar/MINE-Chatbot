import 'package:flutter/material.dart';
import 'package:mine_chatbot/l10n/app_localizations.dart';

class MyselfQuestions extends StatefulWidget {
  final Function(Map<String, dynamic>) onChanged;
  final Map<String, dynamic> initialData;
  const MyselfQuestions({super.key, required this.onChanged, required this.initialData});

  @override
  State<MyselfQuestions> createState() => _MyselfQuestionsState();
}

class _MyselfQuestionsState extends State<MyselfQuestions> {
  late String _avatarName;
  late String _userReference;
  String? _customUserReference;
  List<String> _selectedTone = [];
  List<String> _selectedTopics = [];
  List<String> _favoritePhrases = [];
  int _slider1 = 3;
  bool _extra1 = false;
  List<String> _habitsOrGoals = [];

  final _referenceOptions = [
    'Mi otro yo', 'Por tu nombre', 'Otro'
  ];
  final _tones = ['Motivador', 'Reflexivo', 'Auto-crítico', 'Empoderador'];
  final _topics = ['Motivación personal', 'Hábitos', 'Metas', 'Auto-cuidado'];
  final _phrases = [
    '¡Tú puedes!', 'Aprende de cada día', 'Sigue adelante', 'Confía en ti'
  ];
  final _habits = [
    'Ejercicio', 'Lectura', 'Meditar', 'Planificar el día', 'Otro'
  ];

  @override
  void initState() {
    super.initState();
    _avatarName = widget.initialData['avatarName'] ?? '';
    _userReference = widget.initialData['userReference'] ?? '';
    _selectedTone = List<String>.from(widget.initialData['tone'] ?? []);
    _selectedTopics = List<String>.from(widget.initialData['topics'] ?? []);
    _favoritePhrases = List<String>.from(widget.initialData['favoritePhrases'] ?? []);
    _slider1 = widget.initialData['slider1'] ?? 3;
    _extra1 = widget.initialData['extra1'] ?? false;
    _customUserReference = widget.initialData['customUserReference'];
    _habitsOrGoals = List<String>.from(widget.initialData['habitsOrGoals'] ?? []);
  }

  void _updateParent() {
    widget.onChanged({
      'avatarName': _avatarName,
      'userReference': (_userReference == 'Otro' || _userReference == 'Por tu nombre')
        ? _customUserReference ?? ''
        : _userReference,
      'tone': _selectedTone,
      'topics': _selectedTopics,
      'favoritePhrases': _favoritePhrases,
      'slider1': _slider1,
      'extra1': _extra1,
      'habitsOrGoals': _habitsOrGoals,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(labelText: 'Nombre del avatar',labelStyle: TextStyle(color: Colors.white)),
          style: const TextStyle(color: Colors.white),
          initialValue: _avatarName,
          onChanged: (val) { setState(() { _avatarName = val; _updateParent(); }); },
          validator: (val) => val == null || val.isEmpty ? 'Obligatorio' : null,
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: '¿Cómo te quieres referir a ti mismo?',labelStyle: TextStyle(color: Colors.white)),
          style: const TextStyle(color: Colors.white),
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
              return 'Por favor, especifica la referencia';
            }
            return null;
          },
        ),
        if (_userReference == 'Otro' || _userReference == 'Por tu nombre')
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Escribe aquí tu referencia preferida', labelStyle: TextStyle(color: Colors.white)),
              style: const TextStyle(color: Colors.white),
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
          child: Text('Tono de conversación (elige al menos uno):',style: TextStyle(color: Colors.white)),
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
          child: Text('Temas preferidos (elige al menos uno):', style: TextStyle(color: Colors.white)),
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
          child: Text('Frases favoritas (elige al menos una):',style: TextStyle(color: Colors.white)),
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
          child: Text('Nivel de autoexigencia (1 = muy relajado, 5 = muy disciplinado):',style: TextStyle(color: Colors.white)),
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
          title: const Text('¿Quieres recibir mensajes motivadores?',style: TextStyle(color: Colors.white)),
          value: _extra1,
          onChanged: (val) => setState(() { _extra1 = val; _updateParent(); }),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 4),
          child: Text('¿Sobre qué hábitos o metas te gustaría recibir recordatorios?',style: TextStyle(color: Colors.white)),
        ),
        Wrap(
          spacing: 6,
          children: _habits.map((habit) {
            final selected = _habitsOrGoals.contains(habit);
            return FilterChip(
              label: Text(habit),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  if (isSelected) {
                    _habitsOrGoals.add(habit);
                  } else {
                    _habitsOrGoals.remove(habit);
                  }
                  _updateParent();
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
