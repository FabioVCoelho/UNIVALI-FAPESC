**# AgroSync Improvement Tasks

## Architecture and Code Organization

1. [*] Implement proper architecture pattern (Clean Architecture)
   - [x] Separate UI code from business logic (features and shared widgets; repos/usecases for plants)
   - [x] Create proper use cases for key features (plants: add/get/update/delete/sync)
   - [x] Implement dependency injection for better testability (GetIt DI in core/di; initialized in main)
   - [ ] Extend use cases and DI to remaining legacy screens

2. [*] Refactor data management
   - [x] Create a proper repository layer to abstract data sources (plants feature repo done; users and roles facades added)
   - [x] Implement consistent data models across the application (plants entity + users entity; continue aligning legacy pages)
   - [x] Separate Firestore and Hive implementation details from business logic (plants repo with local/remote; PDF and users separated)
   - [ ] Extend the repository pattern to remaining legacy areas

3. [x] Improve project structure
    - [x] Introduce roles feature scaffolding under lib/features/roles/{data,domain,presentation}; Home uses RoleNavigator for RBAC gating.
    - [x] Organize user-related code under lib/features/users/{data,domain,apresentation} (Login/Profile/UI, repository, entity).
    - [x] Extract PDF building to feature service under lib/features/services/pdf/{data,domain,presentation}; Home delegates to PdfService.
    - [x] Organize files by feature rather than by type (baseline complete; continue incremental moves as needed)
    - [x] Create dedicated directories for widgets, screens, models, repositories, etc. (baseline in place; iterate)
    - [ ] Implement barrel files for cleaner imports

4. [*] Implement proper state management
   - [x] Replace direct setState calls with a more scalable solution (Provider/Bloc) for plants feature and migrated Users & Roles page to Bloc (UsersRolesCubit)
   - [ ] Create dedicated state classes for each screen
   - [x] Implement proper error handling and loading states in blocs/cubits touched (PlantBloc, UsersRolesCubit)

## Performance Optimization

5. [ ] Optimize UI rendering
   - [ ] Implement const constructors where possible
   - [ ] Use ListView.builder with proper keys for all lists
   - [ ] Extract widget methods to separate widget classes to prevent unnecessary rebuilds

6. [ ] Improve data loading and synchronization
   - [ ] Implement pagination for large data sets
   - [ ] Move Firebase operations to background isolates or compute functions
   - [ ] Implement proper caching strategies for remote data

7. [ ] Optimize form handling
   - [ ] Debounce input validation to reduce unnecessary processing
   - [ ] Lazy load dropdown data
   - [ ] Implement form state persistence for multi-page forms

8. [ ] Reduce app size and startup time
   - [ ] Implement proper asset optimization
   - [ ] Use deferred loading for rarely used features
   - [ ] Analyze and remove unused dependencies

## Security Enhancements

9. [ ] Secure authentication implementation
   - [ ] Move Firebase credentials to secure storage or environment variables
   - [ ] Implement proper password validation rules
   - [ ] Add multi-factor authentication option

10. [ ] Improve data security
    - [ ] Encrypt sensitive local data
    - [ ] Implement proper Firestore security rules
    - [ ] Remove sensitive data from logs and debug prints

11. [ ] Implement secure API communication
    - [ ] Use HTTPS for all external API calls
    - [ ] Implement proper API error handling
    - [ ] Add request timeouts and retry mechanisms

12. [x] Add proper user permissions
    - [x] Implement role-based access control (roles collection, role_user mapping, seedRbac wired in main)
    - [x] Restrict data access based on user permissions (RoleNavigator + Roles.canAccess gates; public VIEW_CREDITS)
    - [x] Add audit logging for sensitive operations (plants: creator/modifier tracking + history in Firestore sub-collection and local Hive)

    RBAC Roles (source of truth; keep in sync with lib/core/services/rbac_service.dart):
    - Macro roles:
      - ADD_NEW_FIELDS: Access to Adicionar Campo page.
      - ADD_PLANT: Access to Plant Add page.
      - SEARCH_PLANT: Access to Plant Consultation page.
    - Page roles:
      - VIEW_PLANTS: Access to Plant Consultation page (legacy alias).
      - REGISTER_PLANTS: Access to Plant Add page (legacy alias).
      - EXPORT_PDF: Permission to export PDF in Home.
      - VIEW_GRAPH: Access to Custom Chart page.
      - VIEW_CREDITS: Credits page (public; offline guest allowed via Roles.publicDefaults).
      - APPROVE_MERGE_CONTENT: Access to Conflict Resolution screen.
      - LIST_USER: Access to Users & Permissions page.
      - UPDATE_USER: Permission to update role assignments.
      - REMOVE_USER: Permission to remove a user profile and role mapping.
    - Fine-grained action roles:
      - DELETE_PLANT: Allows deleting plants in the consultation page.

## Code Quality and Maintainability

13. [ ] Improve error handling
    - [ ] Implement global error handling
    - [ ] Add proper error reporting
    - [ ] Create user-friendly error messages

14. [ ] Add comprehensive logging
    - [ ] Implement structured logging
    - [ ] Add log levels (debug, info, warning, error)
    - [ ] Configure remote logging for production

15. [ ] Implement proper testing
    - [ ] Add unit tests for business logic
    - [ ] Implement widget tests for UI components
    - [ ] Add integration tests for critical user flows

16. [ ] Improve code documentation
    - [ ] Add proper documentation for all public APIs
    - [ ] Document complex business logic
    - [ ] Create architecture diagrams

## User Experience Improvements

17. [ ] Enhance form validation
    - [ ] Provide immediate feedback for validation errors
    - [ ] Implement field-specific validation rules
    - [ ] Add helpful error messages

18. [ ] Improve accessibility
    - [ ] Add proper semantic labels
    - [ ] Ensure sufficient color contrast
    - [ ] Support screen readers

19. [ ] Optimize responsive design
    - [ ] Ensure proper layout on different screen sizes
    - [ ] Implement adaptive UI components
    - [ ] Support both portrait and landscape orientations

20. [*] Enhance offline capabilities
   - [x] Implement proper offline data synchronization (Hive-first + SyncService in repo; improved metadata refresh post-sync)
   - [x] Add offline guest mode with local RBAC fallback for public roles
   - [ ] Add offline mode indicator
   - [ ] Provide clear feedback for actions that require connectivity

## Technical Debt Reduction

21. [ ] Refactor large files
    - [ ] Split consulta_tabela.dart into smaller components
    - [ ] Refactor registro_planta.dart to reduce complexity
    - [ ] Extract reusable widgets to separate files

22. [ ] Fix code duplication
    - [ ] Create shared utility functions for common operations
    - [ ] Extract duplicate UI components to reusable widgets
    - [ ] Implement proper inheritance for similar classes

23. [ ] Update dependencies
    - [ ] Upgrade to latest stable Flutter version
    - [ ] Update all packages to compatible versions
    - [ ] Remove unused dependencies

24. [ ] Implement proper error boundaries
    - [ ] Add try-catch blocks for critical operations
    - [ ] Implement fallback UI for component failures
    - [ ] Add proper error recovery mechanisms**

## Internationalization (i18n) and Translations

25. [x] Introduce TranslationService for static texts and roles (en/pt)
    - [x] Add lib/core/services/translation_service.dart with in-memory maps for generic UI keys and RBAC role labels/descriptions
    - [x] Provide API: TranslationService.t(key), roleLabel(roleId), roleDescription(roleId), setLanguage/getLanguage
    - [x] Replace hard-coded labels in login page with TranslationService usages
    - [x] Use TranslationService in filter modal, Apply/Clear labels, and Users & Permissions save button
    - [ ] Gradually replace hard-coded labels across Home and other pages with TranslationService
    - [ ] Wire language selection to user profile (ProfilePage) and persist selection (e.g., Hive/shared_prefs)
