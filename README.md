# Quad local calendar

Quad is now configured for local-only use. It stores events, labels, settings, reminders, and timetable data in the browser using IndexedDB with localStorage fallback.

Supabase and cross-device synchronization are not used by the app.

## Use the calendar

Open the app in a browser. Create and edit events normally. Use the menu to export a JSON backup or restore a previous backup.

The data belongs to the current browser profile. Different devices do not share changes.

## Clean local reset

Use **Menu > Erase all data** to remove the calendar from the current browser. The built-in default labels and seed academic dates are restored after reload.

For a completely clean browser test, clear site data for the app origin, including IndexedDB and localStorage, then reload the page.

## Deployment

The app can still be hosted on GitHub Pages or opened through a local web server. XAMPP, Apache, PHP, MySQL, and Supabase are not required.

The app has no cloud database dependency.
