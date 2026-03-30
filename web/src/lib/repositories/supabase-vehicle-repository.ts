import { SupabaseClient } from '@supabase/supabase-js';
import type { Vehicle, CreateVehicleDTO, VehicleRepository } from './vehicle-repository';

export class SupabaseVehicleRepository implements VehicleRepository {
  constructor(private supabase: SupabaseClient) {}

  async getAll(): Promise<Vehicle[]> {
    const { data, error } = await this.supabase
      .from('vehicles')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data as Vehicle[];
  }

  async getById(id: string): Promise<Vehicle | null> {
    const { data, error } = await this.supabase
      .from('vehicles')
      .select('*')
      .eq('id', id)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw new Error(error.message);
    }
    return data as Vehicle;
  }

  async create(dto: CreateVehicleDTO): Promise<Vehicle> {
    const { data, error } = await this.supabase
      .from('vehicles')
      .insert(dto)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data as Vehicle;
  }

  async update(id: string, dto: Partial<CreateVehicleDTO>): Promise<Vehicle> {
    const { data, error } = await this.supabase
      .from('vehicles')
      .update(dto)
      .eq('id', id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data as Vehicle;
  }

  async delete(id: string): Promise<void> {
    const { error } = await this.supabase
      .from('vehicles')
      .delete()
      .eq('id', id);

    if (error) throw new Error(error.message);
  }
}
