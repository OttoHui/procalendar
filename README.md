# Quad cross-device sync

This calendar app supports optional shared sync via a lightweight MySQL-backed PHP endpoint.

## 1) Start your database server

If you are using XAMPP:

- Start Apache and MySQL.
- Open phpMyAdmin.
- Create a database called `quad_sync`.
- Import the SQL from `quad-sync/schema.sql`.

## 2) Configure the sync endpoint

Edit `quad-sync/sync.php` if needed:

- DB host: `127.0.0.1` or `localhost`
- DB name: `quad_sync`
- DB user: `root`
- DB password: blank for XAMPP default

If you are using a different MySQL user, update the credentials at the top of the file or set environment variables:

```bash
DB_HOST=127.0.0.1
DB_NAME=quad_sync
DB_USER=root
DB_PASS=
```

## 3) Use the app with sync enabled

Open the app through an HTTP URL rather than a `file://` URL, for example:

# Quad cloud sync

The GitHub Pages version can use Supabase directly. XAMPP, Apache, PHP, and MySQL are not required for normal use after this setup.

## Supabase setup

1. Create a Supabase project at https://supabase.com.
2. Open **SQL Editor**.
3. Paste and run [supabase-schema.sql](supabase-schema.sql).
4. Open **Project Settings > API** and copy the Project URL and publishable/anon key.

The anon key is intended for browser applications. Never put a Supabase service-role key in this website.

## Configure each device

Open https://ottohui.github.io/mycalendar/, open the menu, and choose **Sync settings**. Enter the same Supabase URL, anon key, and shared calendar key on every device. Use a different device id for each device and enable sync. Press **Sync now** after saving.

The app keeps IndexedDB as an offline cache and merges local and cloud events before saving the combined calendar.

## Security note

This simple shared-calendar version uses the shared calendar key as the calendar identifier. Anyone who knows both the public Supabase URL and that key can access that calendar. Do not store private or sensitive information in it. Supabase Auth and user-based RLS can be added later for private accounts.

The old `quad-sync/` PHP files can remain for reference, but they are no longer needed by the GitHub Pages version.
- It is intentionally lightweight and does not require a backend framework.
