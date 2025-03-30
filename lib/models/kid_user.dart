class KidUser {
  final String id;
  final String name;
  final String email;

  KidUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory KidUser.fromJson(Map<String, dynamic> json) {
    return KidUser(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}