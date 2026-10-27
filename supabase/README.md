# SocialFlow AI — Cloud Supabase Setup Guide

This guide walks you through connecting your Cloud Supabase project to SocialFlow AI.

---

### Step 1: Create Your Supabase Cloud Project
1. Log in to [supabase.com](https://supabase.com/dashboard).
2. Click **New project** and select your organization.
3. Enter project details:
   - **Name**: `socialflow-ai`
   - **Database Password**: Set a strong password (save it safely).
   - **Region**: Choose the region closest to your users.
4. Click **Create new project** and wait for the database to provision (~2 minutes).

---

### Step 2: Apply the Database Schema & RLS Policies
1. In your Supabase Dashboard, go to **SQL Editor** in the left sidebar.
2. Click **New query**.
3. Open [`supabase/migrations/20261026000000_init_socialflow_schema.sql`](file:///c:/Users/GENT/StudioProjects/socialflow/supabase/migrations/20261026000000_init_socialflow_schema.sql).
4. Copy the entire SQL content and paste it into the SQL Editor.
5. Click **Run**.
   - This creates all 5 tables: `profiles`, `automation_rules`, `connected_accounts`, `posts`, and `interactions`.
   - Enables Row Level Security (RLS) policies so each user's data remains completely private and isolated.
   - Sets up automatic profile and safety rule initialization upon sign-up.

---

### Step 3: Retrieve Project Credentials
1. Go to **Project Settings** (gear icon at the bottom left) > **API**.
2. Copy the following values:
   - **Project URL** (e.g., `https://xyzcompany.supabase.co`)
   - **Project API Keys** -> `anon` / `public` key

---

### Step 4: Run the Flutter App with Your Cloud Credentials
You can pass the credentials directly when launching Flutter:

```bash
flutter run --dart-define=SUPABASE_URL=https://<your-project-ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

Or for Windows desktop:
```bash
flutter run -d windows --dart-define=SUPABASE_URL=https://<your-project-ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

---

### Step 5: Configure Meta OAuth Redirect URL (When Ready)
In your Supabase project under **Authentication > URL Configuration**:
- **Site URL**: `socialflow://auth-callback` (or your web URL if running web)
- **Redirect URLs**: Add `socialflow://**` and `http://localhost:3000/**`
