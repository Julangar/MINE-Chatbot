import 'package:flutter/material.dart';
import 'package:mine_app/l10n/app_localizations.dart';

class AvatarPersonalityForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AvatarPersonalityForm({super.key, required this.onSubmit});

  @override
  State<AvatarPersonalityForm> createState() => _AvatarPersonalityFormState();
}

class _AvatarPersonalityFormState extends State<AvatarPersonalityForm> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String userReference = '';
  String relationshipOrRole = '';
  String speakingStyle = 'casual';
  String country = '';
  String phoneNumber = '';
  List<String> interests = [];
  List<String> commonPhrases = [];
  double extroversion = 0.5;
  double agreeableness = 0.5;
  double conscientiousness = 0.5;

  final phraseController = TextEditingController();

  void _addPhrase() {
    final text = phraseController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        commonPhrases.add(text);
        phraseController.clear();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit({
        'name': name,
        'userReference': userReference,
        'country': country,
        'phoneNumber': phoneNumber,
        'relationshipOrRole': relationshipOrRole,
        'speakingStyle': speakingStyle,
        'interests': interests,
        'commonPhrases': commonPhrases,
        'traits': {
          'extroversion': extroversion,
          'agreeableness': agreeableness,
          'conscientiousness': conscientiousness,
        },
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final styleOptions = {
      'casual': t.style_casual,
      'formal': t.style_formal,
      'tierno': t.style_tierno,
      'divertido': t.style_divertido,
    };

    final interestOptions = {
      'música': t.interest_music,
      'tecnología': t.interest_tech,
      'viajes': t.interest_travel,
      'lectura': t.interest_books,
      'naturaleza': t.interest_nature,
    };

    return Form(
      key: _formKey,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: t.avatar_form_name_label,
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) => name = value,
              validator: (value) => value!.isEmpty ? t.field_required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: t.avatar_form_country_label,
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) => country = value,
              validator: (value) => value!.isEmpty ? t.field_required : null,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: t.avatar_form_user_reference_label,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              onChanged: (value) => userReference = value,
              validator: (value) => value!.isEmpty ? t.field_required : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: t.avatar_form_relationship_label,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              onChanged: (value) => relationshipOrRole = value,
              validator: (value) => value!.isEmpty ? t.field_required : null,
            ),
            TextFormField(
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                labelText: '${t.avatar_form_phone_label} (${t.field_optional})',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (value) => phoneNumber = value,             
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField(
              value: speakingStyle,
              dropdownColor: Colors.grey,
              decoration: InputDecoration(
                labelText: t.avatar_form_speaking_style_label,
                labelStyle: const TextStyle(color: Colors.white),
              ),
              items: styleOptions.entries
                  .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value, style: const TextStyle(color: Colors.grey))))
                  .toList(),
              onChanged: (value) => setState(() => speakingStyle = value!),
            ),
            const SizedBox(height: 24),
            Text(t.avatar_form_interests_label, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            ...interestOptions.entries.map((entry) => CheckboxListTile(
                  title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                  value: interests.contains(entry.key),
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  onChanged: (val) {
                    setState(() {
                      val == true ? interests.add(entry.key) : interests.remove(entry.key);
                    });
                  },
                )),
            const SizedBox(height: 24),
            Text(t.avatar_form_common_phrases_label, style: const TextStyle(color: Colors.white)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phraseController,
                    style: const TextStyle(color: Colors.grey),
                    decoration: InputDecoration(hintText: t.avatar_form_add_phrase_hint),
                  ),
                ),
                IconButton(onPressed: _addPhrase, icon: const Icon(Icons.add_circle_outline))
              ],
            ),
            Wrap(
              spacing: 8,
              children: commonPhrases
                  .map((phrase) => Chip(
                        label: Text(phrase),
                        onDeleted: () => setState(() => commonPhrases.remove(phrase)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Text(t.avatar_form_traits_label, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 8),
            Text(t.avatar_form_extroversion, style: const TextStyle(color: Colors.white)),
            Slider(value: extroversion, onChanged: (v) => setState(() => extroversion = v)),
            Text(t.avatar_form_agreeableness, style: const TextStyle(color: Colors.white)),
            Slider(value: agreeableness, onChanged: (v) => setState(() => agreeableness = v)),
            Text(t.avatar_form_conscientiousness, style: const TextStyle(color: Colors.white)),
            Slider(value: conscientiousness, onChanged: (v) => setState(() => conscientiousness = v)),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.arrow_forward),
                label: Text(AppLocalizations.of(context)!.saveAndContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
