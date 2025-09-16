import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<Map<String, dynamic>?> _fetchUserData(String userId) async {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$userId');
      final snap = await ref.get();
      if (snap.exists) {
        return Map<String, dynamic>.from(snap.value as Map);
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do usuário: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
      ),
      body: user == null
          ? const Center(
              child: Text('Nenhum usuário autenticado',
                  style: TextStyle(color: Colors.white)),
            )
          : FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserData(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar perfil: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white)),
                  );
                }
                final data = snapshot.data ?? {};

                final nome = (data['firstName'] ?? '').toString().trim();
                final sobrenome = (data['lastName'] ?? '').toString().trim();
                final email = (data['email'] ?? user.email ?? '').toString();
                final role = (data['role'] ?? '').toString();
                final phone = (data['phone'] ?? '').toString();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                color: Colors.black, size: 40),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        (nome.isNotEmpty || sobrenome.isNotEmpty)
                            ? '$nome $sobrenome'.trim()
                            : (user.displayName ?? 'Usuário'),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _infoCard(children: [
                        _infoRow('Email', email),
                        _infoRow(
                            'Cargo', role.isNotEmpty ? role : 'Não informado'),
                        if (phone.isNotEmpty) _infoRow('Telefone', phone),
                      ]),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await FirebaseAuth.instance.signOut();
                                if (!mounted) return;
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.logout),
                              label: const Text('Sair'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _infoCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
