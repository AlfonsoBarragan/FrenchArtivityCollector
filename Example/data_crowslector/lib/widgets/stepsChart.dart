import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:data_crowslector/themes/style.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class StepsChart extends StatefulWidget {

  final List<FlSpot> dataToPlotDaily;
  final List<FlSpot> dataToPlotWeekly;
  const StepsChart({Key key, @required this.dataToPlotDaily, @required this.dataToPlotWeekly}) : super(key: key);

  @override
  _StepsChartState createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.7,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: CustomTheme.backgroundColor),
            child: Padding(
              padding: const EdgeInsets.only(right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                showAvg ? avgData(widget.dataToPlotWeekly) : mainData(widget.dataToPlotDaily),
              ),
            ),
          ),
        ),
        SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    showAvg = !showAvg;
                  });
                },
                icon: !showAvg ? Icon(MdiIcons.calendarWeek, color: CustomTheme.secondaryColor) : Icon(MdiIcons.calendar, color: CustomTheme.secondaryColor),
              ),
            ),

      ],
    );
  }

  LineChartData mainData(List<FlSpot> dataToPlot) {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: CustomTheme.primaryColorDark,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: CustomTheme.primaryColorDark,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 12,
          textStyle:
          const TextStyle(color: CustomTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '00';
              case 6:
                return '06';
              case 12:
                return '12';
              case 18:
                return '18';
              case 23:
                return '23';
            }
            return '';
          },
          margin: 10,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: CustomTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 25:
                return '25';
              case 50:
                return '50';
              case 75:
                return '75';
              case 100:
                return '100';
              case 125:
                return '125';
              case 150:
                return '150';
              case 175:
                return '175';
              case 200:
                return '200';
            }
            return '';
          },
          reservedSize: 20,
          margin: 12,
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: CustomTheme.primaryColorDark, width: 1)),
      minX: 0,
      maxX: 23,
      minY: 0,
      maxY: 225,
      lineBarsData: [
        LineChartBarData(
          spots: dataToPlot,
          isCurved: true,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors: gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }

  LineChartData avgData(List<FlSpot> dataToPlot) {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: CustomTheme.primaryColorDark,
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: CustomTheme.primaryColorDark,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 12,
          textStyle:
          const TextStyle(color: CustomTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return 'LUN';
              case 2:
                return 'MAR';
              case 3:
                return 'MIE';
              case 4:
                return 'JUE';
              case 5:
                return 'VIE';
              case 6:
                return 'SAB';
              case 7:
                return 'DOM';

            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          textStyle: const TextStyle(
            color: CustomTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '0';
              case 600:
                return '600';
              case 1200:
                return '1200';
              case 1800:
                return '1800';
              case 2400:
                return '2400';

            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData:
      FlBorderData(show: true, border: Border.all(color: CustomTheme.primaryColorDark, width: 1)),
      minX: 1,
      maxX: 7,
      minY: 0,
      maxY: 2399,
      lineBarsData: [
        LineChartBarData(
          spots: dataToPlot,
          isCurved: true,
          colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2),
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2),
          ],
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(show: true, colors: [
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2).withOpacity(0.1),
            ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2).withOpacity(0.1),
          ]),
        ),
      ],
    );
  }
}