export interface Database {
  public: {
    Tables: {
      tenants: {
        Row: {
          id: string
          subdomain: string
          name: string
          owner_id: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          subdomain: string
          name: string
          owner_id: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          subdomain?: string
          name?: string
          owner_id?: string
          created_at?: string
          updated_at?: string
        }
      }
      students: {
        Row: {
          id: string
          tenant_id: string
          user_id: string | null
          username: string
          display_name: string
          password_hash: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          tenant_id: string
          user_id?: string | null
          username: string
          display_name: string
          password_hash?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          tenant_id?: string
          user_id?: string | null
          username?: string
          display_name?: string
          password_hash?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      worksheets: {
        Row: {
          id: string
          student_id: string
          tenant_id: string
          date: string
          content: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          student_id: string
          tenant_id: string
          date?: string
          content?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          student_id?: string
          tenant_id?: string
          date?: string
          content?: string
          created_at?: string
          updated_at?: string
        }
      }
      invite_links: {
        Row: {
          id: string
          tenant_id: string
          code: string
          is_active: boolean
          expires_at: string | null
          created_by: string
          created_at: string
        }
        Insert: {
          id?: string
          tenant_id: string
          code: string
          is_active?: boolean
          expires_at?: string | null
          created_by: string
          created_at?: string
        }
        Update: {
          id?: string
          tenant_id?: string
          code?: string
          is_active?: boolean
          expires_at?: string | null
          created_by?: string
          created_at?: string
        }
      }
      user_profiles: {
        Row: {
          id: string
          email: string | null
          full_name: string | null
          role: string
          created_at: string
          updated_at: string
        }
        Insert: {
          id: string
          email?: string | null
          full_name?: string | null
          role?: string
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string | null
          full_name?: string | null
          role?: string
          created_at?: string
          updated_at?: string
        }
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      generate_invite_code: {
        Args: Record<PropertyKey, never>
        Returns: string
      }
    }
    Enums: {
      [_ in never]: never
    }
  }
}