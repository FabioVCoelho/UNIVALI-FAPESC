#### Date
2025-09-09 00:47 (local)

#### Summary
- RBAC expanded with fine-grained DELETE_PLANT and offline guest access model
- Graph refresh flows fixed when returning from Register Plant and Plant Consultation
- Filtering UX improved: shared CustomChip, modal label via TranslationService, chips synced with filters
- PlantBloc made filter-aware to persist criteria across add/update/delete/sync events (race-free)
- Local/remote sync improved to avoid false conflicts by refreshing local metadata after server writes
- Users & Permissions migrated to Bloc; page converted to StatefulWidget; new role visible/assignable
- Added offline guest login using Hive flag; RoleNavigator allows public roles without network
- Updated docs/tasks.md and .junie/guidelines.md accordingly

#### Highlights
- New page: Users & Permissions (lazy roles per user, filter, update, delete with confirmation)
- New Home actions: Conflict Resolution, Users & Permissions tiles with RBAC gating
- Role guarding reusable across UI via RoleNavigator
- Home no longer builds PDFs or fetches export data; delegates fully to PdfService
- Removed trivial wrapper methods in Home (favor direct widget usage)

#### Details by scope

RBAC (core)
- Added macro roles: ADD_PLANT, SEARCH_PLANT
- Added users management roles: LIST_USER, UPDATE_USER, REMOVE_USER (ADD_USER kept in RBAC but not used by UI)
- Added fine-grained role: DELETE_PLANT; enforced on PlantConsultationPage delete action
- Seed updates (roles collection + admin assignment); VIEW_CREDITS remains public; introduced Roles.publicDefaults for offline guest fallback
- Roles utilities: isRolePublic, fetchUserRoles, canAccess

Roles feature (lib/features/roles)
- domain/role_guard.dart: contract for role checks
- data/firestore_role_guard.dart: adapter delegating to core RBAC
- presentation/role_navigator.dart: guardAndNavigate for UI

Home updates (lib/pages/home_page.dart)
- Graph now refreshes after returning from Register Plant and from Plant Consultation when changes occur (await navigation result and pushReplacement)
- Header: shared CustomUserHeader; logout also clears offline guest state
- Dashboard: CustomDashboardCard + CustomDashboardSection remain
- Services grid: navigation gated via RoleNavigator
- Added/kept tiles with RBAC gating (Users & Permissions, Conflict Resolution)
- Export PDF tile: checks EXPORT_PDF and delegates to PdfService

PDF service (lib/features/services/pdf)
- domain/pdf_exporter.dart: PdfExporter interface
- data/pdf_exporter_impl.dart: builds PDF, optionally captures chart via GlobalKey, saves to Downloads
- presentation/pdf_service.dart: facade for UI

Users feature (lib/features/users)
- domain: UserEntity, UsersRepository
- data: FirebaseUsersRepository (FirebaseAuth + Realtime Database)
- apresentation: UsersApi facade; re-exports for login/profile/signup
- main.dart and Home updated to use features/users imports and UsersApi

Users & Permissions page (lib/features/users/apresentation/users_roles_page.dart)
- Migrated to Bloc (UsersRolesCubit); page converted to StatefulWidget wrapper
- Lists users from RTDB (users/), filter by name/email
- Lazy-load user roles from role_user/{email} on expand
- Shows checkbox list of all roles from roles collection
- Enables bottom "Aplicar" only when changes pending; applies batched updates (requires UPDATE_USER)
- Delete shows confirmation and removes RTDB profile + Firestore mapping (requires REMOVE_USER)
- Role labels/descriptions via TranslationService

Docs
- docs/tasks.md: updated with new role (DELETE_PLANT), Bloc migration note, and persistent filters in PlantBloc
- .junie/guidelines.md: clarified offline-first flows, guest mode, and rebuild/refresh patterns

#### Breaking changes
- None for runtime behavior, but:
    - Home relies on new shared widgets and RoleNavigator; custom helper methods were removed.
    - PDF export is now delegated to PdfService; any external callers should switch accordingly.

#### Migration notes
- If you had custom navigation wrappers for role checks, replace with RoleNavigator.guardAndNavigate
- If you exported PDFs elsewhere, use:
    - PdfService.exportPlantsReport(context: ..., plants: ..., chartKey: ...)
    - or PdfService.exportPlantsReportFromFirestore(context: ..., firestore: ..., chartKey: ...)
- Ensure Firestore collections exist: roles, role_user, meta/seeds; run seedRbac() on startup (already wired in main.dart)

#### Affected files (key)
- lib/core/services/rbac_service.dart
- lib/pages/home_page.dart
- lib/features/shared/widgets/CustomUserHeader.dart
- lib/features/shared/widgets/CustomDashboardCard.dart
- lib/features/shared/widgets/CustomDashboardSection.dart
- lib/features/roles/{domain,data,presentation}/...
- lib/features/services/pdf/{domain,data,presentation}/...
- lib/features/users/{domain,data,apresentation}/...
- lib/features/users/apresentation/users_roles_page.dart
- lib/main.dart
- docs/tasks.md
