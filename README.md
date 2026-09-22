# Quad cloud sync

The GitHub Pages version can use Supabase directly. XAMPP, Apache, PHP, and MySQL are not required for normal use after this setup.

## Supabase setup

1. Create a Supabase project at https://supabase.com.
2. Open **SQL Editor**.
3. Paste and run [supabase-schema.sql](supabase-schema.sql). This creates the original snapshot table and the current per-item sync table. If the original schema was already installed, run the full file again; it is safe to rerun.
4. Open **Project Settings > API** and copy the Project URL and publishable/anon key.

The anon key is intended for browser applications. Never put a Supabase service-role key in this website.

## Configure each device

Open https://ottohui.github.io/procalendar/, open the menu, and choose **Sync settings**. Enter the same Supabase URL, anon key, and shared calendar key on every device. Use a different device id for each device and enable sync. Press **Sync now** after saving.

The app keeps IndexedDB as an offline cache. Every event or label create, edit, and delete queues only that changed item for automatic upload; it does not upload the whole calendar after every edit. While the page is visible, it polls Supabase every five seconds and applies newer remote items to the calendar automatically. The **Sync now** button is a pull/refresh action and flushes only still-pending local changes. Deleted items are retained as tombstones so deletion can sync too. The first sync imports existing data from the old `quad_sync` snapshot table automatically.

After deploying an update, refresh each device once so the new service-worker cache is installed. Then open **Sync settings**, confirm sync is enabled, and press **Sync now**. The Supabase table `quad_sync_items` should contain one row per event or label.

## Security note

This simple shared-calendar version uses the shared calendar key as the calendar identifier. Anyone who knows both the public Supabase URL and that key can access that calendar. Do not store private or sensitive information in it. Supabase Auth and user-based RLS can be added later for private accounts.

The app is intentionally lightweight and does not require XAMPP, Apache, PHP, or MySQL.
