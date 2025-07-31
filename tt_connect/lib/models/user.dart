class User {
  final String empId;
  final String name;
  final String email;
  final String? department;
  final String? position;

  User({
    required this.empId,
    required this.name,
    required this.email,
    this.department,
    this.position
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      empId: json['empId'].toString(),
      name: json['name'],
      email: json['email'],
      department: json['department'],
      position: json['position']
    );
  }

}