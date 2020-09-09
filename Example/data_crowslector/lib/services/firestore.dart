import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_crowslector/models/phyActivity.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:data_crowslector/pages/home.dart';


import 'dart:async';

import 'package:data_crowslector/services/auth.dart';

final CollectionReference phyActivityRef =
Firestore.instance.collection('phy_activity');

class PhyActivityService {
  // Factory constructor which returns a singleton instance
  // of the service
  PhyActivityService._();
  static final PhyActivityService _instance = PhyActivityService._();
  factory PhyActivityService() => _instance;
  bool _initialized = false;

  AuthService _authService = AuthService();

  Future<void> init() async {
    if (!_initialized) {
      _initialized = true;
    }
  }

  void dispose() {
    _initialized = false;
  }

  /// Given a list of phyActivity object, return a Map with keys for
  /// min, max and median BPM values
  Map<String, int> calculateMinMaxMedian(List<PhyActivity> phyActivities) {
    Map<String, int> result = new Map();
    result['median'] = 0;
    result['max'] = 0;
    result['min'] = 0;

    if (phyActivities.isNotEmpty) {
      int sum = 0;
      int count = 0;
      int max;
      int min;

      phyActivities.forEach((element) {
        if (element.heartRate != null) {
          count++;
          sum += element.heartRate;

          if (min == null) {
            min = element.heartRate;
            max = element.heartRate;
          } else {
            min = element.heartRate < min ? element.heartRate : min;
            max = element.heartRate > max ? element.heartRate : max;
          }
        }
      });

      result['median'] = (sum / count).round();
      result['max'] = max;
      result['min'] = min;
    }

    return result;
  }

  Future<List<Stats>> getDailyStats(DateTime dateFrom, DateTime dateTo) async{
    List<PhyActivity> activitiesInWeek = await read(dateFrom, dateTo);
    List<Stats> rates = new List<Stats>();
    int sleep = 0;
    int last_heartRate = 0;

    for (PhyActivity activity in activitiesInWeek){
      DateTime fecha = DateTime.fromMillisecondsSinceEpoch(activity.timestamp.millisecondsSinceEpoch);
      double minuteWithFraction = fecha.hour + (fecha.minute/100);

      if (activity.heartRate < 255 && activity.heartRate > 0){
        last_heartRate = activity.heartRate;
      }
      if (activity.kind == 112 || activity.kind == 121 || activity.kind == 122){
        sleep = 1;
      } else {
        sleep = 0;
      }
      rates.add(new Stats(minuteWithFraction, sleep, activity.steps, last_heartRate, fecha));
    }
    return rates;
  }

  Future<List<WeeklyStats>> getWeeklyStats(DateTime dateFrom, DateTime dateTo) async{
    List<PhyActivity> activitiesInWeek = await read(dateFrom, dateTo);
    List<WeeklyStats> rates = new List<WeeklyStats>();
    if (activitiesInWeek.isNotEmpty) {
      int sleep = 0;
      int sleepLight = 0;
      int sleepDeep = 0;
      int last_heartRate = 0;
      int counter = 0;
      int lastWeekDay = DateTime
          .fromMillisecondsSinceEpoch(
          activitiesInWeek[0].timestamp.millisecondsSinceEpoch)
          .weekday;

      int sleepAc = 0;
      double stepAc = 0;
      double heartRateAc = 0;

      for (PhyActivity activity in activitiesInWeek) {
        DateTime fecha = DateTime.fromMillisecondsSinceEpoch(
            activity.timestamp.millisecondsSinceEpoch);

        if (activity.heartRate < 255 && activity.heartRate > 0) {
          last_heartRate = activity.heartRate;
        }
        if (activity.kind == 112 || activity.kind == 121 ||
            activity.kind == 122) {
          sleep = 1;

          if (activity.kind == 112) {
            sleepLight += 1;
          } else if (activity.kind == 121 || activity.kind == 122) {
            sleepDeep += 1;
          }
        } else {
          sleep = 0;
        }

        if (lastWeekDay != fecha.weekday) {
          heartRateAc = (heartRateAc / counter);
          rates.add(new WeeklyStats(
              lastWeekDay.toDouble(),
              sleepAc,
              sleepLight,
              sleepDeep,
              stepAc,
              heartRateAc,
              fecha.subtract(new Duration(hours: 2))));
          heartRateAc = last_heartRate.toDouble();
          stepAc = activity.steps.toDouble();
          sleepAc = sleep;
          counter = 1;
          lastWeekDay = fecha.weekday;

          if (activity.kind == 112) {
            sleepLight = 1;
          } else if (activity.kind == 121 || activity.kind == 122) {
            sleepDeep = 1;
          } else {
            sleepLight = 0;
            sleepDeep = 0;
          }
        } else {
          sleepAc += sleep;
          heartRateAc += last_heartRate;
          stepAc += activity.steps;
          counter += 1;
        }
      }
    } else {
      rates.add(new WeeklyStats(
          0.0,
          0,
          0,
          0,
          0,
          0,
          DateTime.now()));
    }

    return rates;
  }

  Future<List<double>> getResumeParameters(DateTime dateFrom, DateTime dateTo) async{
    List<PhyActivity> activitiesInDay = await read(dateFrom, dateTo);

    double steps = 0;
    double heartRate = 0;
    double lastStepSample = 0;
    int lastHeartRateSample = 0;
    int samples = 0;
    int heartRateNullSamples = 0;
    double sleep = 0;

    List<double> parameters = new List<double>();

    for (PhyActivity phyActivity in activitiesInDay){
      steps += phyActivity.steps;
      if (phyActivity.heartRate != 255 && phyActivity.heartRate != 0){
        samples += 1;
        heartRate += phyActivity.heartRate;
        lastHeartRateSample = phyActivity.heartRate;
      } else if(phyActivity.heartRate == 255){
        heartRate += lastHeartRateSample;
      } else {
        heartRateNullSamples++;
      }
      if (phyActivity.kind == 112 || phyActivity.kind == 115){
        sleep++;
      }
    }
    lastStepSample += steps;
    parameters.add(lastStepSample);
    parameters.add(heartRate/samples - heartRateNullSamples);
    parameters.add(sleep);

    print(parameters[0]);
    return parameters;
  }
  /// Read phyActivities between dateFrom and dateTo
  /// If fillWithNull is true, then fill missing  values with a new PhyActivity where heartRate is null
  Future<List<PhyActivity>> read(DateTime dateFrom, DateTime dateTo,
      {bool fillWithNull = false}) async {
    List<PhyActivity> activities = [];
    DateTime _currentDateFrom = dateFrom;

    // Iterate for each day between dateFrom and dateTo..
    while (_currentDateFrom.isBefore(dateTo)) {
      // If currentDateFrom is at same day as dateTo
      if (_isSameDay(_currentDateFrom, dateTo)) {
        List<PhyActivity> newActivities =
        await _addPartialDay(_currentDateFrom, dateTo);
        activities = new List.from(activities)..addAll(newActivities);
      }
      // For first day..
      else if (_isSameDay(_currentDateFrom, dateFrom)) {
        DateTime limitDate =
        DateTime(dateFrom.year, dateFrom.month, dateFrom.day, 23, 59, 59)
            .toLocal();
        List<PhyActivity> newActivities =
        await _addPartialDay(dateFrom, limitDate);
        activities = new List.from(activities)..addAll(newActivities);
      }
      // For any day between dateTo and dateFrom
      else {
        List<PhyActivity> newActivities = await _addAllDay(_currentDateFrom);
        activities = new List.from(activities)..addAll(newActivities);
      }

      // Step to next day at 00:00
      _currentDateFrom = new DateTime(_currentDateFrom.year,
          _currentDateFrom.month, _currentDateFrom.day + 1, 0, 0);
    }

    if (fillWithNull && activities.isNotEmpty) {
      activities = _fillWithNull(activities, dateFrom, dateTo);
    }
    return activities;
  }

  /// Fill missing values with a new PhyActivity object where heartRate is null
  List<PhyActivity> _fillWithNull(
      List<PhyActivity> activities, DateTime dateFrom, DateTime dateTo) {
    print("fill with null. Habia: " + activities.length.toString());

    DateTime currentDate = dateFrom;
    int index = 0;
    while (currentDate.isBefore(dateTo)) {
      if (!(activities[index]
          .timestamp
          .toDate()
          .isAtSameMomentAs(currentDate))) {
        activities.insert(
            index, new PhyActivity(timestamp: Timestamp.fromDate(currentDate)));
      } else if (index < activities.length - 1) {
        index++;
      }
      currentDate = currentDate.add(const Duration(minutes: 1));
    }
    print("fill with null. Después: " + activities.length.toString());
    return activities;
  }

  Future<List<PhyActivity>> _addPartialDay(
      DateTime dateFrom, DateTime dateTo) async {
    List<PhyActivity> activities = [];
    String strDate = _dateAsString(dateFrom);
    int hourFrom = dateFrom.hour;
    int hourTo = dateTo.hour;

    // Get physical activities for each hour between
    // dateFrom and dateTo
    for (int i = hourFrom; i <= hourTo; i++) {
      String strHour = _hourAsString(i);
      DocumentSnapshot doc = await phyActivityRef
          .document(_authService.user.id)
          .collection(strDate)
          .document(strHour)
          .get();

      if (doc.exists) {
        doc.data['activities'].forEach((act) {
          DateTime timestamp = act['timestamp'].toDate();
          if (timestamp.isAtSameMomentAs(dateFrom) ||
              timestamp.isAtSameMomentAs(dateTo)) {
            activities.add(PhyActivity.fromMap(act));
          } else if (timestamp.isBefore(dateTo) &&
              timestamp.isAfter(dateFrom)) {
            activities.add(PhyActivity.fromMap(act));
          }
        });
      }
    }
    return activities;
  }

  Future<List<PhyActivity>> _addAllDay(DateTime date) async {
    List<PhyActivity> activities = [];
    String strDate = _dateAsString(date);

    QuerySnapshot docs = await phyActivityRef
        .document(_authService.user.id)
        .collection(strDate)
        .getDocuments();

    docs.documents.forEach((doc) {
      doc.data['activities'].forEach((act) {
        activities.add(PhyActivity.fromMap(act));
      });
    });
    return activities;
  }

  bool _isSameDay(DateTime dateFrom, DateTime dateTo) {
    return dateFrom.year == dateTo.year &&
        dateFrom.month == dateTo.month &&
        dateFrom.day == dateTo.day;
  }

  String _hourAsString(int hour) {
    return hour < 10 ? "0" + hour.toString() + "_00" : hour.toString() + "_00";
  }

  String _dateAsString(DateTime date) {
    return date.toIso8601String().split("T")[0].replaceAll("-", "_");
  }


}

class Stats {
  Stats(this.time, this.sleep, this.steps, this.heartRate, this.fecha);
  final double time;
  final int sleep;
  final int steps;
  final int heartRate;
  final DateTime fecha;
}

class WeeklyStats {
  WeeklyStats(this.time, this.sleepTotal, this.sleepLight, this.sleepDeep, this.steps, this.heartRate, this.fecha);
  final double time;
  final int sleepTotal;
  final int sleepLight;
  final int sleepDeep;
  final double steps;
  final double heartRate;
  final DateTime fecha;
}


