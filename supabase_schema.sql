-- ==============================================================================
-- FoodBridge Database Schema for Supabase (PostgreSQL)
-- ==============================================================================
-- INSTRUCTIONS:
-- 1. Open your Supabase Dashboard: https://supabase.com/dashboard
-- 2. Select your project and navigate to the "SQL Editor" tab on the left.
-- 3. Click "+ New query", paste the entire contents of this file, and click "Run".
-- 4. Navigate to Project Settings > API, copy your Project URL and anon public key.
-- 5. Paste them into lib/core/config/supabase_config.dart
-- ==============================================================================

-- 1. Enable UUID Extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Drop existing tables if recreating (safe cleanup)
DROP TABLE IF EXISTS rider_jobs CASCADE;
DROP TABLE IF EXISTS ngo_requests CASCADE;
DROP TABLE IF EXISTS donations CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- 3. Profiles Table (Donors, NGOs, Riders)
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT NOT NULL CHECK (role IN ('donor', 'ngo', 'rider')),
    organization_name TEXT,
    rating NUMERIC(3, 2) DEFAULT 5.0,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Donations Table
CREATE TABLE donations (
    id TEXT PRIMARY KEY,
    donor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    donor_name TEXT DEFAULT 'Anonymous Donor',
    food_name TEXT NOT NULL,
    category TEXT NOT NULL,
    quantity TEXT NOT NULL,
    unit TEXT NOT NULL DEFAULT 'kg',
    servings INTEGER NOT NULL DEFAULT 1,
    condition TEXT NOT NULL,
    is_urgent BOOLEAN DEFAULT FALSE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'matched', 'inTransit', 'delivered')) DEFAULT 'pending',
    matched_ngo TEXT,
    rider_id TEXT,
    posted_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. NGO Requests Table
CREATE TABLE ngo_requests (
    id TEXT PRIMARY KEY,
    ngo_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    ngo_name TEXT NOT NULL,
    category TEXT NOT NULL,
    people_count INTEGER NOT NULL,
    required_by TEXT NOT NULL,
    urgency TEXT NOT NULL CHECK (urgency IN ('Low', 'Normal', 'High')) DEFAULT 'Normal',
    notes TEXT,
    status TEXT NOT NULL CHECK (status IN ('open', 'matched', 'closed')) DEFAULT 'open',
    distance NUMERIC(5, 2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Rider Jobs Table
CREATE TABLE rider_jobs (
    id TEXT PRIMARY KEY,
    food_quantity TEXT NOT NULL,
    ngo_name TEXT NOT NULL,
    pickup_distance TEXT NOT NULL,
    drop_distance TEXT NOT NULL,
    est_time TEXT NOT NULL,
    is_urgent BOOLEAN DEFAULT FALSE,
    payout NUMERIC(8, 2) DEFAULT 150.0,
    status TEXT NOT NULL CHECK (status IN ('available', 'assigned', 'in_transit', 'delivered')) DEFAULT 'available',
    rider_id TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==============================================================================
-- 7. Row Level Security (RLS) Configuration
-- ==============================================================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ngo_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE rider_jobs ENABLE ROW LEVEL SECURITY;

-- Allow public read/write for now (can be tightened to authenticated users later)
CREATE POLICY "Public Read Access for profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Public Insert/Update for profiles" ON profiles FOR ALL USING (true);

CREATE POLICY "Public Read Access for donations" ON donations FOR SELECT USING (true);
CREATE POLICY "Public Insert Access for donations" ON donations FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update Access for donations" ON donations FOR UPDATE USING (true);

CREATE POLICY "Public Read Access for ngo_requests" ON ngo_requests FOR SELECT USING (true);
CREATE POLICY "Public Insert Access for ngo_requests" ON ngo_requests FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update Access for ngo_requests" ON ngo_requests FOR UPDATE USING (true);

CREATE POLICY "Public Read Access for rider_jobs" ON rider_jobs FOR SELECT USING (true);
CREATE POLICY "Public Insert Access for rider_jobs" ON rider_jobs FOR INSERT WITH CHECK (true);
CREATE POLICY "Public Update Access for rider_jobs" ON rider_jobs FOR UPDATE USING (true);

-- ==============================================================================
-- 8. Enable Realtime Subscriptions on Delivery & Feed Tables
-- ==============================================================================
-- This allows the Flutter app to receive instant push updates whenever 
-- a donation status changes or a new food request is posted!
ALTER PUBLICATION supabase_realtime ADD TABLE donations;
ALTER PUBLICATION supabase_realtime ADD TABLE ngo_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE rider_jobs;

-- ==============================================================================
-- 9. Seed Initial Data
-- ==============================================================================
INSERT INTO donations (id, food_name, category, quantity, unit, servings, condition, is_urgent, status, matched_ngo, rider_id, posted_at)
VALUES
    ('d1', 'Rice and Lentil Curry', 'Cooked Meals', '5', 'kg', 30, 'Freshly Prepared', TRUE, 'inTransit', 'Helping Hands Foundation', 'R-201', NOW() - INTERVAL '40 minutes'),
    ('d2', 'Mixed Vegetables', 'Raw Ingredients', '10', 'kg', 50, 'Properly Stored (Cold)', FALSE, 'delivered', 'City Orphanage', NULL, NOW() - INTERVAL '3 hours'),
    ('d3', 'Assorted Baked Goods', 'Baked Goods', '2', 'boxes', 20, 'Freshly Prepared', FALSE, 'pending', NULL, NULL, NOW() - INTERVAL '10 minutes');

INSERT INTO ngo_requests (id, ngo_name, category, people_count, required_by, urgency, status, distance, notes)
VALUES
    ('r1', 'Helping Hands Foundation', 'Cooked Meals', 100, 'Before 7:00 PM', 'High', 'open', 3.4, 'Need hot meals for emergency evening distribution.'),
    ('r2', 'City Orphanage', 'Raw Ingredients', 40, 'Tomorrow', 'Normal', 'matched', 5.1, 'Vegetables and pantry staples.'),
    ('r3', 'Community Kitchen East', 'Packaged Food', 80, 'Anytime this week', 'Low', 'open', 8.2, 'Dry rations and grain boxes.');

INSERT INTO rider_jobs (id, food_quantity, ngo_name, pickup_distance, drop_distance, est_time, is_urgent, payout, status)
VALUES
    ('j1', '50 Meals', 'Helping Hands Foundation', '1.2 km', '4.5 km', '25 min', TRUE, 180.0, 'available'),
    ('j2', '20 kg Veggies', 'City Orphanage', '3.0 km', '2.1 km', '18 min', FALSE, 140.0, 'available'),
    ('j3', '3 Boxes', 'Community Kitchen East', '0.8 km', '6.3 km', '35 min', FALSE, 160.0, 'available');
