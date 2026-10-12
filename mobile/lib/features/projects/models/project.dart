class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    this.archived = false,
  });

  final int id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final bool archived;

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String?,
    color: json['color'] as String?,
    icon: json['icon'] as String?,
    archived: (json['archived'] as bool?) ?? false,
  );
}
