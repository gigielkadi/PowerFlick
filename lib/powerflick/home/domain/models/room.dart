import 'dart:convert';

class Room {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> deviceIds;

  Room({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.deviceIds = const [],
  });

  Room copyWith({
    String? id,
    String? name,
    String? imageUrl,
    List<String>? deviceIds,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      deviceIds: deviceIds ?? this.deviceIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'device_ids': deviceIds,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      deviceIds: json['device_ids'] != null 
        ? List<String>.from(json['device_ids'])
        : [],
    );
  }

  static List<Room> getDefaultRooms() {
    return [
      Room(
        id: '1',
        name: 'Bedroom',
        imageUrl: 'assets/illustrations/bedrom.png',
      ),
      Room(
        id: '2',
        name: 'Kitchen',
        imageUrl: 'assets/illustrations/kitchen.png',
      ),
      Room(
        id: '3',
        name: 'Bathroom',
        imageUrl: 'assets/illustrations/bathroom.png',
      ),
      Room(
        id: '4',
        name: 'Living Room',
        imageUrl: 'assets/illustrations/living_room.png',
      ),
    ];
  }
} 