import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
  if (!auth.isLoggedIn) {
    Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
    return const SizedBox(); // o un loader
  }
  // ... tu pantalla protegida aquí
    // Mensajes de ejemplo
    final List<Map<String, dynamic>> messages = [
      {
        "from": "Sophia",
        "avatar":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuAzANiXBGLqBdeZsVQt_k9iMhseo2EV1nDTxBLSgEZMGk74ZV0mqE26DdEZJteDGl1goz_M9GsUymFrZcNqmrhfMnqDUflIYiS4jGaYpNJbt2q43Mdhh_XA3CXScYztnCbPvZyOCKfjV_nxPipuiWyU8R_j_MvgQptTPr9kmvq3NqyEiiGsWYftsmR8dHBXGc5vuzqJIzHyzG_D4NsFF-nIJDoJ-eo7UYIZD0_xvOHT1H8gncHK4d5YqSe5BotTnuNWV3DV5NSUETdv",
        "text": "Hey there! How can I help you today?",
        "isUser": false
      },
      {
        "from": "User",
        "avatar":
            "https://lh3.googleusercontent.com/aida-public/AB6AXuC-OajMIYab03QGBnnkZI3mvuK26WqKLD-k6QxttDoKpNBO7Mlc-zFe470pcijcbQ8csQFmlOf-CW2bjcIF8IIp1o2-xjA_qYjY0YYQA6_3ldP1PQNaADGiHiXou1L59SPXe6Tk0v3wFTdE9xBH9frm9vKpECyDyCTTsv1lUUKJNnFhXBoytPl3g8LhYncEK9JgTgIfgWk488GP_f581mWcLCDSGlNZdbDdtsS5cpRS8PVelDjlQSCX57xF1M__HkiUa1u-JjwMUaEr",
        "text":
            "Hi Sophia, I'm looking for some advice on managing my time better.",
        "isUser": true
      },
      // Más mensajes...
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF141216),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141216),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuCyGf3L_moyY2K0WZ_tp2Jmr1PNRSaiJO3o5uomwcVV2K5lFBBBCDu4t3CNxtIn4omgrmklH1kv5D7rvmJYUV9ZKZte396u43GIEaS1SPs8ki4U-nPW5WrP6fJwJWo8_ThPUkW_8Kqy1Fu0Css9tJMHEj36JQVn0ZnCG87VGd7vA0ergNu7d071ZXacbiu8Sg-1VpVnH1_XJjA_NHvB1mDjSTKJIeWn0ws_wcqtH6ll8VaySyYs3pGc5Ij00GCx7UwIPAnVjvHzKZAV"),
              radius: 18,
            ),
            const SizedBox(width: 10),
            const Text("MINE", style: TextStyle(color: Colors.white)),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: messages.length,
              itemBuilder: (context, idx) {
                final msg = messages[idx];
                final isUser = msg['isUser'] as bool;
                return Row(
                  mainAxisAlignment:
                      isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!isUser)
                      CircleAvatar(
                        backgroundImage: NetworkImage(msg['avatar']),
                        radius: 20,
                      ),
                    if (!isUser) const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 260),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFFc1b2e5)
                            : const Color(0xFF2f2c35),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        msg['text'],
                        style: TextStyle(
                          color: isUser
                              ? const Color(0xFF141216)
                              : Colors.white,
                        ),
                      ),
                    ),
                    if (isUser) const SizedBox(width: 8),
                    if (isUser)
                      CircleAvatar(
                        backgroundImage: NetworkImage(msg['avatar']),
                        radius: 20,
                      ),
                  ],
                );
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: const Color(0xFF201e24),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2f2c35),
                      hintText: "Type a message",
                      hintStyle: const TextStyle(color: Color(0xFFa7a2b3)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.mic, color: Color(0xFFa7a2b3)),
                  onPressed: () {},
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFc1b2e5),
                      foregroundColor: const Color(0xFF141216),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24))),
                  child: const Text("Send"),
                ),
              ],
            ),
          ),
          // Barra de navegación inferior (sólo estructura visual)
          Container(
            color: const Color(0xFF201e24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Icon(Icons.chat_bubble, color: Colors.white),
                Icon(Icons.history, color: Color(0xFFa7a2b3)),
                Icon(Icons.person, color: Color(0xFFa7a2b3)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
