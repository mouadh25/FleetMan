import { SupabaseClient } from '@supabase/supabase-js';
import type { AuthUser, AuthRepository } from './auth-repository';

export class SupabaseAuthRepository implements AuthRepository {
  constructor(private supabase: SupabaseClient) {}

  async signIn(email: string, password: string): Promise<AuthUser> {
    const { data, error } = await this.supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw new Error(error.message);

    const { data: profile, error: profileError } = await this.supabase
      .from('profiles')
      .select('full_name, roles, tenant_id')
      .eq('id', data.user.id)
      .single();

    if (profileError) throw new Error(profileError.message);

    return {
      id: data.user.id,
      email: data.user.email!,
      full_name: profile.full_name,
      roles: profile.roles || [],
      tenant_id: profile.tenant_id,
    };
  }

  async signUp(email: string, password: string, fullName: string, companyName: string): Promise<AuthUser> {
    const { data, error } = await this.supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
          company_name: companyName,
        },
      },
    });

    if (error) throw new Error(error.message);

    // Triggers will automatically confirm emails. If no session is returned, sign in manually.
    if (!data.session) {
      await this.signIn(email, password);
    }

    const currentUser = await this.getCurrentUser();
    if (!currentUser) {
      throw new Error('Sign up succeeded but user profile could not be retrieved');
    }
    return currentUser;
  }

  async signOut(): Promise<void> {
    const { error } = await this.supabase.auth.signOut();
    if (error) throw new Error(error.message);
  }

  async getCurrentUser(): Promise<AuthUser | null> {
    const { data: { user } } = await this.supabase.auth.getUser();
    if (!user) return null;

    const { data: profile } = await this.supabase
      .from('profiles')
      .select('full_name, roles, tenant_id')
      .eq('id', user.id)
      .single();

    if (!profile) return null;

    return {
      id: user.id,
      email: user.email!,
      full_name: profile.full_name,
      roles: profile.roles || [],
      tenant_id: profile.tenant_id,
    };
  }
}
