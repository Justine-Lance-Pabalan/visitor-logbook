class Visitor {
  int? id;
  final String name;
  final String srCode;
  final String department;
  final String purpose;
  final String propertyUsed;
  String pin;
  DateTime date;
  DateTime timeIn;
  DateTime? timeOut;
  bool propertyReturned;

  Visitor({
    this.id,
    required this.name,
    required this.srCode,
    required this.department,
    required this.purpose,
    required this.propertyUsed,
    required this.pin,
    required this.date,
    required this.timeIn,
    this.timeOut,
    this.propertyReturned = false,
  });

  bool get hasProperty {
    return propertyUsed != "N/A";
  }

  // For API (snake_case)
  Map<String, dynamic> toApiMap() {
    return {
      'name': name,
      'sr_code': srCode,
      'department': department,
      'purpose': purpose,
      'property_used': propertyUsed,
      'pin': pin,
      'date': date.toIso8601String(),
      'time_in': timeIn.toIso8601String(),
      'time_out': timeOut?.toIso8601String(),
      'property_returned': propertyReturned ? 1 : 0,
    };
  }

  // From API response (snake_case)
  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'],
      name: map['name'],
      srCode: map['sr_code'] ?? map['srCode'] ?? '',
      department: map['department'] ?? '',
      purpose: map['purpose'] ?? '',
      propertyUsed: map['property_used'] ?? map['propertyUsed'] ?? 'N/A',
      pin: map['pin'] ?? '0000',
      date: DateTime.parse(
        map['date'] ?? map['time_in'] ?? DateTime.now().toIso8601String()).toLocal(),
      timeIn: DateTime.parse(
        map['time_in'] ?? map['timeIn'] ?? DateTime.now().toIso8601String()).toLocal(),
      timeOut: (map['time_out'] ?? map['timeOut']) != null
          ? DateTime.parse(map['time_out'] ?? map['timeOut']).toLocal()
          : null,
      propertyReturned:
          (map['property_returned'] ?? map['propertyReturned']) == 1,
    );
  }
}
