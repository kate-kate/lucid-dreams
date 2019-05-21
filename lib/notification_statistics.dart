import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class NotificationStatistics extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  NotificationStatistics(this.seriesList, {this.animate});

  /// Creates a stacked [BarChart] with sample data and no transition.
  factory NotificationStatistics.withSampleData() {
    return new NotificationStatistics(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

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

  /// Create series list with multiple series
  static List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final unreadNotifCount = [
      new OrdinalSales('19.05', 9),
      new OrdinalSales('20.05', 3),
      new OrdinalSales('21.05', 4),
      new OrdinalSales('22.05', 2),
    ];

    final readNotifCount = [
      new OrdinalSales('19.05', 1),
      new OrdinalSales('20.05', 12),
      new OrdinalSales('21.05', 16),
      new OrdinalSales('22.05', 18),
    ];

    return [
      new charts.Series<OrdinalSales, String>(
        id: 'Desktop',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: unreadNotifCount,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.lighter,
      ),
      new charts.Series<OrdinalSales, String>(
        id: 'Tablet',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: readNotifCount,
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
      ),
    ];
  }
}

/// Sample ordinal data type.
class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
