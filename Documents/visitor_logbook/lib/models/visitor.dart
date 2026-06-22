class Visitor {

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

}