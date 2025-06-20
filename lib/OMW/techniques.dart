class Technique {
  final String title;
  final String description;

  Technique({required this.title, required this.description});

  factory Technique.fromFirestore(Map<String, dynamic> data) {
    return Technique(
      title: data['title'] ?? 'Untitled',
      description: data['description'] ?? '',
    );
  }
}
