# Quad cloud sync

The GitHub Pages version can use Supabase directly. XAMPP, Apache, PHP, and MySQL are not required for normal use after this setup.

## Supabase setup

1. Create a Supabase project at https://supabase.com.
2. Open **SQL Editor**.
3. Paste and run [supabase-schema.sql](supabase-schema.sql).
4. Open **Project Settings > API** and copy the Project URL and publishable/anon key.

The anon key is intended for browser applications. Never put a Supabase service-role key in this website.

## Configure each device

Open https://ottohui.github.io/procalendar/, open the menu, and choose **Sync settings**. Enter the same Supabase URL, anon key, and shared calendar key on every device. Use a different device id for each device and enable sync. Press **Sync now** after saving.

The app keeps IndexedDB as an offline cache and merges local and cloud events before saving the combined calendar.

## Clean testing procedure for a new app version

Use the steps below whenever you publish a new version and want to test the sync flow from a clean state.

1. Delete every row from the Supabase table before testing.
   - In Supabase SQL Editor, run:
     DELETE FROM public.quad_sync;
2. Re-run [supabase-schema.sql](supabase-schema.sql) to recreate the table and policies.
   - This also installs the database trigger that refreshes `quad_sync.updated_at` on every update.
3. On each device, clear the browser data for the site before testing.
   - Open the site in the browser.
   - Open Developer Tools.
   - Go to Application or Storage.
   - Clear site data / storage for this origin.
   - Also delete the old IndexedDB data for the origin if shown.
4. Hard refresh the page once after clearing storage.
5. Open the app again on the Mac and iPad with the same Supabase project URL, anon key, and same shared calendar key.
6. Use different device ids, for example:
   - Mac: `device-mac-test-01`
   - iPad: `device-ipad-test-01`
7. Do not reuse old sample names such as `English` or older test titles. Use new unique names such as:
   - `sync-check-mac-01`
   - `sync-check-ipad-01`
8. On the Mac, create one new event and edit another event. Sync once.
9. On the iPad, refresh the page, then click **Sync now** once. Confirm that the latest Mac snapshot appears and no old stale event remains.
10. Test a real merge: while both devices have the same calendar, create `merge-mac-01` on the Mac and create `merge-ipad-01` on the iPad before either device syncs again. Sync the Mac, then sync the iPad. Both events must remain visible on both devices.
11. On the Mac, sync again and confirm the same final state is still present. A device must not replace a newer database snapshot with its older local snapshot.
12. In Supabase SQL Editor, verify that the server row timestamp changes after a sync:
   ```sql
   SELECT token, device_id, updated_at, snapshot->'events' AS events
   FROM public.quad_sync;
   ```
13. If a sync happens at the same time as another device update, the app pulls the newer row and retries the merge. If it reports a conflict, sync that device once more; do not erase the database.
14. If the app still shows old data, close the tab, clear site data again, and repeat from step 1.

Important: do not test with old calendar entries or older names from previous experiments, because stale local browser data can make a clean test look broken. Use short unique names only.

## Security note

This simple shared-calendar version uses the shared calendar key as the calendar identifier. Anyone who knows both the public Supabase URL and that key can access that calendar. Do not store private or sensitive information in it. Supabase Auth and user-based RLS can be added later for private accounts.

The app is intentionally lightweight and does not require XAMPP, Apache, PHP, or MySQL.
