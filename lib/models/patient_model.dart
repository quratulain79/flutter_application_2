class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
  });

  factory Patient.fromMap(String id, Map<String, dynamic> data) {
    return Patient(
      id: id,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
    );
  }
}
