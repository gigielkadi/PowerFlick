class Device {
  final String id;
  final String name;
  final String type;
  final String brand;
  final String model;
  final bool isOn;
  final bool isSmart;
  final Map<String, dynamic> properties;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    this.isOn = false,
    this.isSmart = false,
    this.properties = const {},
  });

  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? brand,
    String? model,
    bool? isOn,
    bool? isSmart,
    Map<String, dynamic>? properties,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      isOn: isOn ?? this.isOn,
      isSmart: isSmart ?? this.isSmart,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'brand': brand,
      'model': model,
      'is_on': isOn,
      'is_smart': isSmart,
      'properties': properties,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      brand: json['brand'],
      model: json['model'],
      isOn: json['is_on'] ?? false,
      isSmart: json['is_smart'] ?? false,
      properties: json['properties'] ?? {},
    );
  }

  static List<Device> getSampleDevices() {
    return [
      Device(
        id: '1',
        name: 'Smart TV',
        type: 'tv',
        brand: 'Samsung',
        model: '55" Neo QLED 4K',
        isSmart: true,
      ),
      Device(
        id: '2',
        name: 'Non Smart Fridge',
        type: 'fridge',
        brand: 'LG',
        model: 'GTF402SVAN',
        isSmart: false,
      ),
      Device(
        id: '3',
        name: 'Smart Light',
        type: 'light',
        brand: 'Philips',
        model: 'Hue White',
        isSmart: true,
      ),
      Device(
        id: '4',
        name: 'AC Unit',
        type: 'ac',
        brand: 'Daikin',
        model: 'FTX20JV',
        isSmart: true,
      ),
    ];
  }
} 