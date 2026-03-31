import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/vehicle.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getAll();
  Future<Vehicle?> getById(String id);
  Future<Vehicle> create(Vehicle vehicle);
  Future<void> update(String id, Map<String, dynamic> data);
  Future<void> delete(String id);
}

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
