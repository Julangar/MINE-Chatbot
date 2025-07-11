import 'package:flutter/material.dart';

class CreateAvatarScreen extends StatelessWidget {
  const CreateAvatarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131118),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131118),
        elevation: 0,
        title: const Text(
          "Customize your avatar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Previsualización avatar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Container(
                  width: 180,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAWloxKCctaMWxk4JCEKm_a2kT3NSFGj1zzkU7eT0-dPsMoeINzyqZ0VZaJ2hgohVbeVXDF4wBhWaAuenMNGsR7OO966eCfIwiZq94nb4qY-j4s2z-xAdmyW9PFxa3Oqhzsn-uLOtbq4twSdGIFdkqpSz84udv368cCI8suuDExAT9_UnL4iD3KKqjyuUYweNzhr-X1EoO4s7ZVHcpdF1Qk4bu7G21Bq5AmG0SNeJi7ElhQtwQyWdVFLeEEMmlQ3tgUz8ggVuVIOxex"),
                    ),
                  ),
                ),
              ),
            ),
            // Botones para subir archivos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2d2938),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Upload Photo or Video",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2d2938),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Upload Audio",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Botón Guardar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5619e5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/chat');
                  },
                  child: const Text(
                    "Save and continue",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "Choose an image or video and a voice sample for your avatar.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFa59db8),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
