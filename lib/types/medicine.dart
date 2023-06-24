class Prescription {
  final String patientName;
  final String gender;
  final int age;
  final List<Medicine> medicines = [];

  Prescription(
      {required this.patientName,
      required this.gender,
      required this.age,
      });
}

class Medicine {
  final String type;
  final String name;
  final int quantity;
  final List<Frequency>? frequency;
  // final int duration;

  Medicine(
    this.type,
    this.name,
    // this.duration,
    this.quantity,
    this.frequency
  );
}

class Frequency {
  final String details;
  final int quantity;

  Frequency({required this.details, required this.quantity});
}
