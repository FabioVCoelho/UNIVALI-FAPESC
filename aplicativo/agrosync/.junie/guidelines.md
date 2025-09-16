Project: AgroSync (Flutter)

Scope
- Audience: Advanced Flutter developers contributing to AgroSync.
- Goal: Capture project-specific build/config, testing, and development practices that aren’t obvious from generic Flutter docs.
- Source of truth for improvement work: See docs/tasks.md. The checklists there define current priorities and conventions; keep code and docs aligned.

Project Architecture Overview
- Clean architecture with 3 layers:
  - Presentation: Flutter UI, state management via Bloc/Cubit. Dispatches user intents and renders states.
  - Domain: Business logic and models/entities (e.g., User, Plant, Role). Framework-agnostic; exposes use cases. Prefer immutable, equatable types.
  - Data: Repositories orchestrate data sources (Firebase remote, Hive local). Remote/local data sources are isolated, models map to entities.
- Data flow:
  1) Presentation dispatches actions to Domain.
  2) Domain uses Repositories from Data to read/write.
  3) Repositories choose Firebase or Hive depending on connectivity and sync state.
  4) Results propagate back to Presentation to update UI.

Core Features and Implementation Details
1) Authentication and User Management
- Firebase Authentication (email/password) via firebase_auth. Encapsulate logic in a UserAuthService (or AuthRepository + use cases) that also checks connectivity.
- Role-Based Access Control (RBAC):
  - users collection: document per user with id and roles: ["ADMIN", "MERGE_CONTENT", ...].
  - roles collection: documents with metadata incl. is_public flag.
  - Offline roles: on online login, cache roles in Hive; offline login checks cached roles. is_public pages are accessible without auth.
  - Guest mode: Offline guest session stored in Hive (plant_meta_box). RoleNavigator allows access to Roles.publicDefaults without Firestore.

2) Database Management and Synchronization
- Dual database strategy:
  - cloud_firestore is the primary remote DB.
  - hive is the local DB mirroring remote collections where practical.
- Offline-first operations: create/update/delete first in Hive; enqueue for sync.
- SyncService: background worker observing connectivity; on connection, pushes local changes to Firestore.
- IDs: use UUIDs (uuid package) for all plant records to avoid collisions when offline.
- Conflict detection: maintain last_modified (serverTimestamp remotely; DateTime locally). On sync, if both changed since last sync, flag conflict.
- False conflict prevention: after online add/update or sync, refresh local cache with server metadata (lastUpdated/createdAt) so subsequent edits carry correct timestamps.
- Merge control: provide a Merge Conflict page (features/merge/...) restricted to MERGE_CONTENT role. Show side-by-side versions, allow choose/merge/keep both.
- History: maintain a history sub-collection per plant with change logs (who, timestamp, diffs/notes).

3) Plant Management
- Register Plants page is offline-first; saves new plant with UUID into Hive first, syncs later. Public access is controlled by RBAC; by default only Credits is public for guests.
- Plant model minimally includes: id (UUID string), name, last_modified (DateTime/Timestamp), plus domain-relevant fields.

Build and Configuration
1) Flutter/Dart toolchain
- Use latest stable Flutter matching what the repo was last upgraded/tested with. Check pubspec.yaml and .dart_tool for hints. As of recent work, flutter_test is present and standard.
- Run: flutter --version and flutter doctor -v to validate local setup.

2) Firebase initialization
- main.dart initializes Firebase with explicit FirebaseOptions (no platform config files required at runtime):
  Firebase.initializeApp(options: FirebaseOptions(apiKey: ..., appId: ..., projectId: ..., etc))
- Consequences:
  - google-services.json / GoogleService-Info.plist are not strictly required to run the app because options are supplied in code. If you later migrate to file-based config, ensure to integrate the Gradle plugin and plist setup.
  - If you fork/ship to a different project, replace the FirebaseOptions in lib/main.dart with that project’s values or provide them via a compile-time/env indirection (e.g., flavors or --dart-define) and wire them to initializeApp.

3) Hive local storage
- main.dart initializes Hive and registers PlantAdapter, then opens two boxes:
  - plant_box (primary data)
  - plant_meta_box (metadata cache)
- Adapter registration: Hive.registerAdapter(PlantAdapter()) requires Plant model to have a generated/handwritten TypeAdapter (lib/models/plant.dart). If you extend Plant fields, update adapter accordingly and consider a box migration strategy.
- Debug helpers: There’s a limparHive() function that clears plant_box. Only call in dev tools or guarded code paths.

4) Dependency Injection and Bloc
- DI container is in lib/core/di/injection_container.dart, initialized via await di.init() in main.dart.
- UI uses flutter_bloc with a PlantBloc registered in MultiBlocProvider. If you add new blocs, register them in DI and wire providers at the app/root widget where applicable.

5) Android/Gradle specifics
- android/app/build.gradle recently changed; confirm minSdkVersion and Kotlin/Gradle plugin versions align with your local Flutter.
- If you later switch to file-based Firebase config, add com.google.gms.google-services plugin and a google-services.json under android/app.

6) Assets
- Assets exist under assets/ (icons, images, logo, data). If you add assets, declare them in pubspec.yaml under flutter: assets:.

Testing
1) Unit/Widget tests (Dart)
- Framework: flutter_test is already included in pubspec.yaml (dev_dependencies).
- Standard commands:
  - flutter test                # runs all tests under test/
  - flutter test -r expanded    # expands output
  - flutter test test/file.dart # run a single file

2) Recommended structure
- Unit tests for pure logic under test/<feature>/...
- Widget tests under test/widgets/... and use WidgetTester with pumpWidget.
- Avoid Firebase/Hive side-effects in unit tests:
  - For repository/bloc tests, isolate through abstractions and inject fakes/mocks.
  - For storage, consider in-memory adapters or mock interfaces.

3) Example: simple unit test (validated pattern)
- Create test/smoke_test.dart with the following content:

  import 'package:flutter_test/flutter_test.dart';

  void main() {
    group('Smoke', () {
      test('adds numbers correctly', () {
        int add(int a, int b) => a + b;
        expect(add(2, 3), 5);
      });

      test('string utilities work', () {
        String normalize(String s) => s.trim().toLowerCase();
        expect(normalize('  Hello '), 'hello');
      });
    });
  }

- Run: flutter test
- Expected: 2 passing tests, no external services required.
- After verifying locally, remove the temporary file if it was only created for smoke validation.

4) Adding new tests
- For Bloc tests, prefer bloc_test package patterns:
  - Given-When-Expect style with seeded states and mocked repositories.
- For repository tests, mock remote data sources (Firebase/RTDB/Firestore) and Hive interfaces. Do not attempt to initialize Firebase in unit tests; instead provide fakes.
- For widget tests touching DI, initialize the DI container in setUpAll with test registrations (fakes) or inject dependencies explicitly at widget construction.

5) Integration tests
- There is no integration_test/ folder by default. If you add it:
  - Add integration_test and use flutter test integration_test or flutter drive (legacy). Keep Firebase interactions limited to a sandbox project.

Development Guidelines and Debugging
1) Code style and analysis
- analysis_options.yaml is present. Run: flutter analyze. Fix lints as per configured rules.
- Prefer immutable models and explicit null-safety. Keep business logic out of UI widgets.

2) State management
- Use Bloc/Cubit for presentation. Keep PlantBloc logic isolated and covered with unit tests. Repositories should abstract remote/local sources.

3) Data layer
- Be careful with Hive schema evolution. When changing Plant fields:
  - Bump type adapter if needed and ensure backward compatibility or provide migration.
  - Handle empty/missing boxes gracefully.

4) Firebase
- Initialization is wrapped in try/catch in main.dart; retain robust error logging. In debug builds, surface initialization failures to developers (e.g., via debugPrint and banners) instead of failing silently.
- If moving to dynamic configs per flavor, expose FirebaseOptions via top-level getters conditioned by const bool.fromEnvironment or a config file.

5) Troubleshooting checklist
- Android build errors after Flutter upgrade: align Gradle, Kotlin, AGP, and minSdk in android/build.gradle and android/gradle/wrapper/gradle-wrapper.properties.
- iOS/macOS Firebase linking issues when switching from code-based options to plist: ensure GoogleService-Info.plist is in target and bundle.
- Hive errors (Adapter not found): confirm Hive.registerAdapter(PlantAdapter()) runs before opening boxes and that the adapter typeId matches stored box data.
- Filters not applying after edits: ensure PlantBloc persists last filter criteria and re-applies on each PlantLoaded; see lib/features/plants/presentation/bloc/plant_bloc.dart helpers.
- Graph not refreshing after returning from subpages: when pushing pages that can alter plant data, await navigation and pushReplacement to rebuild HomePage.
- Unexpected merge conflicts after self-edit: verify local cache updated with server lastUpdated/createdAt after remote writes (repository refresh step).

6) Performance and logging
- Avoid heavy synchronous work during app start. Defer network-prefetches. Use debugPrint for dev logs; gate verbose logs behind kDebugMode.

7) Security
- Current Firebase options are embedded in source. While not secrets, consider environment-based config for non-production builds and avoid committing sensitive keys if later added.

How to Contribute
- Run: flutter pub get, flutter analyze, and flutter test before submitting.
- Keep commits scoped. When touching DI or initialization flows, update this guideline if behavior changes.
- For architecture, performance, security, UX, technical-debt tasks and acceptance criteria, follow docs/tasks.md. Update both code and the checklist together to keep them in sync.

Project Structure and File Organization
- lib/
  - main.dart
  - core/
    - constants/
    - services/
      - firebase_service.dart
      - hive_service.dart
      - sync_service.dart
    - models/
      - user.dart
      - role.dart
      - plant.dart
    - providers/
      - connectivity_provider.dart
  - features/
    - auth/
      - data/
        - repositories/
          - auth_repository.dart
        - datasources/
          - auth_local_data_source.dart
          - auth_remote_data_source.dart
      - presentation/
        - widgets/
        - pages/
          - login_page.dart
        - bloc/
          - auth_bloc.dart
    - plants/
      - data/
        - repositories/
          - plant_repository.dart
        - datasources/
          - plant_local_data_source.dart
          - plant_remote_data_source.dart
      - presentation/
        - widgets/
        - pages/
          - register_plant_page.dart
          - plants_list_page.dart
    - merge/
      - presentation/
        - pages/
          - merge_conflict_page.dart

Reusable Custom Widgets (Design System)
- Purpose: Centralize commonly used UI elements as reusable widgets. Change once, update everywhere; easy reuse across projects.
- Location: lib/features/shared/widgets/ (all shared widgets centralized here).
- Principles:
  - Keep visual defaults aligned with app theme; allow pass-through of standard parameters (e.g., onPressed, child, controller, suffixIcon, style, enabled).
  - Provide const constructors when possible; avoid side effects in build.
  - Expose minimal required API; accept optional overrides via named params.
  - Keep widgets framework-agnostic regarding business logic; no direct Firebase/Hive calls inside shared widgets.
- Naming: Use the Custom prefix (CustomButton, CustomTextField, CustomServiceTile, CustomChip). File name must match the class name exactly in CamelCase (e.g., CustomButton.dart).
- Theming: Derive colors/typography from Theme.of(context) when feasible; allow color overrides.
- Testing: Add golden/widget tests under test/widgets/shared/ for key widgets.
- Adoption: Replace ad-hoc UI in screens gradually. When a shared widget changes, verify impacted screens via smoke tests.

Key Packages
- firebase_core: Initialize Firebase.
- firebase_auth: User authentication.
- cloud_firestore: Remote database.
- hive: Local database for offline.
- connectivity_plus: Network status.
- flutter_bloc / bloc: State management.
- uuid: Unique ID generation.
