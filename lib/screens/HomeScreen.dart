import 'package:flutter/material.dart';
import '../managers/LocalNotifyManager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();
    localNotifyManager.setOnNotificationReceived(onNotificationReceive);
    localNotifyManager.setOnNotificationClicked(onNotificationClick);
  }

  onNotificationReceive(ReceivedNotification notification) {
    print('Notification received: ${notification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: TextButton(
          onPressed: () async {
            await localNotifyManager.showNotification();
          },
          child: Container(
            decoration: new BoxDecoration(
              color: Colors.redAccent,
              borderRadius: new BorderRadius.circular(8)
            ),
            padding: EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: Text(
              'Send Notification',
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: Colors.white)
            )
          ),
        ),
      ),
    );
  }
}

