class Employee {
  final String id;
  final String name;
  final String designation;
  final String section;

  Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.section,
  });

  // Factory constructor to create an Employee from a Firestore document
  factory Employee.fromFirestore(Map<String, dynamic> data, String id) {
    return Employee(
      id: id,
      name: data['name'] ?? '',
      designation: data['designation'] ?? '',
      section: data['section'] ?? '',
    );
  }

  // Method to convert an Employee to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'designation': designation,
      'section': section,
    };
  }
}
