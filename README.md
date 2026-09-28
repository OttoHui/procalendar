# Quad calendar

Quad stores events, labels, settings, reminders, and timetable data in the browser using IndexedDB with localStorage fallback. When Supabase is configured and a user signs in, the calendar is also stored in that user\'s account and is available on other devices.

## Use the calendar

Open the app in a browser. Create and edit events normally. Use the account button to create an account or sign in. Use the menu to export a JSON backup or restore a previous backup.

Without Supabase configuration, data stays in the current browser profile. With an account, each user can only read and write their own calendar, and changes are refreshed across signed-in devices.

## Configure accounts

1. Create a Supabase project.
2. Run [`supabase-schema.sql`](supabase-schema.sql) in the Supabase SQL editor.
3. Copy the project URL and anon key into `SUPABASE_URL` and `SUPABASE_ANON_KEY` near the top of `index.html`.
4. In Supabase Authentication > URL Configuration, set the Site URL to `https://ottohui.github.io/procalendar/` and add these Redirect URLs:
	- `https://ottohui.github.io/procalendar/`
	- `http://localhost:3000/`

The anon key is safe to include in a browser application when row-level security is enabled. Never put a service-role key in `index.html`.

## Clean local reset

Use **Menu > Erase all data** to remove the local calendar from the current browser. The built-in default labels and seed academic dates are restored after reload. Signing out also clears the signed-in calendar from the screen without deleting the account data.

For a completely clean browser test, clear site data for the app origin, including IndexedDB and localStorage, then reload the page.

## Deployment

The app can be hosted on GitHub Pages or opened through a local web server. No server-side runtime is required; Supabase provides authentication and data storage.
