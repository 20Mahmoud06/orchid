/// Holds the currently signed-in user's profile info.
class UserProfile {
  UserProfile._();

  static final UserProfile instance = UserProfile._();

  String _username = 'Malak Tamer';

  String get username => _username;

  void setUsername(String username) {
    if (username.trim().isEmpty) return;
    _username = username.trim();
  }
}
