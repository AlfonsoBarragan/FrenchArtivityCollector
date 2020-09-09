import 'package:cloud_firestore/cloud_firestore.dart';

class Youngster {
  YoungsterStatus status;
  double altura;
  double peso;
  Timestamp fechaNacimiento;

  Youngster({
    this.status,
    this.altura,
    this.peso,
    this.fechaNacimiento,
  });

  factory Youngster.fromDocument(DocumentSnapshot doc) {
    return Youngster(
        status: YoungsterStatus.values
            .firstWhere((e) => e.toString() == 'YoungsterStatus.' + doc['status']),
        altura: doc['altura'],
        peso: doc['peso'],
        fechaNacimiento: doc['fechaNacimiento']
    );
  }

  @override
  String toString(){
    return 'estado: $status, altura: $altura, peso: $peso, fechaNacimiento: ${fechaNacimiento.toDate().toIso8601String()}';
  }
}

enum YoungsterStatus {
  pretest_pending,
  pretest_in_progress,
  pretest_completed,
}