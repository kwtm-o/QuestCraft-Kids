/*
  # Create tenants table for multi-tenant architecture

  1. New Tables
    - `tenants`
      - `id` (uuid, primary key)
      - `subdomain` (text, unique) - The subdomain for the classroom
      - `name` (text) - Display name of the classroom
      - `owner_id` (uuid) - References auth.users (teacher/parent)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `tenants` table
    - Add policy for owners to manage their own tenants
    - Add policy for authenticated users to read tenants they belong to

  3. Indexes
    - Unique index on subdomain for fast lookups
    - Index on owner_id for efficient queries
*/

CREATE TABLE IF NOT EXISTS tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subdomain text UNIQUE NOT NULL,
  name text NOT NULL,
  owner_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;

-- Policies for tenants table
CREATE POLICY "Owners can manage their own tenants"
  ON tenants
  FOR ALL
  TO authenticated
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can read tenants they belong to"
  ON tenants
  FOR SELECT
  TO authenticated
  USING (
    auth.uid() = owner_id OR
    EXISTS (
      SELECT 1 FROM students 
      WHERE students.tenant_id = tenants.id 
      AND students.user_id = auth.uid()
    )
  );

-- Indexes
CREATE UNIQUE INDEX IF NOT EXISTS idx_tenants_subdomain ON tenants(subdomain);
CREATE INDEX IF NOT EXISTS idx_tenants_owner_id ON tenants(owner_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_tenants_updated_at
  BEFORE UPDATE ON tenants
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();