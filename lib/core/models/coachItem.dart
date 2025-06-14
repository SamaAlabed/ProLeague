class Coach {
  final String name;
  final String team;
  final String picture;
  final String logo;

  Coach({
    required this.name,
    required this.team,
    required this.picture,
    required this.logo,
  });

  factory Coach.fromMap(Map<String, dynamic> map) {
    return Coach(
      name: map['CoachName'] ?? '',
      team: map['TeamName'] ?? '',
      picture: map['image'] ?? '',
      logo: map['teamLogo'] ?? '',
    );
  }
}
