
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
    final interestOptions = ['tecnología', 'música', 'deportes', 'viajes', 'lectura', 'naturaleza'];

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: t.avatar_form_name_label),
              onChanged: (value) => name = value,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: t.avatar_form_user_reference_label),
              onChanged: (value) => userReference = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(labelText: t.avatar_form_relationship_label),
              onChanged: (value) => relationshipOrRole = value,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField(
              value: speakingStyle,
              items: ['casual', 'formal', 'tierno', 'divertido']
                  .map((style) => DropdownMenuItem(value: style, child: Text(style)))
                  .toList(),
              onChanged: (value) => setState(() => speakingStyle = value!),
              decoration: InputDecoration(labelText: t.avatar_form_speaking_style_label),
            ),
            const SizedBox(height: 24),
            Text(t.avatar_form_interests_label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...interestOptions.map((interest) => CheckboxListTile(
                  title: Text(interest),
                  value: interests.contains(interest),
                  onChanged: (val) {
                    setState(() {
                      val == true ? interests.add(interest) : interests.remove(interest);
                    });
                  },
                )),
            const SizedBox(height: 24),
            Text(t.avatar_form_common_phrases_label, style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phraseController,
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
            Text(t.avatar_form_traits_label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(t.avatar_form_extroversion),
            Slider(value: extroversion, onChanged: (v) => setState(() => extroversion = v)),
            Text(t.avatar_form_agreeableness),
            Slider(value: agreeableness, onChanged: (v) => setState(() => agreeableness = v)),
            Text(t.avatar_form_conscientiousness),
            Slider(value: conscientiousness, onChanged: (v) => setState(() => conscientiousness = v)),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.arrow_forward),
                label: Text(t.avatar_form_continue_button),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
