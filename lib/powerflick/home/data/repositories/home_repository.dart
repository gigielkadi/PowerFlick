import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/room.dart';
import '../../domain/models/device.dart';

class HomeRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final Logger _logger = Logger();
  
  // Room Operations
  
  /// Fetch rooms from the database
  Future<List<Room>> getRooms() async {
    try {
      final response = await _client.from('rooms').select('*');
      
      if (response.isEmpty) {
        // If no rooms exist yet, seed with default data
        await _seedDefaultRooms();
        return Room.getDefaultRooms();
      }
      
      return response.map((json) => Room.fromJson(json)).toList().cast<Room>();
    } catch (e) {
      _logger.e('Error fetching rooms: $e');
      // Return default rooms as fallback
      return Room.getDefaultRooms();
    }
  }
  
  /// Add a new room
  Future<Room?> addRoom(Room room) async {
    try {
      final response = await _client.from('rooms').insert(room.toJson()).select().single();
      return Room.fromJson(response);
    } catch (e) {
      _logger.e('Error adding room: $e');
      return null;
    }
  }
  
  /// Update an existing room
  Future<Room?> updateRoom(Room room) async {
    try {
      final response = await _client.from('rooms')
          .update(room.toJson())
          .eq('id', room.id)
          .select()
          .single();
      return Room.fromJson(response);
    } catch (e) {
      _logger.e('Error updating room: $e');
      return null;
    }
  }
  
  /// Delete a room
  Future<bool> deleteRoom(String roomId) async {
    try {
      await _client.from('rooms').delete().eq('id', roomId);
      return true;
    } catch (e) {
      _logger.e('Error deleting room: $e');
      return false;
    }
  }
  
  // Device Operations
  
  /// Fetch devices for a room
  Future<List<Device>> getDevicesForRoom(String roomId) async {
    try {
      final response = await _client.from('devices')
          .select('*')
          .eq('room_id', roomId);
      
      return response.map((json) => Device.fromJson(json)).toList().cast<Device>();
    } catch (e) {
      _logger.e('Error fetching devices for room: $e');
      return [];
    }
  }
  
  /// Fetch all devices
  Future<List<Device>> getAllDevices() async {
    try {
      final response = await _client.from('devices').select('*');
      
      if (response.isEmpty) {
        // If no devices exist yet, seed with sample data
        await _seedSampleDevices();
        return Device.getSampleDevices();
      }
      
      return response.map((json) => Device.fromJson(json)).toList().cast<Device>();
    } catch (e) {
      _logger.e('Error fetching all devices: $e');
      // Return sample devices as fallback
      return Device.getSampleDevices();
    }
  }
  
  /// Add a new device
  Future<Device?> addDevice(Device device, String roomId) async {
    try {
      final deviceJson = device.toJson();
      deviceJson['room_id'] = roomId;
      
      final response = await _client.from('devices').insert(deviceJson).select().single();
      return Device.fromJson(response);
    } catch (e) {
      _logger.e('Error adding device: $e');
      return null;
    }
  }
  
  /// Update a device
  Future<Device?> updateDevice(Device device) async {
    try {
      final response = await _client.from('devices')
          .update(device.toJson())
          .eq('id', device.id)
          .select()
          .single();
      return Device.fromJson(response);
    } catch (e) {
      _logger.e('Error updating device: $e');
      return null;
    }
  }
  
  /// Toggle device power
  Future<bool> toggleDevicePower(String deviceId, bool isOn) async {
    try {
      await _client.from('devices')
          .update({'is_on': isOn})
          .eq('id', deviceId);
      return true;
    } catch (e) {
      _logger.e('Error toggling device power: $e');
      return false;
    }
  }
  
  /// Delete a device
  Future<bool> deleteDevice(String deviceId) async {
    try {
      await _client.from('devices').delete().eq('id', deviceId);
      return true;
    } catch (e) {
      _logger.e('Error deleting device: $e');
      return false;
    }
  }
  
  // Helper Methods
  
  /// Seed the database with default rooms if empty
  Future<void> _seedDefaultRooms() async {
    try {
      final defaultRooms = Room.getDefaultRooms();
      for (final room in defaultRooms) {
        await _client.from('rooms').insert(room.toJson());
      }
      _logger.i('Seeded database with default rooms');
    } catch (e) {
      _logger.e('Error seeding default rooms: $e');
    }
  }
  
  /// Seed the database with sample devices if empty
  Future<void> _seedSampleDevices() async {
    try {
      final sampleDevices = Device.getSampleDevices();
      
      // Get rooms to assign devices
      final rooms = await getRooms();
      if (rooms.isEmpty) {
        return;
      }
      
      // Distribute devices across rooms
      for (int i = 0; i < sampleDevices.length; i++) {
        final device = sampleDevices[i];
        final roomId = rooms[i % rooms.length].id;
        
        final deviceJson = device.toJson();
        deviceJson['room_id'] = roomId;
        
        await _client.from('devices').insert(deviceJson);
      }
      
      _logger.i('Seeded database with sample devices');
    } catch (e) {
      _logger.e('Error seeding sample devices: $e');
    }
  }
} 