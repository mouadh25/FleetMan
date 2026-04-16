import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents an offline operation that needs to be synced.
class OfflineOperation {
  final String id;
  final String type; // 'audit', 'issue', 'vehicle_update'
  final String payload; // JSON string
  final DateTime createdAt;
  final int retryCount;

  const OfflineOperation({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: json['type'] as String,
      payload: json['payload'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      retryCount: json['retry_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'retry_count': retryCount,
    };
  }

  OfflineOperation copyWith({
    String? id,
    String? type,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
  }) {
    return OfflineOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Service for managing offline operations and synchronization.
/// Uses Hive for local storage and Connectivity Plus for network monitoring.
class OfflineSyncService {
  static const String _boxName = 'offline_operations';
  static const int _maxRetries = 5;
  static const Duration _retryDelay = Duration(seconds: 30);

  static OfflineSyncService? _instance;
  Box<Map>? _box;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _isSyncing = false;

  final _syncController = StreamController<int>.broadcast();
  final _connectivityController = StreamController<bool>.broadcast();

  /// Stream of pending operation count.
  Stream<int> get pendingCountStream => _syncController.stream;

  /// Stream of connectivity status (true = online).
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current pending operations count.
  int get pendingCount => _box?.length ?? 0;

  /// Whether currently syncing.
  bool get isSyncing => _isSyncing;

  /// Singleton instance.
  static OfflineSyncService get instance {
    _instance ??= OfflineSyncService._();
    return _instance!;
  }

  OfflineSyncService._();

  /// Initialize the service and start monitoring connectivity.
  Future<void> initialize() async {
    await _initHive();
    await _initConnectivityMonitoring();
    _startRetryTimer();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<void> _initConnectivityMonitoring() async {
    // Check initial connectivity
    final result = await Connectivity().checkConnectivity();
    _handleConnectivityChange(result);

    // Listen for changes
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isOnline =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    _connectivityController.add(isOnline);

    if (isOnline) {
      // Trigger sync when coming online
      syncPendingOperations();
    }
  }

  void _startRetryTimer() {
    _retryTimer = Timer.periodic(_retryDelay, (_) {
      if (pendingCount > 0 && !_isSyncing) {
        syncPendingOperations();
      }
    });
  }

  /// Queue an operation for offline sync.
  Future<void> queueOperation({
    required String type,
    required Map<String, dynamic> payload,
  }) async {
    final operation = OfflineOperation(
      id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      payload: _encodePayload(payload),
      createdAt: DateTime.now(),
    );

    await _box?.put(operation.id, operation.toJson());
    _notifyPendingCount();

    // Try to sync immediately if online
    // ignore: unawaited_futures - fire and forget sync attempt
    syncPendingOperations();
  }

  String _encodePayload(Map<String, dynamic> payload) {
    // Simple JSON encoding - in production use json_serializable
    final buffer = StringBuffer();
    buffer.write('{');
    var first = true;
    payload.forEach((key, value) {
      if (!first) buffer.write(',');
      first = false;
      buffer.write('"$key":"$value"');
    });
    buffer.write('}');
    return buffer.toString();
  }

  /// Sync all pending operations to the server.
  Future<void> syncPendingOperations() async {
    if (_isSyncing || !_hasPendingOperations()) return;

    _isSyncing = true;

    try {
      // Process operations in FIFO order
      final operations = _getPendingOperations();

      for (final operation in operations) {
        try {
          await _syncOperation(operation);
          // Remove successfully synced operation
          await _box?.delete(operation.id);
        } catch (e) {
          // Handle retry logic
          await _handleSyncError(operation, e);
        }
      }
    } finally {
      _isSyncing = false;
      _notifyPendingCount();
    }
  }

  bool _hasPendingOperations() {
    return _box?.isNotEmpty ?? false;
  }

  List<OfflineOperation> _getPendingOperations() {
    final operations = <OfflineOperation>[];
    _box?.toMap().forEach((key, value) {
      // value is always a Map from Hive box.toMap()
      // ignore: unnecessary_cast
      operations
          .add(OfflineOperation.fromJson(Map<String, dynamic>.from(value)));
    });

    // Sort by creation time (FIFO)
    operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return operations;
  }

  Future<void> _syncOperation(OfflineOperation operation) async {
    switch (operation.type) {
      case 'audit':
        await _syncAudit(operation);
        break;
      case 'issue':
        await _syncIssue(operation);
        break;
      case 'vehicle_update':
        await _syncVehicleUpdate(operation);
        break;
      default:
        debugPrint('Unknown operation type: ${operation.type}');
    }
  }

  Future<void> _syncAudit(OfflineOperation operation) async {
    final supabase = Supabase.instance.client;
    final payload = _parsePayload(operation.payload);

    await supabase.from('audits').insert({
      'id': operation.id,
      'vehicle_id': payload['vehicle_id'],
      'inspector_id': payload['inspector_id'],
      'odometer_km': int.parse(payload['odometer_km'] ?? '0'),
      'pass_fail': payload['pass_fail'] == 'true',
      'damage_notes': payload['damage_notes'],
      'checklist': _parseJson(payload['checklist'] ?? '{}'),
      'photo_urls': _parseJsonList(payload['photo_urls'] ?? '[]'),
      'created_at': operation.createdAt.toIso8601String(),
    });
  }

  Future<void> _syncIssue(OfflineOperation operation) async {
    final supabase = Supabase.instance.client;
    final payload = _parsePayload(operation.payload);

    await supabase.from('issues').insert({
      'id': operation.id,
      'vehicle_id': payload['vehicle_id'],
      'reporter_id': payload['reporter_id'],
      'description': payload['description'],
      'priority': payload['priority'] ?? 'medium',
      'status': 'open',
      'created_at': operation.createdAt.toIso8601String(),
    });
  }

  Future<void> _syncVehicleUpdate(OfflineOperation operation) async {
    final supabase = Supabase.instance.client;
    final payload = _parsePayload(operation.payload);

    await supabase.from('vehicles').update({
      'odometer_km': int.parse(payload['odometer_km'] ?? '0'),
      'status': payload['status'],
    }).eq('id', payload['vehicle_id'] ?? '');
  }

  Map<String, String> _parsePayload(String payload) {
    // Simple JSON parsing
    final result = <String, String>{};
    final content = payload.substring(1, payload.length - 1); // Remove { }
    final pairs = content.split(',');

    for (final pair in pairs) {
      final kv = pair.split(':');
      if (kv.length == 2) {
        result[kv[0].trim().replaceAll('"', '')] =
            kv[1].trim().replaceAll('"', '');
      }
    }

    return result;
  }

  dynamic _parseJson(String json) {
    // In production, use proper JSON parsing
    return {};
  }

  List<String> _parseJsonList(String json) {
    // In production, use proper JSON parsing
    return [];
  }

  Future<void> _handleSyncError(
      OfflineOperation operation, Object error) async {
    debugPrint('Sync error for ${operation.id}: $error');

    if (operation.retryCount < _maxRetries) {
      // Increment retry count
      final updated = operation.copyWith(retryCount: operation.retryCount + 1);
      await _box?.put(operation.id, updated.toJson());
    } else {
      // Max retries exceeded - remove and log
      debugPrint(
          'Max retries exceeded for ${operation.id}, removing from queue');
      await _box?.delete(operation.id);
    }
  }

  void _notifyPendingCount() {
    _syncController.add(pendingCount);
  }

  /// Clear all pending operations (use with caution).
  Future<void> clearAll() async {
    await _box?.clear();
    _notifyPendingCount();
  }

  /// Dispose resources.
  void dispose() {
    _connectivitySubscription?.cancel();
    _retryTimer?.cancel();
    _syncController.close();
    _connectivityController.close();
  }
}

/// Provider for the offline sync service.
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  final service = OfflineSyncService.instance;
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for pending operations count.
final pendingOperationsCountProvider = StreamProvider<int>((ref) {
  return OfflineSyncService.instance.pendingCountStream;
});

/// Provider for connectivity status.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return OfflineSyncService.instance.connectivityStream;
});
