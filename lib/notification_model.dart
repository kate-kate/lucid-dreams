import 'database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Notification {
  final int id;
  final String date;
  bool isRaised;
  bool isRead;

  Notification({this.id, this.date, this.isRaised, this.isRead});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'is_raised': isRaised, 'is_read': isRead};
  }
}

Future<void> insertNotification(Notification notification) async {
  final db = await DBProvider.db.database;

  await db.insert('notifications', notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<charts.Series<NotificationDataWrapper, String>>>
    chartSeries() async {
  final notifList = await notifications();

  Map<String, Map<String, NotificationDataWrapper>> statusNotifMap = Map();

  notifList.forEach((Notification notif) {
    String status =
        notif.isRaised ? (notif.isRead ? 'read' : 'unread') : 'unraised';
    Map<String, NotificationDataWrapper> dateNotifMap =
        (statusNotifMap != null && statusNotifMap.containsKey(status))
            ? statusNotifMap[status]
            : new Map<String, NotificationDataWrapper>();

    NotificationDataWrapper nData = dateNotifMap.containsKey(notif.date)
        ? dateNotifMap[notif.date]
        : NotificationDataWrapper(notif.date, 0);
    nData.increment();
    dateNotifMap[notif.date] = nData;
    statusNotifMap[status] = dateNotifMap;
  });

  var res = new List<charts.Series<NotificationDataWrapper, String>>();

  if (statusNotifMap['unraised'] != null) {
    res.add(new charts.Series<NotificationDataWrapper, String>(
      id: 'Unraised',
      domainFn: (NotificationDataWrapper notifData, _) => notifData.date,
      measureFn: (NotificationDataWrapper notifData, _) => notifData.count,
      data: statusNotifMap['unraised'].values.toList(),
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.lighter,
    ));
  }
  return res;
}

class NotificationDataWrapper {
  final String date;
  int count;

  NotificationDataWrapper(this.date, this.count);

  increment() {
    this.count++;
  }
}

Future<List<Notification>> notifications() async {
  final db = await DBProvider.db.database;
  final List<Map<String, dynamic>> nList = await db.query('notifications');

  return List.generate(nList.length, (i) {
    return Notification(
      id: nList[i]['id'],
      date: nList[i]['date'],
      isRaised: nList[i]['is_raised'] == 1 ? true : false,
      isRead: nList[i]['is_read'] == 1 ? true : false,
    );
  });
}

