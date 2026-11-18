class Student {
  String name;
  String id;
  String department;
  String room;

  Student({
    required this.name,
    required this.id,
    required this.department,
    this.room = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'department': department,
    'room': room,
  };

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      department: json['department'] ?? '',
      room: json['room'] ?? '',
    );
  }
}

class DormRoom {
  String building;
  String number;

  DormRoom({required this.building, required this.number});

  String get id => '$building-$number';

  Map<String, dynamic> toJson() => {
    'building': building,
    'number': number,
  };

  factory DormRoom.fromJson(Map<String, dynamic> json) {
    return DormRoom(
      building: json['building'] ?? 'A',
      number: json['number'] ?? '101',
    );
  }
}

class MaintenanceRequest {
  String room;
  String issue;
  String status;

  MaintenanceRequest({
    required this.room,
    required this.issue,
    this.status = 'Pending',
  });
}
