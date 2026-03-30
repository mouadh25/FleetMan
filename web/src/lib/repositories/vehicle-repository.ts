/**
 * Cloud-Agnostic Vehicle Repository Interface.
 * Never call Supabase directly from UI components.
 * Swap implementation for sovereign VPS in MVP2.
 */

export type VehicleStatus = 'active' | 'in_maintenance' | 'out_of_service';
export type FuelType = 'diesel' | 'essence_sans_plomb' | 'sirghaz_gplc';

export interface Vehicle {
  id: string;
  tenant_id: string;
  plate_number: string;
  make: string;
  model: string;
  year: number;
  vin: string | null;
  odometer_km: number;
  status: VehicleStatus;
  fuel_type: FuelType;
  assigned_driver_id: string | null;
  insurance_expiry: string | null;
  technical_inspection_expiry: string | null;
  circulation_card_expiry: string | null;
  photo_url: string | null;
  created_at: string;
  updated_at: string;
}

export interface CreateVehicleDTO {
  plate_number: string;
  make: string;
  model: string;
  year: number;
  vin?: string;
  odometer_km: number;
  fuel_type: FuelType;
  insurance_expiry?: string;
  technical_inspection_expiry?: string;
  circulation_card_expiry?: string;
}

export interface VehicleRepository {
  getAll(): Promise<Vehicle[]>;
  getById(id: string): Promise<Vehicle | null>;
  create(data: CreateVehicleDTO): Promise<Vehicle>;
  update(id: string, data: Partial<CreateVehicleDTO>): Promise<Vehicle>;
  delete(id: string): Promise<void>;
}
