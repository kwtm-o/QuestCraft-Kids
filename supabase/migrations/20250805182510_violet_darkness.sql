/*
  # Create invite links table for student registration

  1. New Tables
    - `invite_links`
      - `id` (uuid, primary key)
      - `tenant_id` (uuid) - References tenants table
      - `code` (text, unique) - Unique invite code
      - `is_active` (boolean) - Whether the invite is still valid
      - `expires_at` (timestamp, nullable) - Optional expiration date
      - `created_by` (uuid) - References auth.users (teacher who created it)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on `invite_links` table
    - Add policy for tenant owners to manage their invite links
    - Allow anonymous users to read active invite links for validation

  3. Functions
    - Function to generate unique invite codes
    - Function to validate invite codes
*/

CREATE TABLE IF NOT EXISTS invite_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  code text UNIQUE NOT NULL,
  is_active boolean DEFAULT true,
  expires_at timestamptz,
  created_by uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE invite_links ENABLE ROW LEVEL SECURITY;

-- Policies for invite_links table
CREATE POLICY "Tenant owners can manage their invite links"
  ON invite_links
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM tenants 
      WHERE tenants.id = invite_links.tenant_id 
      AND tenants.owner_id = auth.uid()
    )
  );

CREATE POLICY "Anonymous users can read active invite links"
  ON invite_links
  FOR SELECT
  TO anon
  USING (is_active = true AND (expires_at IS NULL OR expires_at > now()));

CREATE POLICY "Authenticated users can read active invite links"
  ON invite_links
  FOR SELECT
  TO authenticated
  USING (is_active = true AND (expires_at IS NULL OR expires_at > now()));

-- Indexes
CREATE INDEX IF NOT EXISTS idx_invite_links_tenant_id ON invite_links(tenant_id);
CREATE INDEX IF NOT EXISTS idx_invite_links_code ON invite_links(code);
CREATE INDEX IF NOT EXISTS idx_invite_links_active ON invite_links(is_active) WHERE is_active = true;

-- Function to generate unique invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS text AS $$
DECLARE
  chars text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  result text := '';
  i integer := 0;
  code_exists boolean := true;
BEGIN
  WHILE code_exists LOOP
    result := '';
    FOR i IN 1..8 LOOP
      result := result || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
    
    SELECT EXISTS(SELECT 1 FROM invite_links WHERE code = result) INTO code_exists;
  END LOOP;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;