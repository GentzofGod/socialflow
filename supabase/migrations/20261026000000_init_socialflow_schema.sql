-- ==============================================================================
-- SocialFlow AI — Master Database Schema & Row-Level Security
-- Framework: Supabase (PostgreSQL 15+)
-- ==============================================================================

-- 1. PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    theme_preference TEXT DEFAULT 'system' CHECK (theme_preference IN ('system', 'light', 'dark')),
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

-- Trigger to auto-create profile on user sign up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        new.id,
        new.email,
        new.raw_user_meta_data->>'full_name',
        new.raw_user_meta_data->>'avatar_url'
    );
    -- Also create default automation rules
    INSERT INTO public.automation_rules (user_id)
    VALUES (new.id);
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 2. AUTOMATION RULES & SAFETY SETTINGS
CREATE TABLE IF NOT EXISTS public.automation_rules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    require_human_approval BOOLEAN DEFAULT true NOT NULL,
    auto_generate_reply_drafts BOOLEAN DEFAULT true NOT NULL,
    safety_filter_profanity BOOLEAN DEFAULT true NOT NULL,
    kill_switch_emergency_pause BOOLEAN DEFAULT false NOT NULL,
    max_daily_actions INT DEFAULT 15 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.automation_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own automation rules"
    ON public.automation_rules FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own automation rules"
    ON public.automation_rules FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own automation rules"
    ON public.automation_rules FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- 3. CONNECTED META ACCOUNTS (Facebook Pages & Instagram Professional)
CREATE TABLE IF NOT EXISTS public.connected_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    platform TEXT NOT NULL CHECK (platform IN ('facebook', 'instagram')),
    account_id TEXT NOT NULL, -- Page ID or IG Business Account ID
    account_name TEXT NOT NULL,
    username TEXT,
    profile_picture_url TEXT,
    access_token TEXT NOT NULL, -- Long-lived token managed server-side
    token_expires_at TIMESTAMPTZ,
    capabilities JSONB DEFAULT '{"publish_post": true, "read_insights": true, "manage_comments": true}'::jsonb NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_user_platform_account UNIQUE (user_id, platform, account_id)
);

ALTER TABLE public.connected_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their connected accounts"
    ON public.connected_accounts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their connected accounts"
    ON public.connected_accounts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their connected accounts"
    ON public.connected_accounts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their connected accounts"
    ON public.connected_accounts FOR DELETE
    USING (auth.uid() = user_id);

-- 4. POSTS & SCHEDULED DRAFTS
CREATE TABLE IF NOT EXISTS public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES public.connected_accounts(id) ON DELETE SET NULL,
    platform TEXT NOT NULL CHECK (platform IN ('facebook', 'instagram', 'all')),
    caption TEXT NOT NULL,
    media_urls TEXT[] DEFAULT '{}'::text[] NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'publishing', 'published', 'failed')),
    scheduled_for TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    meta_post_id TEXT,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their own posts"
    ON public.posts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own posts"
    ON public.posts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own posts"
    ON public.posts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own posts"
    ON public.posts FOR DELETE
    USING (auth.uid() = user_id);

-- 5. ENGAGEMENT INTERACTIONS (Comments, Mentions)
CREATE TABLE IF NOT EXISTS public.interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    account_id UUID NOT NULL REFERENCES public.connected_accounts(id) ON DELETE CASCADE,
    platform TEXT NOT NULL CHECK (platform IN ('facebook', 'instagram')),
    external_id TEXT NOT NULL, -- Meta Comment ID
    parent_post_id TEXT,
    sender_id TEXT NOT NULL,
    sender_name TEXT NOT NULL,
    message TEXT NOT NULL,
    interaction_type TEXT NOT NULL CHECK (interaction_type IN ('comment', 'mention', 'direct_message')),
    status TEXT NOT NULL DEFAULT 'unreviewed' CHECK (status IN ('unreviewed', 'reviewed', 'replied', 'ignored')),
    ai_suggested_reply TEXT,
    replied_text TEXT,
    replied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    CONSTRAINT unique_account_interaction UNIQUE (account_id, external_id)
);

ALTER TABLE public.interactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read interactions from their accounts"
    ON public.interactions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update interactions from their accounts"
    ON public.interactions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert interactions"
    ON public.interactions FOR INSERT
    WITH CHECK (auth.uid() = user_id);
