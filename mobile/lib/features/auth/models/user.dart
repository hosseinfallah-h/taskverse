
/// Plain user model for TaskVerse.
///
/// Keeps JSON field names compatible with the existing API.
/// No code generation or additional dependencies required.
class User {
  const User({
    required this.id,
    required this.phone,
    required this.name,
    this.email,
    this.avatarPath,
    this.timezone = 'Asia/Tehran',
    this.tier = 'pending',
    this.xp = 0,
    this.level = 1,
    this.briefHour = 7,
    this.recapHour = 21,
  });

  final int id;
  final String phone;
  final String name;
  final String? email;
  final String? avatarPath;
  final String timezone;
  final String tier;
  final int xp;
  final int level;
  final int briefHour;
  final int recapHour;

  /// Whether the user has a non-empty display name.
  bool get hasName => name.trim().isNotEmpty;

  /// Whether an email address is available.
  bool get hasEmail => email?.trim().isNotEmpty ?? false;

  /// Whether an avatar path is available.
  bool get hasAvatar => avatarPath?.trim().isNotEmpty ?? false;

  /// Whether the user has reached a positive XP total.
  bool get hasXp => xp > 0;

  /// XP remaining until the next level.
  ///
  /// XP thresholds are not defined by this model, so this model
  /// intentionally does not calculate progression.
  ///
  /// Use [xp] and [level] with the application's progression rules.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _readInt(json, 'id', required: true)!,
      phone: _readString(json, 'phone', required: true)!,
      name: _readString(json, 'name', required: true)!,
      email: _readString(json, 'email'),
      avatarPath: _readString(json, 'avatar_path'),
      timezone: _readString(json, 'timezone') ?? 'Asia/Tehran',
      tier: _readString(json, 'tier') ?? 'pending',
      xp: _readInt(json, 'xp') ?? 0,
      level: _readInt(json, 'level') ?? 1,
      briefHour: _readInt(json, 'brief_hour') ?? 7,
      recapHour: _readInt(json, 'recap_hour') ?? 21,
    );
  }

  /// Converts the model to the API's existing snake_case format.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'email': email,
      'avatar_path': avatarPath,
      'timezone': timezone,
      'tier': tier,
      'xp': xp,
      'level': level,
      'brief_hour': briefHour,
      'recap_hour': recapHour,
    };
  }

  /// Creates a copy while retaining unspecified values.
  ///
  /// Use [clearEmail] or [clearAvatarPath] to explicitly clear
  /// nullable fields.
  User copyWith({
    int? id,
    String? phone,
    String? name,
    String? email,
    String? avatarPath,
    String? timezone,
    String? tier,
    int? xp,
    int? level,
    int? briefHour,
    int? recapHour,
    bool clearEmail = false,
    bool clearAvatarPath = false,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: clearEmail ? null : (email ?? this.email),
      avatarPath:
          clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
      timezone: timezone ?? this.timezone,
      tier: tier ?? this.tier,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      briefHour: briefHour ?? this.briefHour,
      recapHour: recapHour ?? this.recapHour,
    );
  }

  static String? _readString(
    Map<String, dynamic> json,
    String key, {
    bool required = false,
  }) {
    final value = json[key];

    if (value == null) {
      if (required) {
        throw FormatException('Missing required user field: $key');
      }
      return null;
    }

    if (value is String) return value;

    throw FormatException('Invalid user field type: $key');
  }

  static int? _readInt(
    Map<String, dynamic> json,
    String key, {
    bool required = false,
  }) {
    final value = json[key];

    if (value == null) {
      if (required) {
        throw FormatException('Missing required user field: $key');
      }
      return null;
    }

    if (value is int) return value;

    // JSON APIs sometimes encode integer values as whole numbers.
    if (value is num && value.isFinite && value == value.truncate()) {
      return value.toInt();
    }

    throw FormatException('Invalid user field type: $key');
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'phone: $phone, '
        'name: $name, '
        'email: $email, '
        'timezone: $timezone, '
        'tier: $tier, '
        'xp: $xp, '
        'level: $level'
        ')';
  }
}
