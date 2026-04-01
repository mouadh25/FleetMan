import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/vehicle.dart';

/// Defines the standard contract for Vehicle data operations.
/// 
/// This repository is implemented by [SupabaseVehicleRepository] for production
/// and can be mocked for testing. It interacts directly with the `Vehicle`
/// domain model.
abstract class VehicleRepository {
  /// Fetches all vehicles registered to the current tenant, ordered by creation date descending.
  Future<List<Vehicle>> getAll();

  /// Fetches a specific vehicle by its UUID. Returns null if not found.
  Future<Vehicle?> getById(String id);

  /// Creates a new vehicle record. Returns the newly created [Vehicle] with its generated UUID.
  Future<Vehicle> create(Vehicle vehicle);

  /// Updates specific fields of an existing vehicle.
  Future<void> update(String id, Map<String, dynamic> data);

  /// Hard deletes a vehicle from the system by its UUID.
  Future<void> delete(String id);
}

/// Production implementation of [VehicleRepository] using Supabase.
/// 
/// Relies on the `vehicles` table. Assumes that Row Level Security (RLS) policies 
/// automatically scope data requests to the authenticated user's current tenant.
class SupabaseVehicleRepository implements VehicleRepository {
  final SupabaseClient _supabase;

  SupabaseVehicleRepository(this._supabase);

  @override
  Future<List<Vehicle>> getAll() async {
    final response = await _supabase
        .from('vehicles')
        .select('*')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => Vehicle.fromJson(json)).toList();
  }

  @override
  Future<Vehicle?> getById(String id) async {
    final response = await _supabase
        .from('vehicles')
        .select('*')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Vehicle.fromJson(response);
  }

  @override
  Future<Vehicle> create(Vehicle vehicle) async {
    final response = await _supabase
        .from('vehicles')
        .insert(vehicle.toJson())
        .select()
        .single();

    return Vehicle.fromJson(response);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase
        .from('vehicles')
        .update(data)
        .eq('id', id);
  }

  @override
  Future<void> delete(String id) async {
    await _supabase
        .from('vehicles')
        .delete()
        .eq('id', id);
  }
}
