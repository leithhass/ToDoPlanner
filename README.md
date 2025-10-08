<b>Todo Planner</b><br>
A 100% offline Flutter app for managing tasks with priorities, due dates, tags, smart groupings, local notifications, JSON export/import, and an Insights page (charts). Built to showcase solid product thinking, clean architecture, and a polished Material 3 UI.<br><br>

<b>Features</b><br>
• Task management: create tasks (title, priority Low/Med/High, optional due date, tags), mark done/undone (leading icon or tap), multi-select with bulk actions, Trash + Undo (SnackBar).<br>
• Search & filters: instant search; tag filters via chips.<br>
• Smart grouping: Overdue, Today, Upcoming, No date, Completed, Trash.<br>
• Visual clarity: Material 3 (ColorScheme.fromSeed), filled chips, readable priority badges, large-radius cards with subtle priority-tinted outline/shadow, Light/Dark modes.<br>
• Local notifications: schedule for due tasks; auto-cancel when completed or trashed.<br>
• Data ownership: export all tasks to JSON; import via file picker with a graceful “paste JSON” fallback.<br>
• Insights: completion rate; last 8 weeks (created vs completed); top tags; priority distribution.<br><br>

<b>Architecture</b><br>
<pre>lib/
  main.dart
  core/
    theme.dart
    design_tokens.dart
    widgets/
      app_card.dart
      app_button.dart
      app_text_field.dart
      empty_state.dart
  features/todos/
    data/
      todo_box.dart
    domain/
      todo.dart
    application/
      todos_controller.dart
      filters.dart
      grouping.dart
      analytics.dart
    presentation/
      pages/
        todos_home.dart
        insights_page.dart
      widgets/
        add_todo_sheet.dart
        tag_filter_bar.dart
        todo_tile.dart
  infrastructure/
    export_service.dart
  services/
    notification_service.dart
</pre>

<b>Tech Stack</b><br>
Flutter (Material 3, implicit animations), hooks_riverpod, hive + hive_flutter, flutter_local_notifications + timezone, path_provider, file_picker (with paste fallback), fl_chart. Recommended: Flutter 3.22+, Dart 3+.<br><br>

<b>Getting Started</b><br>
1) Install deps: <code>flutter pub get</code><br>
2) iOS setup: <code>cd ios</code> → <code>pod install</code> → <code>cd ..</code><br>
3) Run: <code>flutter run</code><br>
Notifications are initialized before <code>runApp()</code>. Android 13+ prompts runtime permission; iOS asks on first launch.<br><br>

<b>Usage</b><br>
Add tasks (title/priority/due/tags) → search & filter by tags → tap leading icon or card to toggle done → long-press for multi-select → use Trash & Undo → menu (⋮) for Export/Import → <i>Insights</i> button for charts.<br><br>

<b>Notifications – quick test</b><br>
Create a task with due = now + 1–2 minutes → background/lock → notification fires at due time → if you complete before due, it is canceled. If nothing appears: iOS Settings › Notifications (allow; check Focus), Android 13+ ensure permission; simulators sometimes need a restart.<br><br>

<b>Export / Import</b><br>
Export: AppBar menu → Export JSON (saved in app documents). Import: AppBar menu → Import JSON (file picker, or paste JSON fallback). JSON example:<br>
<pre>[
  {"id":"1719876543210","title":"Review chapter 3","done":false,
   "createdAt":"2025-10-08T09:30:00.000","dueDate":"2025-10-08T10:30:00.000",
   "priority":1,"tags":["study","math"],"deletedAt":null}
]</pre>

<b>Testing (suggested)</b><br>
Unit: domain/grouping/filters/analytics. Golden: empty state, grouped lists, dark mode. Integration: create → complete → trash → undo. CI: GitHub Actions for <code>flutter analyze</code>, tests, optional golden diffs & Web build.<br><br>

<b>Roadmap</b><br>
Recurring tasks (daily/weekly); subtasks/checklists; local attachments (photos/voice notes); theme settings (seed color/blur/animations); i18n (en/fr/ar); optional Hive encryption (flutter_secure_storage); CSV export.<br><br>
