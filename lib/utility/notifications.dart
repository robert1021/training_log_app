import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:training_log_app/db/database_helper.dart';

class WorkoutNotification {
  static Future<void> createWorkoutNotification(
      int reminderId, int weekday, int hour, int minute) async {
    // Get reminder from db
    var reminder =
        (await DatabaseHelper.instance.getSpecificReminder(reminderId))[0];

    var body = 'Time to pump some iron!';
    // Check if notes have anything
    if (reminder.notes != null) {
      body = '${reminder.notes}';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reminderId, // if not unique only one notification can be displayed
        channelKey: 'key1',
        title: '${Emojis.smile_smiling_face_with_sunglasses} Workout reminder!',
        body: body,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_DONE',
          label: 'Mark Done',
        ),
      ],
      schedule: NotificationCalendar(
        weekday: weekday,
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
  }

  static Future<void> createWorkoutNotificationCron(
      int reminderId, String weekdays, int hour, int minute) async {
    // Get reminder from db
    var reminder =
        (await DatabaseHelper.instance.getSpecificReminder(reminderId))[0];

    var body = 'Time to pump some iron!';
    // Check if notes have anything
    if (reminder.notes != null) {
      body = '${reminder.notes}';
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: reminderId, // if not unique only one notification can be displayed
        channelKey: 'key1',
        title: '${Emojis.smile_smiling_face_with_sunglasses} Workout reminder!',
        body: body,

        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_DONE',
          label: 'Mark Done',
        ),
      ],
      schedule: NotificationAndroidCrontab(
        repeats: true,
        crontabExpression: '0 $minute $hour ? * $weekdays *',
      ),
    );
  }

  // cancels specific notification using reminder/notification id
  static void cancelNotification(int reminderId) async {
    await AwesomeNotifications().cancelSchedule(reminderId);
    await AwesomeNotifications().cancel(reminderId);
  }

  // cancels all notifications using reminder/notification id
  static void cancelAllNotifications() async {
    await AwesomeNotifications().cancelAllSchedules();
    await AwesomeNotifications().cancelAll();
  }
}
