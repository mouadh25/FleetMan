import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/vehicle.dart';

class VehicleCardScreen extends ConsumerWidget {
  final Vehicle vehicle;

  const VehicleCardScreen({
    super.key,
    required this.vehicle,
  });

  String _getStatusTranslation(String status, AppLocalizations l10n) {
    switch (status) {
      case 'active':
        return l10n.statusActive;
      case 'in_maintenance':
        return l10n.statusInMaintenance;
      case 'out_of_service':
        return l10n.statusOutOfService;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppTheme.successGreen;
      case 'in_maintenance':
        return AppTheme.accentOrange;
      case 'out_of_service':
        return AppTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vehicleDetails),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Header Card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 64,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      vehicle.plateNumber,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(vehicle.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusTranslation(vehicle.status, l10n).toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getStatusColor(vehicle.status),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Specs Card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(l10n.make, vehicle.make, theme),
                    const Divider(height: 1),
                    _buildInfoRow(l10n.model, vehicle.model, theme),
                    const Divider(height: 1),
                    _buildInfoRow(l10n.year, vehicle.year.toString(), theme),
                    const Divider(height: 1),
                    _buildInfoRow(l10n.odometer, '${vehicle.odometerKm} km', theme),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button (Audit/Start)
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to Audit/eDVIR flow
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                  ),
                ),
                icon: const Icon(Icons.assignment_turned_in, size: 24),
                label: Text(
                  'Démarrer l\'inspection',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
