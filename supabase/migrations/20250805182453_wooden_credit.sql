/*
  # Create students table for student management

  1. New Tables
    - `students`
      - `id` (uuid, primary key)
      - `tenant_id` (uuid) - References tenants table
      - `user_id` (uuid, nullable) - References auth.users when student logs in
      - `username` (text) - Student's username for login
      - `display_name` (text) - Student's display name
      - `password_hash` (text, nullable) - Optional password hash
      - `is_active` (boolean) - Whether student account is active
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `students` table
    - Add policy for tenant owners to manage students
    - Add policy for students to read their own data
    - Add policy for students to update their own data

  3. Constraints
    - Unique constraint on (tenant_id, username)
    - Check constraint for username format
*/

CREATE TABLE IF NOT EXISTS students (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  user_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  username text NOT NULL,
  display_name text NOT NULL,
  password_hash text,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Ensure username is unique within each tenant
  CONSTRAINT unique_username_per_tenant UNIQUE (tenant_id, username),
  
  -- Username validation (alphanumeric and underscore only)
  CONSTRAINT valid_username CHECK (username ~ '^[a-zA-Z0-9_]+$' AND length(username) >= 3 AND length(username) <= 20)
);

-- Enable RLS
ALTER TABLE students ENABLE ROW LEVEL SECURITY;

-- Policies for students table
CREATE POLICY "Tenant owners can manage their students"
  ON students
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM tenants 
      WHERE tenants.id = students.tenant_id 
      AND tenants.owner_id = auth.uid()
    )
  );

CREATE POLICY "Students can read their own data"
  ON students
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Students can update their own data"
  ON students
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Allow anonymous users to read student data for login purposes
CREATE POLICY "Anonymous users can read students for login"
  ON students
  FOR SELECT
  TO anon
  USING (true);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_students_tenant_id ON students(tenant_id);
CREATE INDEX IF NOT EXISTS idx_students_user_id ON students(user_id);
CREATE INDEX IF NOT EXISTS idx_students_username ON students(username);
CREATE UNIQUE INDEX IF NOT EXISTS idx_students_tenant_username ON students(tenant_id, username);

-- Trigger to automatically update updated_at
CREATE TRIGGER update_students_updated_at
  BEFORE UPDATE ON students
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();