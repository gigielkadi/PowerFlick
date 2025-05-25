import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/home_providers.dart';
import '../../domain/models/device.dart';

class RoomPage extends ConsumerWidget {
  final String roomId;
  
  const RoomPage({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsyncValue = ref.watch(roomProvider(roomId));
    final devicesAsyncValue = ref.watch(roomDevicesProvider(roomId));
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show room settings
            },
          ),
        ],
      ),
      body: roomAsyncValue.when(
        data: (room) {
          if (room == null) {
            return const Center(child: Text('Room not found'));
          }
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Room header with image
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(room.imageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                alignment: Alignment.bottomLeft,
                child: Text(
                  room.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              // Devices in this room
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Devices',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    devicesAsyncValue.when(
                      data: (devices) {
                        if (devices.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text('No devices in this room'),
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: devices.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            return _buildDeviceListTile(context, ref, devices[index]);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error loading devices: $error'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading room: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add device to this room
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildDeviceListTile(BuildContext context, WidgetRef ref, Device device) {
    // Determine icon based on device type
    IconData deviceIcon = Icons.device_unknown;
    switch (device.type) {
      case 'tv':
        deviceIcon = Icons.tv;
        break;
      case 'fridge':
        deviceIcon = Icons.kitchen;
        break;
      case 'light':
        deviceIcon = Icons.lightbulb_outline;
        break;
      case 'ac':
        deviceIcon = Icons.ac_unit;
        break;
    }
    
    return ListTile(
      leading: Icon(
        deviceIcon,
        size: 28,
      ),
      title: Text(device.name),
      subtitle: Text('${device.brand} ${device.model}'),
      trailing: Switch(
        value: device.isOn,
        onChanged: (value) {
          // Toggle device power
          ref.read(toggleDevicePowerProvider(
            ToggleDeviceParams(
              deviceId: device.id,
              isOn: value,
              roomId: roomId,
            )
          ));
        },
      ),
      onTap: () {
        // Navigate to device details
      },
    );
  }
} 