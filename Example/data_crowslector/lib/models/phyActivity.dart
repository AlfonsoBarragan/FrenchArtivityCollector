import 'package:cloud_firestore/cloud_firestore.dart';

class PhyActivity {
   int heartRate;
   int intensity;
   int kind;
   int steps;
   Timestamp timestamp;

  PhyActivity({
    this.heartRate,
    this.kind,
    this.intensity,
    this.steps,
    this.timestamp,
  });


  factory PhyActivity.fromMap(Map<String, dynamic> map) {
    return PhyActivity(
      heartRate: map['heartRate'],
      kind: map['kindraw'],
      intensity: map['intensity'],
      steps: map['steps'],
      timestamp: map['timestamp'],
    );
  }

  @override
  String toString(){
    return 'heartRate: $heartRate, kind: $kind, intensity:$intensity, steps: $steps, timestamp: $timestamp';
  }
  
}
