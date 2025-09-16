import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomUserHeader extends StatelessWidget {
  final Future<Map<String, dynamic>?>? futureUserData;
  final VoidCallback onProfileTap;
  final VoidCallback onLogout;

  const CustomUserHeader({
    super.key,
    required this.futureUserData,
    required this.onProfileTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF388E3C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onProfileTap,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: futureUserData == null
                ? _guestName()
                : FutureBuilder<Map<String, dynamic>?>(
                    future: futureUserData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(color: Colors.white);
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return _guestName();
                      }
                      final userData = snapshot.data!;
                      final nome = (userData['firstName'] ?? '').toString().trim();
                      final cargo = (userData['role'] ?? '').toString().trim();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome.isNotEmpty ? nome : 'Usuário não identificado',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Cargo: ${cargo.isNotEmpty ? cargo : 'Não informado'}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }

  Widget _guestName() {
    return Text(
      'Convidado',
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
