import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/home_repository.dart';
import '../../domain/models/room.dart';
import '../../domain/models/device.dart';

// Repository provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

// Rooms providers
final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getRooms();
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
final allDevicesProvider = FutureProvider<List<Device>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getAllDevices();
});

final roomDevicesProvider = FutureProvider.family<List<Device>, String>((ref, roomId) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getDevicesForRoom(roomId);
});

// Quick access devices provider (returns a small subset of devices for quick access)
final quickAccessDevicesProvider = FutureProvider<List<Device>>((ref) async {
  final allDevices = await ref.watch(allDevicesProvider.future);
  // Return at most 4 devices for quick access
  return allDevices.take(4).toList();
});

// Toggle device power provider
final toggleDevicePowerProvider = FutureProvider.family<bool, ToggleDeviceParams>((ref, params) async {
  final repository = ref.watch(homeRepositoryProvider);
  final result = await repository.toggleDevicePower(params.deviceId, params.isOn);
  
  // Refresh the devices list if successful
  if (result) {
    ref.invalidate(allDevicesProvider);
    ref.invalidate(roomDevicesProvider(params.roomId ?? ''));
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