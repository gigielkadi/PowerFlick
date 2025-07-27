class Room {
  final String id;
  final String type; // e.g., "Bedroom"
  final String name; // e.g., "Bedroom 1"
  final int? count;

  Room({
    required this.id,
    required this.type,
    required this.name,
    this.count,
  });

  Room copyWith({
    String? id,
    String? type,
    String? name,
    int? count,
  }) {
    return Room(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      count: count ?? this.count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'count': count,
    };
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      type: json['type']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      count: json['count'] is int ? json['count'] : int.tryParse(json['count']?.toString() ?? ''),
    );
  }

  static String imageForType(String type) {
    switch (type) {
      case 'Bedroom':
        return 'assets/illustrations/bedrom.png';
      case 'Living room':
        return 'assets/illustrations/living_room.png';
      case 'Kitchen':
        return 'assets/illustrations/kitchen.png';
      case 'Bathroom':
        return 'assets/illustrations/bathroom.png';
      default:
        return 'assets/illustrations/custom_room.png';
    }
  }

  String get imageAsset => imageForType(type);

  static List<Room> getDefaultRooms() {
    return [
      Room(
        id: '1',
        type: 'Bedroom',
        name: 'Bedroom 1',
      ),
      Room(
        id: '2',
        type: 'Kitchen',
        name: 'Kitchen 1',
      ),
      Room(
        id: '3',
        type: 'Bathroom',
        name: 'Bathroom 1',
      ),
      Room(
        id: '4',
        type: 'Living room',
        name: 'Living Room 1',
      ),
    ];
  }
} 