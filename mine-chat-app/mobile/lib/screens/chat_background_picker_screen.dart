// lib/screens/chat_background_picker_screen.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_appearance_controller.dart';
import '../data/chat_background_presets.dart';
import '../models/chat_background.dart';
import '../widgets/chat_background_layer.dart';

class ChatBackgroundPickerScreen extends StatelessWidget {
  const ChatBackgroundPickerScreen({super.key});

  static const List<String> backgrounds = [
    'assets/backgrounds/bg1.png',
    'assets/backgrounds/bg2.png',
    'assets/backgrounds/bg3.png',
    'assets/backgrounds/bg4.png',
  ];
  
  Future<void> _pickAndUpload(BuildContext context) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 2000, imageQuality: 90);
    if (x == null) return;
    final file = File(x.path);

    final ctrl = context.read<ChatAppearanceController>();
    final uid = ctrl.userId ?? 'anonymous';
    final ref = FirebaseStorage.instance.ref().child('users/$uid/wallpapers/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();

    await ctrl.setBackground(ChatBackground(
      type: ChatBackgroundType.networkImage,
      image: url,
      blur: 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ChatAppearanceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Fondo del chat')),
      body: Column(
        children: [
          // Vista previa en vivo
          AspectRatio(
            aspectRatio: 16/9,
            child: Stack(
              children: [
                Positioned.fill(child: ChatBackgroundLayer(background: ctrl.background)),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Vista previa', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Opciones predefinidas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1,
              ),
              itemCount: chatBackgroundPresets.length + 2, // + subir + blur
              itemBuilder: (ctx, i) {
                if (i == chatBackgroundPresets.length) {
                  return _ActionTile(
                    icon: Icons.upload,
                    label: 'Mi imagen',
                    onTap: () => _pickAndUpload(context),
                  );
                }
                if (i == chatBackgroundPresets.length + 1) {
                  return _BlurTile(
                    current: ctrl.background.blur,
                    onChanged: (v) => ctrl.setBackground(ChatBackground(
                      type: ctrl.background.type,
                      color: ctrl.background.color,
                      colors: ctrl.background.colors,
                      begin: ctrl.background.begin,
                      end: ctrl.background.end,
                      image: ctrl.background.image,
                      blur: v,
                    )),
                  );
                }
                final preset = chatBackgroundPresets[i];
                return _PresetTile(
                  preset: preset,
                  selected: _eq(ctrl.background, preset),
                  onTap: () => ctrl.setBackground(preset),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _eq(ChatBackground a, ChatBackground b) =>
      a.type == b.type &&
      a.image == b.image &&
      a.color?.value == b.color?.value &&
      (a.colors?.map((c) => c.value).join(',') ?? '') ==
          (b.colors?.map((c) => c.value).join(',') ?? '') &&
      a.blur == b.blur;
}

class _PresetTile extends StatelessWidget {
  final ChatBackground preset;
  final bool selected;
  final VoidCallback onTap;
  const _PresetTile({required this.preset, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ChatBackgroundLayer(background: preset),
            if (selected)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon), const SizedBox(height: 8), Text(label)],
          ),
        ),
      ),
    );
  }
}

class _BlurTile extends StatefulWidget {
  final double current;
  final ValueChanged<double> onChanged;
  const _BlurTile({required this.current, required this.onChanged});
  @override
  State<_BlurTile> createState() => _BlurTileState();
}
class _BlurTileState extends State<_BlurTile> {
  double _v = 0;
  @override
  void initState() { super.initState(); _v = widget.current; }
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.blur_on),
            const SizedBox(height: 4),
            const Text('Desenfoque', style: TextStyle(fontSize: 12)),
            Slider(
              min: 0, max: 12, divisions: 12,
              value: _v,
              onChanged: (v) => setState(() => _v = v),
              onChangeEnd: widget.onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
