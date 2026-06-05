class UserModel {
  final int id;
  final String email;
  final String name;
  final int level;
  final int xp;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.level = 1,
    this.xp    = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:    json['id']          as int,
        email: json['email']       as String,
        name:  json['displayName'] as String? ?? '',
        level: json['level']       as int? ?? 1,
        xp:    json['xp']          as int? ?? 0,
      );
}