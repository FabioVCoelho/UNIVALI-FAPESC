
import 'package:agrosync/features/plants/presentation/pages/plant_consultation_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:agrosync/features/services/pdf/presentation/pdf_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrosync/features/shared/widgets/CustomServiceTile.dart';
import 'package:agrosync/features/shared/widgets/CustomDashboardCard.dart';
import 'package:agrosync/features/shared/widgets/CustomDashboardSection.dart';
import 'package:agrosync/features/shared/widgets/CustomUserHeader.dart';
import 'package:agrosync/core/services/rbac_service.dart';
import 'package:agrosync/core/services/guest_auth_service.dart';

import '../features/plants/presentation/pages/plant_add_page.dart';
import 'adicionar_campo.dart';
import 'creditos.dart';
import 'custom_chart_page.dart';
import 'package:agrosync/features/users/apresentation/profile_page.dart';
import 'package:agrosync/features/users/apresentation/login.dart';
import 'package:agrosync/features/users/apresentation/users_api.dart';
import 'package:agrosync/features/roles/presentation/role_navigator.dart';
import 'package:agrosync/features/plants/presentation/pages/conflict_resolution_screen.dart';
import 'package:agrosync/features/users/apresentation/users_roles_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final _firestore = FirebaseFirestore.instance;

  final GlobalKey chartKey = GlobalKey();

  // Função para buscar o total de plantas registradas no Firestore
  Future<int> _getTotalPlants() async {
    final snapshot = await _firestore.collection('plants').get();
    return snapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B8B3B), // Fundo verde
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com informações do usuário (refatorado para widget compartilhado)
            CustomUserHeader(
              futureUserData: FirebaseAuth.instance.currentUser == null
                  ? Future.value(null)
                  : UsersApi.currentUserRaw(),
              onProfileTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              onLogout: () async {
                await UsersApi.logout();
                await GuestAuthService.signOutGuest();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 12),

            //Grafico
            const SizedBox(height: 0),
            CustomDashboardSection(
              firestore: _firestore,
              repaintKey: chartKey,
            ),

            // Dashboard com métricas do Firebase
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF388E3C), // Verde mais escuro
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CustomDashboardCard(
                    title: 'Plantas Registradas',
                    futureValue: _getTotalPlants(),
                  ),
                  // Removido o card de "Usuários Cadastrados"
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título "Serviços"
            Text(
              'Serviços',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // Grid com os botões
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  CustomServiceTile(
                    icon: Icons.note_add,
                    label: 'Registrar Planta',
                    onTap: () async {
                      final result = await RoleNavigator.guardAndNavigate(
                        context,
                        requiredRoles: [Roles.addPlant, Roles.registerPlants],
                        page: const PlantAddPage(),
                      );
                      // If a plant was added, force the dashboard section to refresh by recreating HomePage
                      if (context.mounted && result == true) {
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => HomePage(),
                            transitionDuration: Duration(milliseconds: 0),
                          ),
                        );
                      }
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  CustomServiceTile(
                    icon: Icons.search,
                    label: 'Consultar Planta',
                    onTap: () {
                      RoleNavigator.guardAndNavigate(
                        context,
                        requiredRoles: [Roles.searchPlant, Roles.viewPlants],
                        page: const PlantConsultationPage(),
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  CustomServiceTile(
                    icon: Icons.picture_as_pdf,
                    label: 'Exportar PDF',
                    onTap: () async {
                      final allowed = await Roles.canAccess(
                        _firestore,
                        userEmail: FirebaseAuth.instance.currentUser?.email,
                        requiredRoles: [Roles.exportPdf],
                      );
                      if (!allowed) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Acesso negado: você não possui permissão para exportar.')),
                        );
                        return;
                      }
                      await PdfService.exportPlantsReportFromFirestore(
                        context: context,
                        firestore: _firestore,
                        chartKey: chartKey,
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  CustomServiceTile(
                    icon: Icons.bar_chart,
                    label: 'Gráfico Personalizado',
                    onTap: () {
                      RoleNavigator.guardAndNavigate(
                        context,
                        requiredRoles: [Roles.viewGraph],
                        page: CustomChartPage(firestore: _firestore),
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  // Mova estes dois para o final:
                  CustomServiceTile(
                    icon: Icons.person,
                    label: 'Creditos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreditosPage(),
                        ),
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  CustomServiceTile(
                    icon: Icons.manage_accounts,
                    label: 'Usuários & Permissões',
                    onTap: () {
                      RoleNavigator.guardAndNavigate(
                        context,
                        requiredRoles: [Roles.listUser],
                        page: const UsersRolesPage(),
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  CustomServiceTile(
                    icon: Icons.merge_type,
                    label: 'Resolver Conflitos',
                    onTap: () {
                      RoleNavigator.guardAndNavigate(
                        context,
                        requiredRoles: [Roles.approveMergeContent],
                        page: const ConflictResolutionScreen(isAdmin: true),
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                  CustomServiceTile(
                    icon: Icons.add_location_alt,
                    label: 'Adicionar Campo',
                    onTap: () {
                      RoleNavigator.guardAndNavigate(
                        context,
                        requiredRoles: [Roles.addNewFields],
                        page: const AdicionarCampoPage(),
                      );
                    },
                    backgroundColor: const Color(0xFF66BB6A),
                    iconColor: Colors.black,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
