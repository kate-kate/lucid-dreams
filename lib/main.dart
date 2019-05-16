import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ThemeData kIOSTheme = new ThemeData(brightness: Brightness.dark);

void main() => runApp(new MaterialApp(
      home: LucidApp(),
      theme: kIOSTheme,
    ));

class LucidApp extends StatefulWidget {
  @override
  _LucidAppState createState() {
    return _LucidAppState();
  }
}

class _LucidAppState extends State {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  bool switchEnabled = false;
  int fromHour;
  int fromMinute;
  int toHour;
  int toMinute;
  int repeatPeriodsNumber;
  String notificationText = '';

  final _formKey = GlobalKey<FormState>();
  List<String> timeList = new List<String>();

  TextEditingController fromController;
  TextEditingController toController;
  TextEditingController repeatController;
  TextEditingController notifTextController;

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      new AndroidNotificationDetails('repeatDailyAtTime channel id',
          'repeatDailyAtTime channel name', 'repeatDailyAtTime description');
  IOSNotificationDetails iOSPlatformChannelSpecifics =
      new IOSNotificationDetails();
  NotificationDetails platformChannelSpecifics;

  @override
  void initState() {
    super.initState();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('lucid');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

    _loadPreferences();
    platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      switchEnabled = prefs.getBool('lucidNotificationsEnabled') != null
          ? prefs.getBool('lucidNotificationsEnabled')
          : false;
      fromHour = prefs.getInt('lucidFromHour');
      fromMinute = prefs.getInt('lucidFromMinute');
      toHour = prefs.getInt('lucidToHour');
      toMinute = prefs.getInt('lucidToMinute');
      repeatPeriodsNumber = prefs.getInt('lucidRepeatNumber') != null
          ? prefs.getInt('lucidRepeatNumber')
          : 0;
      notificationText = prefs.getString('lucidNotificationText') != null
          ? prefs.getString('lucidNotificationText')
          : 'Reality check';
    });

    await _generateTimeList(
        fromHour, fromMinute, toHour, toMinute, repeatPeriodsNumber, false);

    var fromText = (fromHour != null && fromMinute != null)
        ? getFromattedTimeString(fromHour, fromMinute)
        : '';

    fromController = TextEditingController(text: fromText);
    var toText = (toHour != null && toMinute != null)
        ? getFromattedTimeString(toHour, toMinute)
        : '';
    toController = TextEditingController(text: toText);
    repeatController =
        TextEditingController(text: repeatPeriodsNumber.toString());
    notifTextController = TextEditingController(text: notificationText);
  }

  void switchNotification(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchEnabled = value;
      prefs.setBool('lucidNotificationsEnabled', value);
    });
  }

  void setFromTime(String fromTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var timeArray = fromTime.split(':');
      fromHour = int.parse(timeArray[0]);
      fromMinute = int.parse(timeArray[1]);
      prefs.setInt('lucidFromHour', fromHour);
      prefs.setInt('lucidFromMinute', fromMinute);
    });
  }

  void setToTime(String toTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      var timeArray = toTime.split(':');
      toHour = int.parse(timeArray[0]);
      toMinute = int.parse(timeArray[1]);
      prefs.setInt('lucidToHour', toHour);
      prefs.setInt('lucidToMinute', toMinute);
    });
  }

  void setRepeatNumber(String repeatNumberInput) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      repeatPeriodsNumber =
          repeatNumberInput != '' ? int.parse(repeatNumberInput) : 0;
      prefs.setInt('lucidRepeatNumber', repeatPeriodsNumber);
    });
  }

  void setNotificationText(String notifText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationText = notifText;
      prefs.setString('lucidNotificationText', notificationText);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    fromController.dispose();
    toController.dispose();
    repeatController.dispose();
    notifTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to the Lucid Dreams'),
        textTheme: TextTheme(
            title: TextStyle(color: Colors.greenAccent, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 16, left: 4, right: 4),
              child: SwitchListTile(
                value: switchEnabled,
                onChanged: enableNotification,
                title: Text("Enable notification"),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration:
                        new InputDecoration(labelText: "First alert time"),
                    validator: validateTime,
                    controller: fromController,
                  ),
                  TextFormField(
                    decoration:
                        new InputDecoration(labelText: "Last alert time"),
                    validator: validateTime,
                    controller: toController,
                  ),
                  TextFormField(
                    decoration: new InputDecoration(
                        labelText: "How many times to repeat"),
                    controller: repeatController,
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter how many notifications you want to get daily';
                      }
                      var parsedValue = int.tryParse(value) ?? 0;
                      if (parsedValue <= 0) {
                        return 'Invalid number';
                      }
                      if (parsedValue > 60) {
                        return '60 notifications is maximum';
                      }
                      if (getInterval(parsedValue) == 0) {
                        return 'You want to get notifications too often:)';
                      }
                    },
                  ),
                  TextFormField(
                    decoration:
                        new InputDecoration(labelText: "Notification text"),
                    controller: notifTextController,
                    validator: (String value) {
                      if (value == '') {
                        return 'Please enter a notification text';
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 36),
                    child: RaisedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setFromTime(fromController.text);
                          setToTime(toController.text);
                          setRepeatNumber(repeatController.text);
                          setNotificationText(notifTextController.text);
                          enableNotification(true);
                        }
                      },
                      child: Text('Save'),
                      color: Colors.purpleAccent,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(switchEnabled && repeatPeriodsNumber > 0
                        ? 'You will get notifications at:'
                        : 'You decided to never get notifications'),
                  ),
                  Container(
                    child: Text(timeList.map((time) => time).join(', ')),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future onSelectNotification(String payload) async {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              title: Text('Here is payload'),
              content: Text("Payload: $payload"),
            ));
  }

  String validateTime(String inputValue) {
    var timeArray = inputValue.split(':');
    if (timeArray.length < 2 || timeArray[1] == '') {
      return 'Invalid time format';
    }
    var fromHourVal = int.tryParse(timeArray[0]) ?? -1;
    if (fromHourVal > 23 || fromHourVal < 0) {
      return 'Invalid hour value';
    }
    var fromMinuteVal = int.tryParse(timeArray[1]) ?? -1;
    if (fromMinuteVal > 59 || fromMinuteVal < 0) {
      return 'Invalid minute value';
    }
    return null;
  }

  Future enableNotification(switchValue) async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("I cancelled all!!!");
    switchNotification(switchValue);
    if (switchValue) {
      if (repeatPeriodsNumber == 0) {
        switchNotification(false);
      } else {
        await _generateTimeList(
            fromHour, fromMinute, toHour, toMinute, repeatPeriodsNumber, true);
      }
    }
  }

  Future _generateTimeList(int startHour, int startMinute, int endHour,
      int endMinute, int repeatNumber, bool addNotifications) async {
    var notificationList = new List<String>();

    if (fromHour != null &&
        fromMinute != null &&
        toHour != null &&
        toMinute != null &&
        repeatNumber > 0) {
      if (repeatNumber == 1) {
        await addNotification(
            0, fromHour, fromMinute, notificationList, addNotifications);
      } else if (repeatNumber == 2) {
        await addNotification(
            0, fromHour, fromMinute, notificationList, addNotifications);
        await addNotification(
            1, toHour, toMinute, notificationList, addNotifications);
      } else {
        
        var intervalNumber = getInterval(repeatNumber);
        var hour = fromHour;
        var minute = fromMinute;

        for (var counter = 0; counter < repeatNumber; counter++) {
          if (counter == 0) {
            await addNotification(
                counter, hour, minute, notificationList, addNotifications);
          } else {
            minute += intervalNumber;
            if (minute >= 60) {
              for (; minute >= 60; minute -= 60) {
                hour++;
              }
            }

            if ((hour == toHour &&
                    (minute > toMinute ||
                        toMinute - minute < intervalNumber)) ||
                (hour > toHour)) {
              await addNotification(counter, toHour, toMinute, notificationList,
                  addNotifications);
            } else {
              await addNotification(
                  counter, hour, minute, notificationList, addNotifications);
            }
          }
        }
      }
    }

    setState(() {
      timeList = notificationList;
    });
  }

  Future addNotification(int id, int hour, int minute, List<String> notifList,
      bool createEvent) async {
    notifList.add(getFromattedTimeString(hour, minute));
    if (createEvent) {
      await flutterLocalNotificationsPlugin.showDailyAtTime(
          id,
          'Lucid Dreams',
          notificationText,
          new Time(hour, minute, 0),
          platformChannelSpecifics);
    }
  }

  String formatMinute(int minute) {
    if (minute < 10) {
      return "0" + minute.toString();
    }
    return minute.toString();
  }

  String getFromattedTimeString(int hour, int minute) {
    return hour.toString() + ":" + formatMinute(minute);
  }

  int getInterval(int repeatPeriodsNum) {
    var totalMinutes = (toHour - fromHour - 1) * 60 + (60 - fromMinute) + toMinute;
    return (totalMinutes / (repeatPeriodsNum - 1)).floor();
  }
}
