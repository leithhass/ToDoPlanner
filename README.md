Todo Planner
Todo Planner is a Flutter app that runs 100% offline. It helps you manage tasks with priorities, due dates, tags, smart groupings, local notifications, JSON export/import, and an Insights page with charts. It’s designed to showcase solid product thinking, a clean architecture, and a polished Material 3 UI.
✨ Features
Task management
Create tasks with title, priority (Low/Med/High), optional due date, and tags.
Search instantly from the top bar and filter by tags (chip filters).
Smart grouping in the list: Overdue, Today, Upcoming, No date, Completed, Trash.
Mark done/undone (leading icon or tap), multi-select with bulk actions.
Trash + Undo (SnackBar action).
Visual clarity
Material 3 theme using ColorScheme.fromSeed, filled chips, readable priority badges,
and cards with large radii and a subtle colored tint/outline by priority.
Light/Dark modes supported.
Local notifications
Schedule notifications for tasks with a due date; cancel automatically when a task is completed or trashed.
Data ownership
Export all tasks to JSON.
Import from JSON via file picker, with a graceful “paste JSON” fallback if the picker isn’t available.
Insights (stats)
Completion rate.
Last 8 weeks bar chart (created vs. completed).
Top tags.
Priority distribution pie chart.
Offline by design
Local storage only (Hive). No backend required.
🧱 Architecture
Layered, testable structure with a clear separation of concerns:
lib/
  main.dart
  core/
    theme.dart                // Material 3 theme + tokens
    design_tokens.dart        // Seed color, radii, spacing, helpers
    widgets/
      app_card.dart
      app_button.dart
      app_text_field.dart
      empty_state.dart
  features/todos/
    data/
      todo_box.dart           // Local persistence (Hive)
    domain/
      todo.dart               // Entity (id, title, done, createdAt, dueDate?, priority, tags, deletedAt?)
    application/
      todos_controller.dart   // Riverpod Notifier: CRUD + notifications sync
      filters.dart            // search/tag/completed/trash filters
      grouping.dart           // Overdue/Today/Upcoming/...
      analytics.dart          // Aggregations for Insights
    presentation/
      pages/
        todos_home.dart       // Main screen (thin, declarative)
        insights_page.dart    // Charts (fl_chart)
      widgets/
        add_todo_sheet.dart   // Bottom sheet to add tasks
        tag_filter_bar.dart   // Tag chips
        todo_tile.dart        // Reusable task tile
  infrastructure/
    export_service.dart       // JSON export/import (picker + paste fallback)
  services/
    notification_service.dart // flutter_local_notifications + timezone
Domain: pure model
Data: persistence adapters (Hive)
Application: business logic & providers (Riverpod)
Presentation: UI widgets & pages
Infrastructure/Services: cross-cutting concerns (export/notifications)
🧰 Tech Stack
Flutter (Material 3, implicit animations)
State: hooks_riverpod
Storage: hive, hive_flutter
Notifications: flutter_local_notifications, timezone
Files: path_provider, file_picker (+ paste fallback)
Charts: fl_chart
Recommended Flutter: 3.22+, Dart 3+.
🚀 Getting Started
1) Install dependencies
flutter pub get
2) iOS setup
cd ios
pod install
cd ..
3) Initialize notifications (already wired)
In main.dart, NotificationService.instance.init() is called before runApp().
On Android 13+, the app requests runtime notification permission; on iOS, it asks on first launch.
4) Run
flutter run
🔔 How to test notifications
Create a task with due date = now + 1–2 minutes.
Background the app / lock the device.
You should receive a local notification at the due time.
Mark the task completed before the due time → the notification for that task should be canceled.
If nothing shows:
iOS: Settings → Notifications → allow for this app; check Focus/Do Not Disturb.
Android 13+: ensure the permission prompt was granted.
Simulators sometimes need a restart.
↔️ Export / Import
Export: AppBar menu → Export JSON
A JSON file is created in the app’s documents directory.
Import: AppBar menu → Import JSON
Uses the file picker; if unavailable, a dialog lets you paste JSON.
JSON shape (example):
[
  {
    "id": "1719876543210",
    "title": "Review chapter 3",
    "done": false,
    "createdAt": "2025-10-08T09:30:00.000",
    "dueDate": "2025-10-08T10:30:00.000",
    "priority": 1,
    "tags": ["study", "math"],
    "deletedAt": null
  }
]
📊 Insights (what you’ll see)
Completion rate (overall %).
Last 8 weeks: two bars per week (created vs. completed).
Top tags: frequency of tags on active tasks.
Priority distribution: Low/Med/High across active tasks.
🎨 UI/UX Notes
Material 3 with a seed color and tinted surfaces (less “flat gray” than defaults).
Large radii on cards (20–28), subtle outline + soft shadow.
Filled chips, clear priority badges, and CTA FAB that stands out.
Light/Dark mode, focus states, and touch targets ≥ 44 px.
Change the app’s look by updating the seed color in core/design_tokens.dart.
🧪 Testing (recommended for portfolio)
Unit tests: domain (todo.dart), grouping, filters, analytics.
Golden tests: empty state, grouped lists, dark mode.
Integration: “create → complete → trash → undo”.
CI: GitHub Actions for flutter analyze, tests, (optional) golden diffs and Web build.
🛣️ Roadmap (nice next steps)
Recurring tasks (daily/weekly) generated locally.
Subtasks/checklists and local attachments (photos/voice notes).
Theme settings page (switch seed color, toggle blur/animations).
i18n (en/fr/ar) with ARB files.
Optional Hive encryption (key via flutter_secure_storage).
CSV export.
