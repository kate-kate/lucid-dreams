import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class NotificationStatistics extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  NotificationStatistics(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Statistics'),
        textTheme: TextTheme(
            title: TextStyle(color: Colors.greenAccent, fontSize: 18)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: charts.BarChart(
          seriesList,
          animate: animate,
          barGroupingType: charts.BarGroupingType.stacked,
          domainAxis: charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
                labelStyle:
                    charts.TextStyleSpec(color: charts.MaterialPalette.white)),
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
                labelStyle:
                    charts.TextStyleSpec(color: charts.MaterialPalette.white)),
          ),
        ),
      ),
    );
  }
}