class ContactModel {
  final String id;
  final String name;
  final String email;

  ContactModel({required this.id, required this.name, required this.email});

  factory ContactModel.fromJson(Map<String, dynamic> json) => ContactModel(
    id:
        json['id']?.toString() ??
        json['userId']?.toString() ??
        json['contactId']?.toString() ??
        '',
    name:
        json['name']?.toString() ??
        json['fullName']?.toString() ??
        json['userName']?.toString() ??
        '',
    email: json['email']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
