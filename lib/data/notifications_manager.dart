import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:fyp_driver/data/resources.dart';

class NotificationsManager {
  static init() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'driver_channel_group',
          channelKey: 'driver_channel',
          channelName: 'driver_notifications',
          channelDescription: 'High passenger request density',
          enableVibration: true,
          onlyAlertOnce: true,
          enableLights: true,
          importance: NotificationImportance.High,
          playSound: true,
          vibrationPattern: highVibrationPattern,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'driver_channel_group',
          channelGroupName: 'driver_group',
        ),
      ],

      /// you might have to come back here later, I'm not sure if this is how it is supposed to be
      debug: true,
    );
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationsManager.onActionReceivedMethod,
    );
  }

  static void showNotification({required String title, required String body}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'driver_channel',
        title: title,
        body: body,
        criticalAlert: true,
        wakeUpScreen: true,
        showWhen: true,
        autoDismissible: false,
        displayOnForeground: true,
        displayOnBackground: true,
        fullScreenIntent: true,
        backgroundColor: Colors.grey,
        notificationLayout: NotificationLayout.BigText,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'accept_button',
          label: 'ACCEPT',
        ),
        NotificationActionButton(
          key: 'reject_button',
          label: 'REJECT',
          isDangerousOption: true,
        ),
      ],
    );
  }

  /// This seems to work so far
  /// You may need to use some ValueNotifiers to update respective parts of the UI accordingly
  //TODO: If driver presses reject button, the controller should get the notification that it was
  //TODO rejected, and they should assign it to another driver
  //TODO: The isAccepted field in the database should remain false
  //TODO: If the a driver accepts the request, the isAccepted field of the respective document in
  //TODO the database should update to true, as they will be used later
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    switch (receivedAction.buttonKeyPressed) {
      case 'accept_button':
        firestoreManager.saveResponse(isAccepted: true);
        log('----------ACCEPT_BUTTON IS PRESSED');
        break;
      case 'reject_button':
        firestoreManager.saveResponse();
        log('----------REJECT_BUTTON IS PRESSED');
        break;
    }
  }
}
