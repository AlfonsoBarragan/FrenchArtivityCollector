import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:data_crowslector/themes/style.dart';
enum WidgetMarker { total, ligero, profundo }

class SleepChart extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SleepChartState();

  final List<double> dataToPlotTotal;
  final List<double> dataToPlotLight;
  final List<double> dataToPlotDeep;
  const SleepChart({Key key, @required this.dataToPlotTotal, @required this.dataToPlotLight, @required this.dataToPlotDeep}) : super(key: key);
}

class SleepChartState extends State<SleepChart> {
  final Color barBackgroundColor = CustomTheme.secondaryColor;
  final Duration animDuration = const Duration(milliseconds: 250);
  WidgetMarker selectedWidgetMarker = WidgetMarker.total;



  int touchedIndex;

  bool isPlaying = false;

  Widget getCustomSleepChart() {
    switch (selectedWidgetMarker) {
      case WidgetMarker.total:
        return getTotalSleepChart();
      case WidgetMarker.ligero:
        return getLightSleepChart();
      case WidgetMarker.profundo:
        return getDeepSleepChart();
    }

    return getTotalSleepChart();
  }

  Widget getTotalSleepChart(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const SizedBox(
            height: 38,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BarChart(
                mainBarData(widget.dataToPlotTotal, CustomTheme.terciaryColor),
                swapAnimationDuration: animDuration,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget getLightSleepChart(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const SizedBox(
            height: 38,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BarChart(
                mainBarData(widget.dataToPlotLight, CustomTheme.terciaryColorLight),
                swapAnimationDuration: animDuration,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget getDeepSleepChart(){
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          const SizedBox(
            height: 38,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: BarChart(
                mainBarData(widget.dataToPlotDeep, CustomTheme.terciaryColorDark),
                swapAnimationDuration: animDuration,
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        color: CustomTheme.primaryColorDark,
        child: Stack(
          children: <Widget>[
            Container(
              child: getCustomSleepChart(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    setState(() {
                      selectedWidgetMarker = WidgetMarker.total;
                    });
                  },
                  child: selectedWidgetMarker == WidgetMarker.total ? Text("Total", style: TextStyle(color: CustomTheme.secondaryColorLight)) : Text("Total", style: TextStyle(color: Colors.white70)),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      selectedWidgetMarker = WidgetMarker.ligero;
                    });
                  },
                  child: selectedWidgetMarker == WidgetMarker.ligero ? Text("Ligero", style: TextStyle(color: CustomTheme.secondaryColorLight)) : Text("Ligero", style: TextStyle(color: Colors.white70)),
                ),
                FlatButton(
                  onPressed: () {
                    setState(() {
                      selectedWidgetMarker = WidgetMarker.profundo;
                    });
                  },
                  child: selectedWidgetMarker == WidgetMarker.profundo ? Text("Profundo", style: TextStyle(color: CustomTheme.secondaryColorLight)) : Text("Profundo", style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
      int x,
      double y,
      Color touchedColor, {
        bool isTouched = false,
        Color barColor = CustomTheme.primaryColorLight,
        double width = 22,
        List<int> showTooltips = const [],
      }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + 1 : y,
          color: isTouched ? touchedColor : barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 24,
            color: barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups(List<double> data, Color touchedColor) => List.generate(7, (i) {
    switch (i) {
      case 0:
        return makeGroupData(0, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      case 1:
        return makeGroupData(1, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      case 2:
        return makeGroupData(2, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      case 3:
        return makeGroupData(3, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      case 4:
        return makeGroupData(4, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      case 5:
        return makeGroupData(5, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      case 6:
        return makeGroupData(6, data.elementAt(i).toDouble(), touchedColor, isTouched: i == touchedIndex);
      default:
        return null;
    }
  });

  BarChartData mainBarData(List<double> dataToPlot, Color touchedColor) {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: CustomTheme.primaryColorDark,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;
              switch (group.x.toInt()) {
                case 0:
                  weekDay = 'Lunes';
                  break;
                case 1:
                  weekDay = 'Martes';
                  break;
                case 2:
                  weekDay = 'Miércoles';
                  break;
                case 3:
                  weekDay = 'Jueves';
                  break;
                case 4:
                  weekDay = 'Viernes';
                  break;
                case 5:
                  weekDay = 'Sábado';
                  break;
                case 6:
                  weekDay = 'Domingo';
                  break;
              }
              return BarTooltipItem(
                  weekDay + '\n' + (rod.y - 1).toString(), TextStyle(color: touchedColor));
            }),
        touchCallback: (barTouchResponse) {
          setState(() {
            if (barTouchResponse.spot != null &&
                barTouchResponse.touchInput is! FlPanEnd &&
                barTouchResponse.touchInput is! FlLongPressEnd) {
              touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          textStyle: TextStyle(color: CustomTheme.primaryColorLight, fontWeight: FontWeight.bold, fontSize: 14),
          margin: 16,
          getTitles: (double value) {
            switch (value.toInt()) {
              case 0:
                return 'L';
              case 1:
                return 'M';
              case 2:
                return 'X';
              case 3:
                return 'J';
              case 4:
                return 'V';
              case 5:
                return 'S';
              case 6:
                return 'D';
              default:
                return '';
            }
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(dataToPlot, touchedColor),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(animDuration + const Duration(milliseconds: 50));
    if (isPlaying) {
      refreshState();
    }
  }
}
