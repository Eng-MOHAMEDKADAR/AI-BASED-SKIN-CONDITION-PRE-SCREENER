class Remedy {
  final String organicSolution;
  final String chemicalSolution;

  Remedy({
    required this.organicSolution,
    required this.chemicalSolution,
  });

  Map<String, dynamic> toMap() {
    return {
      'organicSolution': organicSolution,
      'chemicalSolution': chemicalSolution,
    };
  }

  factory Remedy.fromMap(Map<String, dynamic> map) {
    return Remedy(
      organicSolution: map['organicSolution'] ?? '',
      chemicalSolution: map['chemicalSolution'] ?? '',
    );
  }
}
