class UserProfile {
  String name;
  final String employeeId;
  String email;
  String department;
  String profilePictureUrl;

  UserProfile({
    required this.name,
    required this.employeeId,
    required this.email,
    required this.department,
    required this.profilePictureUrl,
  });
}