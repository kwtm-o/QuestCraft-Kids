/*
  # Create worksheets table for student adventure logs

  1. New Tables
    - `worksheets`
      - `id` (uuid, primary key)
      - `student_id` (uuid) - References students table
      - `tenant_id` (uuid) - References tenants table for data isolation
      - `date` (text) - The date entered by student
      - `content` (text) - The goals/content entered by student
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `worksheets` table
    - Add policy for students to manage their own worksheets
    - Add policy for tenant owners to read all worksheets in their tenant

  3. Indexes
    - Index on student_id for efficient queries
    - Index on tenant_id for tenant-based queries
    - Index on created_at for chronological ordering
*/

CREATE TABLE IF NOT EXISTS worksheets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid REFERENCES students(id) ON DELETE CASCADE NOT NULL,
  tenant_id uuid REFERENCES tenants(id) ON DELETE CASCADE NOT NULL,
  date text NOT NULL DEFAULT '',
  content text NOT NULL DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE worksheets ENABLE ROW LEVEL SECURITY;

-- Policies for worksheets table
CREATE POLICY "Students can manage their own worksheets"
  ON worksheets
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM students 
      WHERE students.id = worksheets.student_id 
      AND students.user_id = auth.uid()
    )
  );

CREATE POLICY "Tenant owners can read all worksheets in their tenant"
  ON worksheets
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM tenants 
      WHERE tenants.id = worksheets.tenant_id 
      AND tenants.owner_id = auth.uid()
    )
  );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_worksheets_student_id ON worksheets(student_id);
CREATE INDEX IF NOT EXISTS idx_worksheets_tenant_id ON worksheets(tenant_id);
CREATE INDEX IF NOT EXISTS idx_worksheets_created_at ON worksheets(created_at DESC);

-- Trigger to automatically update updated_at
CREATE TRIGGER update_worksheets_updated_at
  BEFORE UPDATE ON worksheets
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();