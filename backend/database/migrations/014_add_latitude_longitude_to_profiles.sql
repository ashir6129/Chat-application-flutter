-- 014_add_latitude_longitude_to_profiles.sql
-- Add latitude and longitude columns to the profiles table for location-based discovery

ALTER TABLE profiles ADD COLUMN IF NOT EXISTS latitude DOUBLE PRECISION;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS longitude DOUBLE PRECISION;
