import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/notification.dart' as model;
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/utils/color.dart';
import 'package:instagram_clone/widgets/base_gradient_indicator.dart';
import 'package:instagram_clone/widgets/notification_card.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with AutomaticKeepAliveClientMixin<NotificationsScreen> {
  Stream<QuerySnapshot<Map<String, dynamic>>>? _stream;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    User? user = Provider.of<UserProvider>(context).getUser;
    if (user != null && _stream == null) {
      _stream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .orderBy('datePublished', descending: true)
          .snapshots();
    }

    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          shadowColor: Colors.grey,
          title: Text('Notifications'),
          backgroundColor: mobileBgColor,
          centerTitle: false,
        ),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _stream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No New Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18
                    ),
                  ),
                );
              }
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: ((context, index) {
                  model.Notification notification = model.Notification.fromMap(
                      snapshot.data!.docs[index].data());
                  return NotificationCard(notification: notification, currentUser: user!,);
                }),
              );
            }
            return BaseGradientIndicator();
          },
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
