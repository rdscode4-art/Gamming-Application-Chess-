class UserModel {
  final String userId;
  final String username;
  final int rating;

  UserModel({required this.userId, required this.username, required this.rating});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      username: json['username'],
      rating: json['rating'],
    );
  }
}
