import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:stream_transform/stream_transform.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/home_repository.dart';
import '../../domain/models/room.dart';
import '../../domain/models/device.dart';

// Global channel manager to prevent duplicate subscriptions
class SupabaseChannelManager {
  static final Map<String, RealtimeChannel> _channels = {};
  static final Map<String, StreamController<List<Map<String, dynamic>>>> _controllers = {};
  static final Map<String, Map<String, Map<String, dynamic>>> _latestReadings = {};

  static RealtimeChannel getOrCreateChannel(String channelKey, List<String> deviceIds) {
    if (!_channels.containsKey(channelKey) || _controllers[channelKey]?.isClosed == true) {
      // Dispose existing channel if it exists but is closed
      if (_channels.containsKey(channelKey)) {
        _channels[channelKey]?.unsubscribe();
        _channels.remove(channelKey);
        _controllers.remove(channelKey);
        _latestReadings.remove(channelKey);
      }
      
      final supabase = Supabase.instance.client;
      final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
      
      _controllers[channelKey] = controller;
      _latestReadings[channelKey] = {};

      final channel = supabase.channel(channelKey)
        ..onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'power_readings',
          callback: (payload) {
            print('Realtime INSERT received: \\nDevice ID: \\${payload.newRecord?['device_id']}\\nPayload: \\${payload.newRecord}');
            final newReading = payload.newRecord;
            if (newReading != null) {
              _updateAndAddReading(channelKey, newReading, deviceIds);
            }
          },
        )
        ..onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'power_readings',
          callback: (payload) {
            print('Realtime UPDATE received: ${payload.newRecord}');
            final updatedReading = payload.newRecord;
            if (updatedReading != null) {
              _updateAndAddReading(channelKey, updatedReading, deviceIds);
            }
          },
        )
        ..subscribe((status, [error]) {
          print('Supabase channel status: $status');
          if (error != null) {
            print('Supabase channel subscription error: $error');
          }
          if (status == RealtimeSubscribeStatus.subscribed) {
            _fetchInitialReadings(channelKey, deviceIds);
          }
        });

      _channels[channelKey] = channel;
    } else {
      // Channel exists and is active, but make sure we have initial data
      // This handles the case where user returns to page and needs to see data immediately
      if (_latestReadings[channelKey]?.isEmpty == true) {
        _fetchInitialReadings(channelKey, deviceIds);
      }
    }
    return _channels[channelKey]!;
  }

  static void _updateAndAddReading(String channelKey, Map<String, dynamic> reading, List<String> deviceIds) {
    final deviceId = reading['device_id'] as String;
    if (deviceIds.contains(deviceId)) {
      final latestReadings = _latestReadings[channelKey]!;
      if (!latestReadings.containsKey(deviceId) ||
          DateTime.parse(reading['timestamp']).isAfter(DateTime.parse(latestReadings[deviceId]!['timestamp']))) {
        latestReadings[deviceId] = reading;
        print('_updateAndAddReading: Latest reading for device $deviceId updated. Emitting new state: \\n\\t${latestReadings.values.toList()}');
        _controllers[channelKey]?.add(latestReadings.values.toList());
      }
    }
  }

  static Future<void> _fetchInitialReadings(String channelKey, List<String> deviceIds) async {
    print('Attempting to fetch initial power readings after subscription...');
    try {
      if (deviceIds.isEmpty) {
        print('No device IDs to fetch initial readings for.');
        return;
      }
      
      final supabase = Supabase.instance.client;
      final initialReadingsResponse = await supabase
          .from('power_readings')
          .select('device_id, power_watts, timestamp')
          .inFilter('device_id', deviceIds)
          .order('timestamp', ascending: false);

      print('Initial readings response received: ${initialReadingsResponse.length} records.');

      if (initialReadingsResponse != null && initialReadingsResponse.isNotEmpty) {
        final Map<String, Map<String, dynamic>> initialLatestReadings = {};
        for (var reading in initialReadingsResponse) {
          final deviceId = reading['device_id'] as String;
          if (!initialLatestReadings.containsKey(deviceId) ||
              (reading['timestamp'] is String && initialLatestReadings[deviceId]!['timestamp'] is String &&
               DateTime.parse(reading['timestamp']).isAfter(DateTime.parse(initialLatestReadings[deviceId]!['timestamp'])))) {
            initialLatestReadings[deviceId] = reading;
          }
        }
        
        _latestReadings[channelKey]!.clear();
        _latestReadings[channelKey]!.addAll(initialLatestReadings);
        print('Adding initial latest readings to controller: \\n\\tLatest readings: \\${_latestReadings[channelKey]!.values.toList()}');
        _controllers[channelKey]?.add(_latestReadings[channelKey]!.values.toList());
      } else {
        print('No initial readings found for device IDs: $deviceIds');
        _controllers[channelKey]?.add([]);
      }
    } catch (e) {
      print('Error fetching initial power readings: $e');
      if (!_controllers[channelKey]!.isClosed) {
        _controllers[channelKey]!.addError(e);
      }
    }
  }

  static Stream<List<Map<String, dynamic>>> getStream(String channelKey) {
    return _controllers[channelKey]!.stream;
  }

  static void disposeChannel(String channelKey) {
    print('Disposing channel: $channelKey');
    _channels[channelKey]?.unsubscribe();
    _channels.remove(channelKey);
    _controllers[channelKey]?.close();
    _controllers.remove(channelKey);
    _latestReadings.remove(channelKey);
  }

  static void disposeAll() {
    for (final channelKey in _channels.keys.toList()) {
      disposeChannel(channelKey);
    }
  }
}

// Repository provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

// Selected room index provider for MyRoomsPage persistence
final selectedRoomIndexProvider = StateNotifierProvider<SelectedRoomIndexNotifier, int>((ref) {
  return SelectedRoomIndexNotifier();
});

class SelectedRoomIndexNotifier extends StateNotifier<int> {
  SelectedRoomIndexNotifier() : super(0) {
    _loadSelectedRoomIndex();
  }

  Future<void> _loadSelectedRoomIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIndex = prefs.getInt('selected_room_index') ?? 0;
      state = savedIndex;
    } catch (e) {
      print('Error loading selected room index: $e');
    }
  }

  Future<void> setSelectedRoomIndex(int index) async {
    state = index;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_room_index', index);
    } catch (e) {
      print('Error saving selected room index: $e');
    }
  }
}

// Rooms providers
final roomsProvider = StreamProvider<List<Room>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamRooms();
});

final roomProvider = FutureProvider.family<Room?, String>((ref, roomId) async {
  final rooms = await ref.watch(roomsProvider.future);
  try {
    return rooms.firstWhere((room) => room.id == roomId);
  } catch (e) {
    return null;
  }
});

// Devices providers
final allDevicesProvider = StreamProvider<List<Device>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamAllDevices();
});

final roomDevicesProvider = StreamProvider.family<List<Device>, String>((ref, roomId) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.streamDevicesForRoom(roomId);
});

// Quick access devices provider (returns a small subset of devices for quick access)
final quickAccessDevicesProvider = FutureProvider<List<Device>>((ref) async {
  final allDevices = await ref.watch(allDevicesProvider.future);
  // Return at most 4 devices for quick access
  return allDevices.take(4).toList();
});

// Combined provider for devices and their real-time power readings for a room
final combinedDevicesAndPowerReadingsProvider = StreamProvider.family<
    (List<Device>, List<Map<String, dynamic>>),
    String
>((ref, roomId) {
    print('combinedDevicesAndPowerReadingsProvider created for roomId: $roomId');
    // Watch the devices for the given room
    final devicesStream = ref.watch(roomDevicesProvider(roomId).stream);

    // Combine the devices stream with the power readings stream
    // This logic ensures the power readings stream is created only when devices are available
    return devicesStream.switchMap((devices) {
      print('combinedDevicesAndPowerReadingsProvider - devicesStream emitted ${devices.length} devices.');
      final deviceIds = devices.map((d) => d.id).toList();
      if (deviceIds.isEmpty) {
        print('combinedDevicesAndPowerReadingsProvider - deviceIds list is empty.');
        // If no devices, return an empty stream for readings and the empty device list
        return Stream.value((devices, <Map<String, dynamic>>[]));
      } else {
        print('combinedDevicesAndPowerReadingsProvider - deviceIds: $deviceIds. Watching power readings.');
        // If devices exist, watch the power readings for these device IDs
        final powerReadingsStream = ref.watch(roomPowerReadingsProvider(deviceIds).stream);
        // Combine the current devices list with the power readings stream
        return powerReadingsStream.map((readings) {
          print('combinedDevicesAndPowerReadingsProvider - powerReadingsStream emitted readings: \\n\\tDevice IDs: $deviceIds\\n\\tReadings: $readings');
          return (devices, readings);
        });
      }
    });
  });

// Realtime Power Readings Provider - Now persistent across navigation
final roomPowerReadingsProvider = StreamProvider.family<List<Map<String, dynamic>>, List<String>>((ref, deviceIds) {
  print('roomPowerReadingsProvider created for deviceIds: $deviceIds');
  if (deviceIds.isEmpty) {
    print('deviceIds list is empty, returning empty stream.');
    return Stream.value([]);
  }

  // Create a unique channel key based on sorted device IDs to ensure consistency
  final sortedDeviceIds = List<String>.from(deviceIds)..sort();
  final channelKey = 'power_readings_${sortedDeviceIds.join('_')}';
  
  // Get or create the channel using the global manager
  SupabaseChannelManager.getOrCreateChannel(channelKey, deviceIds);

  // Keep the connection alive across navigation
  // Only dispose when the app itself is disposed
  ref.onDispose(() {
    print('roomPowerReadingsProvider disposed for deviceIds: $deviceIds');
    // Don't dispose the channel immediately - let the global cleanup handle it
  });

  return SupabaseChannelManager.getStream(channelKey);
});

// Provider to manage global cleanup
final channelCleanupProvider = Provider<void>((ref) {
  ref.onDispose(() {
    print('App disposing - cleaning up all Supabase channels');
    SupabaseChannelManager.disposeAll();
  });
});

// Toggle device power provider
final toggleDevicePowerProvider = FutureProvider.family<bool, ToggleDeviceParams>((ref, params) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.toggleDevicePower(params.deviceId, params.isOn);
  
  // Refresh the devices list if successful
  if (result) {
    // Since we are using streams, invalidating might not be necessary,
    // but we can keep it for now or adjust based on testing.
    // ref.invalidate(allDevicesProvider);
    // ref.invalidate(roomDevicesProvider(params.roomId ?? ''));
  }
  
  return result;
});

// Parameter class for toggle device power
class ToggleDeviceParams {
  final String deviceId;
  final bool isOn;
  final String? roomId;
  
  ToggleDeviceParams({
    required this.deviceId,
    required this.isOn,
    this.roomId,
  });
}

// Update device status provider
final updateDeviceStatusProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.updateDeviceStatus(params['deviceId']!, params['status']!);
  if (result) {
    ref.invalidate(allDevicesProvider);
    ref.invalidate(roomDevicesProvider(params['roomId'] ?? ''));
  }
  return result;
});

// Provider for total kWh (sum of totalPower) across all devices
final totalKwhProvider = StreamProvider<double>((ref) {
  final allDevicesStream = ref.watch(allDevicesProvider.stream);
  return allDevicesStream.map((devices) =>
    devices.fold<double>(0, (sum, d) => sum + d.totalPower)
  );
});

// Provider to calculate actual energy consumption from power readings
// This serves as a backup when total_power isn't updated correctly by database triggers
final actualEnergyConsumptionProvider = FutureProvider.family<double, String>((ref, deviceId) async {
  final repository = ref.watch(homeRepositoryProvider);
  try {
    final supabase = Supabase.instance.client;
    
    // Get all power readings for this device, ordered by timestamp
    final response = await supabase
        .from('power_readings')
        .select('power_watts, power_kwh, timestamp')
        .eq('device_id', deviceId)
        .order('timestamp', ascending: true);
    
    if (response.isEmpty) {
      return 0.0;
    }
    
    double totalEnergyKwh = 0.0;
    
    // If power_kwh is available and not null, sum it up
    for (final reading in response) {
      final powerKwh = reading['power_kwh'] as double?;
      if (powerKwh != null && powerKwh > 0) {
        totalEnergyKwh += powerKwh;
      }
    }
    
    // If no power_kwh data found, calculate from power_watts using time intervals
    if (totalEnergyKwh == 0.0 && response.length > 1) {
      for (int i = 1; i < response.length; i++) {
        final currentReading = response[i];
        final previousReading = response[i - 1];
        
        final currentPowerWatts = (currentReading['power_watts'] as num?)?.toDouble() ?? 0.0;
        final currentTime = DateTime.parse(currentReading['timestamp']);
        final previousTime = DateTime.parse(previousReading['timestamp']);
        
        final timeDiffHours = currentTime.difference(previousTime).inMinutes / 60.0;
        
        // Calculate energy consumed in this interval
        // Using previous reading's power for the interval duration
        final previousPowerWatts = (previousReading['power_watts'] as num?)?.toDouble() ?? 0.0;
        final energyKwh = (previousPowerWatts * timeDiffHours) / 1000.0;
        
        totalEnergyKwh += energyKwh;
      }
    }
    
    return totalEnergyKwh;
  } catch (e) {
    print('Error calculating actual energy consumption for device $deviceId: $e');
    return 0.0;
  }
});

// Provider to get total energy for all devices in a room (calculated from power readings)
final roomActualEnergyProvider = FutureProvider.family<double, String>((ref, roomId) async {
  try {
    final devices = await ref.watch(roomDevicesProvider(roomId).future);
    double totalRoomEnergy = 0.0;
    
    for (final device in devices) {
      final deviceEnergy = await ref.watch(actualEnergyConsumptionProvider(device.id).future);
      totalRoomEnergy += deviceEnergy;
    }
    
    return totalRoomEnergy;
  } catch (e) {
    print('Error calculating room actual energy for room $roomId: $e');
    return 0.0;
  }
});

// Provider to get total energy for all devices (calculated from power readings)
final allDevicesActualEnergyProvider = FutureProvider<double>((ref) async {
  try {
    final allDevices = await ref.watch(allDevicesProvider.future);
    double totalEnergy = 0.0;
    
    for (final device in allDevices) {
      final deviceEnergy = await ref.watch(actualEnergyConsumptionProvider(device.id).future);
      totalEnergy += deviceEnergy;
    }
    
    return totalEnergy;
  } catch (e) {
    print('Error calculating total actual energy for all devices: $e');
    return 0.0;
  }
});

// Enhanced provider that combines device total_power with calculated energy as fallback
final enhancedEnergyProvider = FutureProvider.family<double, String>((ref, deviceId) async {
  try {
    final devices = await ref.watch(allDevicesProvider.future);
    final device = devices.firstWhere((d) => d.id == deviceId);
    
    // If total_power is properly set and > 0, use it
    if (device.totalPower > 0) {
      return device.totalPower;
    }
    
    // Otherwise, calculate from power readings
    return ref.watch(actualEnergyConsumptionProvider(deviceId).future);
  } catch (e) {
    print('Error getting enhanced energy data for device $deviceId: $e');
    // Fallback to calculated energy
    return ref.watch(actualEnergyConsumptionProvider(deviceId).future);
  }
});

final userGoalProvider = FutureProvider<double>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  // Default goal is 14.2 kWh if not set
  return prefs.getDouble('user_goal_kwh') ?? 14.2;
});

final setUserGoalProvider = FutureProvider.family<void, double>((ref, newGoal) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('user_goal_kwh', newGoal);
  // Optionally, refresh the userGoalProvider
  ref.invalidate(userGoalProvider);
});

enum TariffMode { auto, manual }

final tariffModeProvider = FutureProvider<TariffMode>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final modeStr = prefs.getString('tariff_mode') ?? 'auto';
  return modeStr == 'manual' ? TariffMode.manual : TariffMode.auto;
});

final setTariffModeProvider = FutureProvider.family<void, TariffMode>((ref, mode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('tariff_mode', mode == TariffMode.manual ? 'manual' : 'auto');
  ref.invalidate(tariffModeProvider);
});

final selectedBracketProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('selected_bracket') ?? 3; // Default to 201-350 kWh
});

final setSelectedBracketProvider = FutureProvider.family<void, int>((ref, bracketIndex) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('selected_bracket', bracketIndex);
  ref.invalidate(selectedBracketProvider);
});

// List of residential brackets and their prices (EGP per kWh)
const List<Map<String, dynamic>> residentialBrackets = [
  {'label': '0–50 kWh', 'price': 0.68},
  {'label': '51–100 kWh', 'price': 0.78},
  {'label': '101–200 kWh', 'price': 0.95},
  {'label': '201–350 kWh', 'price': 1.55},
  {'label': '351–650 kWh', 'price': 1.95},
  {'label': '651–1000 kWh', 'price': 2.10},
  {'label': 'Above 1000 kWh', 'price': 2.30},
];

// Helper to get price per kWh based on mode, bracket, and usage
// usageKwh: current total kWh
Future<double> getPricePerKwh({required TariffMode mode, required int manualBracket, required double usageKwh}) async {
  if (mode == TariffMode.manual) {
    return residentialBrackets[manualBracket]['price'] as double;
  } else {
    // Auto: pick bracket based on usage
    if (usageKwh <= 50) return 0.68;
    if (usageKwh <= 100) return 0.78;
    if (usageKwh <= 200) return 0.95;
    if (usageKwh <= 350) return 1.55;
    if (usageKwh <= 650) return 1.95;
    if (usageKwh <= 1000) return 2.10;
    return 2.30;
  }
} 