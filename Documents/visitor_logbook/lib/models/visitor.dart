class Visitor {
  int? id;
  final String name;
  final String srCode;
  final String department;

  final String purpose;
  final String propertyUsed;

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
    required this.date,
    required this.timeIn,

    this.timeOut,

    this.propertyReturned = false,
  });


  bool get hasProperty {
    return propertyUsed != "N/A";
  }

  // Convert a Visitor into a Map for saving to database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'srCode': srCode,
      'department': department,
      'purpose': purpose,
      'propertyUsed': propertyUsed,
      'date': date.toIso8601String(),
      'timeIn': timeIn.toIso8601String(),
      'timeOut': timeOut?.toIso8601String(),
      'propertyReturned': propertyReturned ? 1 : 0,
    };
  }

  // Convert a Map from the database back into a Visitor
  factory Visitor.fromMap(Map<String, dynamic> map) {
    return Visitor(
      id: map['id'],
      name: map['name'],
      srCode: map['srCode'],
      department: map['department'],
      purpose: map['purpose'],
      propertyUsed: map['propertyUsed'],
      date: DateTime.parse(map['date']),
      timeIn: DateTime.parse(map['timeIn']),
      timeOut: map['timeOut'] != null
          ? DateTime.parse(map['timeOut'])
          : null,
      propertyReturned: map['propertyReturned'] == 1,
    );
  }
}