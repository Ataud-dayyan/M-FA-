class AppUser {
  final String matricNumber;
  final String fullName;
  final String token;
  final int strikeCount; // 0-3, false-alarm strikes against this student

  AppUser({
    required this.matricNumber,
    required this.fullName,
    required this.token,
    this.strikeCount = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      matricNumber: json['matricNumber'] as String,
      fullName: json['fullName'] as String,
      token: json['token'] as String,
      strikeCount: json['strikeCount'] as int? ?? 0,
    );
  }
}
