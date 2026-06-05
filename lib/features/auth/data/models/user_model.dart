class UserModel {
  final int    id;
  final String email;
  final String name;
  final int    level;
  final int    xp;
  final String role;         // 'member' | 'gym_owner' | 'super_admin'
  final bool   isOnboarded;  // false = show onboarding

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.level       = 1,
    this.xp          = 0,
    this.role        = 'member',
    this.isOnboarded = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id:          j['id']          as int,
        email:       j['email']       as String,
        name:        j['displayName'] as String?  ?? '',
        level:       j['level']       as int?     ?? 1,
        xp:          j['xp']          as int?     ?? 0,
        role:        j['role']        as String?  ?? 'member',
        isOnboarded: j['isOnboarded'] as bool?    ?? false,
      );
}

// ─── Login Result ─────────────────────────────────────────────────────────────

class LoginResult {
  final UserModel user;
  final String    accessToken;
  final String    refreshToken;

  const LoginResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> j) => LoginResult(
        user:         UserModel.fromJson(j['user'] as Map<String, dynamic>),
        accessToken:  j['accessToken']  as String,
        refreshToken: j['refreshToken'] as String,
      );
}