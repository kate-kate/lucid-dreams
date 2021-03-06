import 'database.dart';
import 'package:sqflite/sqflite.dart';
import 'package:charts_flutter/flutter.dart' as charts;

const String statusUnraised = 'unraised';
const String statusRaised = 'raised';
const String statusRead = 'read';

class Notification {
  final int id;
  final String date;
  bool isRaised;
  bool isRead;

  Notification({this.id, this.date, this.isRaised, this.isRead});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date, 'is_raised': isRaised, 'is_read': isRead};
  }

  factory Notification.fromMap(Map<String, dynamic> res) => new Notification(
        id: res["id"],
        date: res["date"],
        isRaised: res["is_raised"] == 1 ? true : false,
        isRead: res["is_read"] == 1 ? true : false,
      );

  markAsRaised() {
    this.isRaised = true;
  }

  markAsRead() {
    this.isRead = true;
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
        notif.isRaised ? (notif.isRead ? statusRaised : statusRead) : statusUnraised;
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

  if (statusNotifMap[statusUnraised] != null) {
    res.add(new charts.Series<NotificationDataWrapper, String>(
      id: 'Unraised',
      domainFn: (NotificationDataWrapper notifData, _) => notifData.date,
      measureFn: (NotificationDataWrapper notifData, _) => notifData.count,
      data: statusNotifMap[statusUnraised].values.toList(),
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.lighter,
    ));
  }

  if (statusNotifMap[statusRaised] != null) {
    res.add(new charts.Series<NotificationDataWrapper, String>(
      id: 'Raised',
      domainFn: (NotificationDataWrapper notifData, _) => notifData.date,
      measureFn: (NotificationDataWrapper notifData, _) => notifData.count,
      data: statusNotifMap[statusRaised].values.toList(),
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
    ));
  }

  if (statusNotifMap[statusRead] != null) {
    res.add(new charts.Series<NotificationDataWrapper, String>(
      id: 'Read',
      domainFn: (NotificationDataWrapper notifData, _) => notifData.date,
      measureFn: (NotificationDataWrapper notifData, _) => notifData.count,
      data: statusNotifMap[statusRead].values.toList(),
      colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault.darker,
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

Future<void> removeNotifications(String date) async {
  final db = await DBProvider.db.database;
  await db.delete('notifications',
      where: "date = ? and is_raised = 0", whereArgs: [date]);
}

Future<Notification> findNotification(int id) async {
  final db = await DBProvider.db.database;
  var res = await db.query('notifications', where: "id = ?", whereArgs: [id]);
  return res.isNotEmpty ? Notification.fromMap(res.first) : Null;
}

Future<void> updateNotification(Notification notification) async {
  final db = await DBProvider.db.database;
  await db.update('notifications', notification.toMap(),
      where: "id = ?", whereArgs: [notification.id]);
}

Future<List<Notification>> findNotificationsForDate(String date) async {
  final db = await DBProvider.db.database;
  var res = await db.query('notifications', where: "date = ?", whereArgs: [date]);
  List<Notification> notifList = new List<Notification>();
  res.forEach((Map<String, dynamic> map) {
    Notification notif = Notification.fromMap(map);
    notifList.add(notif);
  });
  return notifList;
}

Future<int> getBiggestIdForStart() async {
  final db = await DBProvider.db.database;
  var res = Sqflite
    .firstIntValue(await db.rawQuery("SELECT MAX(id) FROM notifications"));
  return res;
}