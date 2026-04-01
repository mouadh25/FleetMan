import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/vehicle.dart';

/// Full-featured Vehicle Detail Card screen.
///
/// Displays:
/// - Header with plate number + status badge
/// - Vehicle specs (make, model, year, odometer, fuel type, VIN)
/// - Legal document expiry section with color-coded chips
/// - QR scanner placeholder in AppBar for Phase 3
/// - "Start Inspection" action button for Phase 5 eDVIR
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

  String _getFuelTranslation(String fuelType, AppLocalizations l10n) {
    switch (fuelType) {
      case 'diesel':
        return l10n.fuelDiesel;
      case 'essence_sans_plomb':
        return l10n.fuelEssence;
      case 'sirghaz_gplc':
        return l10n.fuelSirghaz;
      default:
        return fuelType;
    }
  }

  /// Returns color + label for a legal document expiry date.
  /// 🟢 > 30 days | 🟠 ≤ 30 days | 🔴 expired
  _ExpiryInfo _getExpiryInfo(String? dateStr, AppLocalizations l10n) {
    if (dateStr == null || dateStr.isEmpty) {
      return _ExpiryInfo(Colors.grey, '—');
    }

    final today = DateTime.now();
    final expiry = DateTime.tryParse(dateStr);
    if (expiry == null) {
      return _ExpiryInfo(Colors.grey, '—');
    }

    final diff = expiry.difference(DateTime(today.year, today.month, today.day)).inDays;

    if (diff < 0) {
      return _ExpiryInfo(AppTheme.errorRed, l10n.expired);
    } else if (diff <= 30) {
      return _ExpiryInfo(AppTheme.accentOrange, '$diff ${l10n.daysShort}');
    } else {
      return _ExpiryInfo(
        AppTheme.successGreen,
        '${expiry.day}/${expiry.month}/${expiry.year}',
      );
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
        actions: [
          // QR Scanner placeholder for Phase 3
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: l10n.scanQrButton,
            onPressed: () {
              // TODO: Phase 3 — Navigate to QR scanner
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Vehicle Header Card ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                        color: _getStatusColor(vehicle.status).withValues(alpha: 0.1),
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

              // ── Vehicle Specs Card ──
              _buildSectionCard(
                theme: theme,
                children: [
                  _buildInfoRow(l10n.make, vehicle.make, theme),
                  const Divider(height: 1),
                  _buildInfoRow(l10n.model, vehicle.model, theme),
                  const Divider(height: 1),
                  _buildInfoRow(l10n.year, vehicle.year.toString(), theme),
                  const Divider(height: 1),
                  _buildInfoRow(l10n.odometer, '${vehicle.odometerKm} km', theme),
                  const Divider(height: 1),
                  _buildInfoRow(l10n.fuelType, _getFuelTranslation(vehicle.fuelType, l10n), theme),
                  if (vehicle.vin != null && vehicle.vin!.isNotEmpty) ...[
                    const Divider(height: 1),
                    _buildInfoRow(l10n.vin, vehicle.vin!, theme),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // ── Legal Documents Card ──
              _buildSectionCard(
                theme: theme,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      l10n.legalDocuments,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _buildExpiryRow(
                    l10n.insuranceExpiry,
                    _getExpiryInfo(vehicle.insuranceExpiry, l10n),
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildExpiryRow(
                    l10n.technicalInspection,
                    _getExpiryInfo(vehicle.technicalInspectionExpiry, l10n),
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildExpiryRow(
                    l10n.circulationCard,
                    _getExpiryInfo(vehicle.circulationCardExpiry, l10n),
                    theme,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Start Inspection Button ──
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Phase 5 — Navigate to eDVIR flow
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
                  l10n.startInspection,
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

  /// Builds a rounded card container for a section.
  Widget _buildSectionCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }

  /// Builds a standard label-value info row.
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

  /// Builds a row for a legal document expiry with a color-coded chip.
  Widget _buildExpiryRow(String label, _ExpiryInfo info, ThemeData theme) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: info.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              info.label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: info.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal helper to pair a color with a display label for expiry badges.
class _ExpiryInfo {
  final Color color;
  final String label;

  const _ExpiryInfo(this.color, this.label);
}
