import 'package:flutter/material.dart';
import 'notification_settings.dart';
import 'notification_statistics.dart';

final ThemeData kIOSTheme = new ThemeData(brightness: Brightness.dark);

void main() => runApp(new MaterialApp(
      home: LucidApp(),
      theme: kIOSTheme,
    ));

class LucidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 40, bottom: 48),
            child: Center(
              child: Text(
                'Welcome to the Lucid Dreams',
                style: TextStyle(fontSize: 20, color: Colors.greenAccent),
              ),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Notification Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationSettings()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Notification Statistics'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => NotificationStatistics.withSampleData()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
