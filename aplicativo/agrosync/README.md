Github: https://github.com/gustavotang/agrosync
# AgroSync

AgroSync is a Flutter application focused on plant management and synchronization, using Firebase and Hive for data storage and flutter_bloc for state management.

## Build and Configuration
- Use the latest stable Flutter that this repo was tested with. Validate with:
  - flutter --version
  - flutter doctor -v
- Firebase is initialized in code via FirebaseOptions in lib/main.dart (no JSON/Plist required at runtime).
- Hive is initialized in main.dart and opens two boxes: plant_box and plant_meta_box.

## Development Tasks and Conventions
The source of truth for improvement work, priorities, and conventions is here:
- docs/tasks.md

When contributing changes that affect architecture, performance, security, testing, or UX, update both the implementation and the corresponding checklist items in docs/tasks.md to keep them in sync.

## Reusable Custom Widgets
- Shared UI lives under lib/features/shared/widgets/. Prefer the shared widgets (e.g., CustomButton, CustomTextField, CustomServiceTile) and pass-through common params to keep screens thin and easily themeable.

## Getting Started
1) Install dependencies:
   - flutter pub get
2) Analyze and test:
   - flutter analyze
   - flutter test
3) Run the app:
   - flutter run

## Contributing
- Keep commits scoped. When touching DI or initialization flows, follow .junie/guidelines.md and update docs/tasks.md as needed.
- Open PRs referencing the checklist items you address in docs/tasks.md.