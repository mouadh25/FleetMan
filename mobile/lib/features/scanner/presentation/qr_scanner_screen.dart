import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../vehicles/data/supabase_vehicle_repository.dart';
import '../../vehicles/domain/vehicle.dart';

/// QR Scanner screen for field managers to identify vehicles.
/// Uses mobile_scanner package with camera-first UX.
class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _errorMessage;
  final _plateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Camera initialization failed: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    await _lookupVehicle(code);
  }

  Future<void> _lookupVehicle(String identifier) async {
    try {
      final supabase = Supabase.instance.client;
      final vehicleRepo = SupabaseVehicleRepository(supabase);

      // Try to find vehicle by ID (from QR code) or plate number
      Vehicle? vehicle = await vehicleRepo.getById(identifier);

      if (vehicle == null) {
        // Try as plate number lookup via filter
        final vehicles = await vehicleRepo.getAll();
        vehicle = vehicles
            .where(
              (v) => v.plateNumber.toLowerCase() == identifier.toLowerCase(),
            )
            .firstOrNull;
      }

      if (!mounted) return;

      if (vehicle != null) {
        // Navigate to audit form with vehicle context
        await context.push('/audit-form', extra: vehicle);
      } else {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.vehicleNotFound;
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Lookup failed: $e';
        _isProcessing = false;
      });
    }
  }

  void _handleManualEntry() {
    final plate = _plateController.text.trim();
    if (plate.isNotEmpty) {
      _lookupVehicle(plate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(l10n.scanQRCode),
        elevation: 0,
        actions: [
          if (_controller != null)
            IconButton(
              icon: const Icon(Icons.flash_on),
              iconSize: 28,
              tooltip: l10n.toggleFlash,
              onPressed: () => _controller?.toggleTorch(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera view - takes most of the screen
          Expanded(
            flex: 3,
            child: _errorMessage != null
                ? _buildErrorView(l10n, theme)
                : _buildScannerView(l10n),
          ),
          // Manual entry fallback
          Expanded(
            flex: 1,
            child: Container(
              color: AppTheme.backgroundLight,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.orEnterPlateManually,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _plateController,
                          decoration: InputDecoration(
                            hintText: l10n.plateNumberHint,
                            prefixIcon: const Icon(Icons.directions_car),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          onSubmitted: (_) => _handleManualEntry(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 56, // 56px touch target
                        height: 56, // 56px touch target
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _handleManualEntry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentOrange,
                            padding: EdgeInsets.zero,
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.search, size: 28),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView(AppLocalizations l10n) {
    return Stack(
      children: [
        if (_controller != null)
          MobileScanner(
            controller: _controller!,
            onDetect: _handleBarcode,
          ),
        // Scanning overlay
        CustomPaint(
          painter: _ScannerOverlayPainter(),
          child: const SizedBox.expand(),
        ),
        // Processing indicator
        if (_isProcessing)
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l10n.lookingUpVehicle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Instructions
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
            ),
            child: Text(
              l10n.scanQRInstructions,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 56, // 56px touch target
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isProcessing = false;
                  });
                },
                icon: const Icon(Icons.refresh, size: 24),
                label: Text(l10n.tryAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for scanner overlay with cutout effect.
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;
    final scanRect = Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize);

    // Draw overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = AppTheme.accentOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const bracketLength = 32.0;
    const cornerRadius = 16.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + bracketLength)
        ..lineTo(left, top + cornerRadius)
        ..quadraticBezierTo(left, top, left + cornerRadius, top)
        ..lineTo(left + bracketLength, top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - bracketLength, top)
        ..lineTo(left + scanAreaSize - cornerRadius, top)
        ..quadraticBezierTo(
            left + scanAreaSize, top, left + scanAreaSize, top + cornerRadius)
        ..lineTo(left + scanAreaSize, top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanAreaSize - bracketLength)
        ..lineTo(left, top + scanAreaSize - cornerRadius)
        ..quadraticBezierTo(
            left, top + scanAreaSize, left + cornerRadius, top + scanAreaSize)
        ..lineTo(left + bracketLength, top + scanAreaSize),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanAreaSize - bracketLength, top + scanAreaSize)
        ..lineTo(left + scanAreaSize - cornerRadius, top + scanAreaSize)
        ..quadraticBezierTo(left + scanAreaSize, top + scanAreaSize,
            left + scanAreaSize, top + scanAreaSize - cornerRadius)
        ..lineTo(left + scanAreaSize, top + scanAreaSize - bracketLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
