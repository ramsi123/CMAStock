import 'package:fl_chart/fl_chart.dart';

List<FlSpot> calculateLineChart(List<int> numOrderPerMonth) {
  final List<FlSpot> lineChartCoordinate = [
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
    const FlSpot(0, 0),
  ];
  int index = 0;

  for (var value in numOrderPerMonth) {
    int y1 = 0;
    int y2 = 0;
    int y1Value = 0;
    int y2Value = 0;

    if (value >= 0 && value <= 25) {
      y1 = 0;
      y2 = 2;
      y1Value = 0;
      y2Value = 25;
    } else if (value > 25 && value <= 50) {
      y1 = 2;
      y2 = 4;
      y1Value = 25;
      y2Value = 50;
    } else if (value > 50 && value <= 75) {
      y1 = 4;
      y2 = 6;
      y1Value = 50;
      y2Value = 75;
    } else if (value > 75) {
      y1 = 6;
      y2 = 8;
      y1Value = 75;
      y2Value = 100;
    }

    double yChart = y1 + ((value - y1Value) / (y2Value - y1Value)) * (y2 - y1);

    // assign to line chart coordinate
    lineChartCoordinate[index] = FlSpot(index.toDouble(), yChart);

    // increment index
    index++;
  }

  return lineChartCoordinate;
}
