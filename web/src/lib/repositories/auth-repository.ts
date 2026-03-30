/**
 * Cloud-Agnostic Auth Repository Interface.
 */

export interface AuthUser {
  id: string;
  email: string;
  full_name: string | null;
  roles: string[];
  tenant_id: string | null;
}

export interface AuthRepository {
  signIn(email: string, password: string): Promise<AuthUser>;
  signUp(email: string, password: string, fullName: string, companyName: string): Promise<AuthUser>;
  signOut(): Promise<void>;
  getCurrentUser(): Promise<AuthUser | null>;
}
