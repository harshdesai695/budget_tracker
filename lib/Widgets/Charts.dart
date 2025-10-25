import 'package:budget_tracker/Models/ChartModels.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChart extends StatelessWidget {
  final List<PieChartData> piedate;
  PieChart({super.key, required this.piedate});

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: <PieSeries<PieChartData, String>>[
        PieSeries<PieChartData, String>(
          dataSource: piedate,
          xValueMapper: (PieChartData x, _) => x.category,
          yValueMapper: (PieChartData y, _) => y.sales,
          pointColorMapper: (PieChartData data, _) => data.color,
        ),
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true),
      selectionGesture: ActivationMode.longPress,
    );
  }
}

class DonutChart extends StatelessWidget {
  final List<DonutChartData> donutChartData;

  const DonutChart({super.key, required this.donutChartData});
  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      series: <CircularSeries<DonutChartData, String>>[
        DoughnutSeries<DonutChartData, String>(
          dataSource: donutChartData,
          xValueMapper: (DonutChartData x, _) => x.category,
          yValueMapper: (DonutChartData y, _) => y.sales,
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
      legend: Legend(isVisible: true),
      selectionGesture: ActivationMode.longPress,
    );
  }
}