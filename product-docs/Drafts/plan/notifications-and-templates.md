# Dottr — Notifications + Templates (Future Steps)

## Step 14: Templates

**What the user gets**: Tap "new entry" and pick from a template instead of starting blank every time. A "Morning check-in" template might pre-fill mood, energy, and gratitude fields with a body scaffold.

### Template model
- **name**: display label (e.g. "Morning Check-in", "Meeting Notes")
- **frontmatter defaults**: pre-filled tags, mood, custom properties
- **body scaffold**: markdown body with placeholder text
- **icon/color**: visual identifier in the template picker

### Storage
- `journal/.dottr/templates.yaml` — lives alongside `schemas.yaml`, syncs with Git
- Each template is a YAML block mirroring Entry frontmatter + body

### UI
- **Template manager** (Settings > Templates): CRUD list, reorder, edit
- **Template picker**: bottom sheet shown on new entry creation (long-press FAB or explicit "from template" option)
- **Editor**: when creating from template, pre-populate all fields + body, mark entry as dirty immediately

### Files to create/modify
- `lib/models/template.dart`
- `lib/services/template_service.dart`
- `lib/providers/template_provider.dart`
- `lib/screens/settings/template_manager_screen.dart`
- `lib/screens/editor/widgets/template_picker.dart`
- Modify: `editor_screen.dart`, `router.dart`, `settings_screen.dart`

---

## Step 15: Configurable Notifications

**What the user gets**: Set up recurring reminders ("Journal at 9pm", "Weekly review on Sunday") that, when tapped, open the app straight into a new entry — optionally pre-filled from a linked template.

### Notification model
- **id**: unique identifier
- **label**: user-facing name (e.g. "Evening journal")
- **schedule**: cron-like config — time of day, days of week, repeat interval
- **enabled**: toggle on/off
- **templateId**: optional link to a template (null = blank entry)

### Behavior
- Tapping a notification deep-links to `/editor?template=<templateId>` (or `/editor` if no template)
- Notification body shows the label, e.g. "Time for your Evening journal"
- Missed notifications don't stack — latest one replaces previous

### Storage
- Persisted locally (not in Git) via `shared_preferences` or a small JSON file in app documents
- Notification scheduling via `flutter_local_notifications`

### New packages
| Package | Purpose |
|---------|---------|
| `flutter_local_notifications` | Schedule and display local notifications |
| `timezone` | Timezone-aware scheduling |
| `shared_preferences` | Persist notification configs locally |

### UI
- **Notification manager** (Settings > Notifications): list of configured notifications, toggle, add/edit/delete
- **Add/edit notification**: time picker, day-of-week selector, template dropdown, label field
- **Deep link handling**: `main.dart` listens for notification tap payload and routes accordingly

### Files to create/modify
- `lib/models/notification_config.dart`
- `lib/services/notification_service.dart`
- `lib/providers/notification_provider.dart`
- `lib/screens/settings/notification_manager_screen.dart`
- `lib/screens/settings/notification_edit_screen.dart`
- Modify: `main.dart` (notification init + deep link), `router.dart`, `settings_screen.dart`, `editor_screen.dart` (accept template param), `pubspec.yaml`

---

## Dependency order

```
Step 14 (Templates) → Step 15 (Notifications)
```

Templates must land first since notifications reference them. Notifications without templates still work (open blank editor), but the full value is template-linked notifications.
