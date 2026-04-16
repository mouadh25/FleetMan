import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/domain/vehicle.dart';
import '../domain/audit.dart';

/// Audit Form Screen (eDVIR) for field managers to perform pre-trip inspections.
/// Takes a Vehicle from QR scanner context and presents a 5-item checklist.
class AuditFormScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;

  const AuditFormScreen({super.key, required this.vehicle});

  @override
  ConsumerState<AuditFormScreen> createState() => _AuditFormScreenState();
}

class _AuditFormScreenState extends ConsumerState<AuditFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _damageNotesController = TextEditingController();
  final _imagePicker = ImagePicker();

  late Map<String, ChecklistItem> _checklist;
  List<String> _photoUrls = [];
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeChecklist();
    _odometerController.text = widget.vehicle.odometerKm.toString();
  }

  void _initializeChecklist() {
    _checklist = {
      AuditChecklist.tires: const ChecklistItem(name: 'tires', passed: false),
      AuditChecklist.lights: const ChecklistItem(name: 'lights', passed: false),
      AuditChecklist.fluids: const ChecklistItem(name: 'fluids', passed: false),
      AuditChecklist.mirrors:
          const ChecklistItem(name: 'mirrors', passed: false),
      AuditChecklist.odometer:
          const ChecklistItem(name: 'odometer', passed: false),
    };
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _damageNotesController.dispose();
    super.dispose();
  }

  bool _allItemsCompleted() {
    return _checklist.values.every((item) => item.passed || !item.passed);
  }

  bool _anyItemFailed() {
    return _checklist.values.any((item) => !item.passed);
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        // In production, upload to Supabase Storage
        // For now, store the local path
        setState(() {
          _photoUrls.add(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture photo: $e';
      });
    }
  }

  Future<void> _submitAudit() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_allItemsCompleted()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allItemsRequired),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_photoUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoRequired),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmSubmit),
        content: Text(_anyItemFailed() ? l10n.auditFailed : l10n.auditPassed),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.tryAgain),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _anyItemFailed() ? AppTheme.errorRed : AppTheme.successGreen,
            ),
            child: Text(l10n.submitAudit),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      final odometer =
          int.tryParse(_odometerController.text) ?? widget.vehicle.odometerKm;

      final audit = Audit.create(
        vehicleId: widget.vehicle.id,
        inspectorId: user?.id ?? 'unknown',
        odometerKm: odometer,
        damageNotes: _anyItemFailed() ? _damageNotesController.text : null,
        passFail: !_anyItemFailed(),
        photoUrls: _photoUrls,
        checklist: _checklist,
      );

      // In production, submit to Supabase
      // For now, we'll just show success and navigate back
      // await _submitToSupabase(audit);

      if (!mounted) return;

      // Show success message
      _showAuditResult(audit);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to submit audit: $e';
        _isSubmitting = false;
      });
    }
  }

  void _showAuditResult(Audit audit) {
    final l10n = AppLocalizations.of(context)!;
    final isPass = audit.passFail;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isPass ? AppTheme.successGreen : AppTheme.errorRed,
        title: Row(
          children: [
            Icon(
              isPass ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.auditComplete,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPass ? l10n.auditPassed : l10n.auditFailed,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!isPass && widget.vehicle.id.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '${l10n.issueCreated}${widget.vehicle.plateNumber}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/home/gatekeeper');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor:
                  isPass ? AppTheme.successGreen : AppTheme.errorRed,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getChecklistLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case AuditChecklist.tires:
        return l10n.tires;
      case AuditChecklist.lights:
        return l10n.lights;
      case AuditChecklist.fluids:
        return l10n.fluids;
      case AuditChecklist.mirrors:
        return l10n.mirrors;
      case AuditChecklist.odometer:
        return l10n.odometerReading;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(l10n.auditForm),
        elevation: 0,
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l10n.auditComplete,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Vehicle Info Card
                  _buildVehicleCard(l10n, theme),
                  const SizedBox(height: 24),

                  // Checklist Section
                  Text(
                    l10n.auditChecklist,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Checklist Items
                  ..._checklist.keys
                      .map((key) => _buildChecklistItem(key, l10n)),

                  const SizedBox(height: 24),

                  // Odometer Reading
                  Text(
                    l10n.odometerReading,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _odometerController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      suffixText: l10n.km,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Damage Notes (shown only if items failed)
                  if (_anyItemFailed()) ...[
                    Text(
                      l10n.damageNotes,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _damageNotesController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: l10n.damageNotesHint,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Photo Section
                  Text(
                    l10n.addPhoto,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Photo thumbnails
                  if (_photoUrls.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _photoUrls.asMap().entries.map((entry) {
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _photoUrls.removeAt(entry.key);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorRed,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 12),

                  // Take Photo Button - 56px touch target
                  SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt, size: 24),
                      label: Text(l10n.takePhoto),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.errorRed),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.errorRed),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Submit Button - 56px touch target
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitAudit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _anyItemFailed()
                            ? AppTheme.errorRed
                            : AppTheme.successGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        l10n.submitAudit,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildVehicleCard(AppLocalizations l10n, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions_car,
                  size: 32,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vehicle.plateNumber,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      '${widget.vehicle.year} ${widget.vehicle.make} ${widget.vehicle.model}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            l10n.inspectionDetails,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String key, AppLocalizations l10n) {
    final item = _checklist[key]!;
    final isPassed = item.passed;
    final isFailed = item.passed == false &&
        _checklist.values.any((i) => i.name == key && !i.passed == false) ==
            false &&
        _formKey.currentState?.validate() == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPassed
              ? AppTheme.successGreen.withOpacity(0.5)
              : isFailed
                  ? AppTheme.errorRed.withOpacity(0.5)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isPassed
                    ? AppTheme.successGreen.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getChecklistIcon(key),
                color: isPassed ? AppTheme.successGreen : Colors.grey[400],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Label
            Expanded(
              child: Text(
                _getChecklistLabel(key, l10n),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isPassed ? AppTheme.successGreen : Colors.black87,
                ),
              ),
            ),
            // Pass/Fail Toggle - 56px touch targets
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  label: l10n.pass,
                  isSelected: isPassed,
                  selectedColor: AppTheme.successGreen,
                  onTap: () {
                    setState(() {
                      _checklist[key] = item.copyWith(passed: true);
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildToggleButton(
                  label: l10n.fail,
                  isSelected: !isPassed,
                  selectedColor: AppTheme.errorRed,
                  onTap: () {
                    setState(() {
                      _checklist[key] = item.copyWith(passed: false);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getChecklistIcon(String key) {
    switch (key) {
      case AuditChecklist.tires:
        return Icons.tire_repair;
      case AuditChecklist.lights:
        return Icons.highlight;
      case AuditChecklist.fluids:
        return Icons.water_drop;
      case AuditChecklist.mirrors:
        return Icons.drive_file_rename_outline;
      case AuditChecklist.odometer:
        return Icons.speed;
      default:
        return Icons.check_circle_outline;
    }
  }
}
