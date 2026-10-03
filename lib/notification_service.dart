
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
static final FlutterLocalNotificationsPlugin notifications =
FlutterLocalNotificationsPlugin();

// =========================
// INITIALIZE
// =========================

static Future<void> initialize() async {
tz.initializeTimeZones();

const AndroidInitializationSettings androidSettings =
AndroidInitializationSettings('@mipmap/ic_launcher');

const InitializationSettings settings = InitializationSettings(
android: androidSettings,
);

await notifications.initialize(
settings: settings,
onDidReceiveNotificationResponse: (response) {},
);

final android = notifications
    .resolvePlatformSpecificImplementation<
AndroidFlutterLocalNotificationsPlugin>();

// Notification permission
final before = await android?.areNotificationsEnabled();
print("NOTIFICATION BEFORE: $before");

final notificationPermission =
await android?.requestNotificationsPermission();

print("NOTIFICATION PERMISSION RESULT: $notificationPermission");

final after = await android?.areNotificationsEnabled();
print("NOTIFICATION AFTER: $after");

// Exact alarm permission
final exactAlarmPermission =
await android?.requestExactAlarmsPermission();

print("EXACT ALARM PERMISSION RESULT: $exactAlarmPermission");
}

// =========================
// SCHEDULE REMINDER
// =========================

static Future<void> sheduleReminder({
required int hour,
required int minute,
required String repeatType,
required Set<String> selecteddays,
}) async {
// Purane reminders cancel
await notifications.cancelAll();

if (repeatType == "Every Day") {
await _scheduleDaily(
hour: hour,
minute: minute,
);
} else {
for (String day in selecteddays) {
await _scheduleSelectedDay(
day: day,
hour: hour,
minute: minute,
);
}
}
}

// =========================
// EVERY DAY
// =========================

static Future<void> _scheduleDaily({
required int hour,
required int minute,
}) async {
final now = tz.TZDateTime.now(tz.local);

var scheduled = tz.TZDateTime(
tz.local,
now.year,
now.month,
now.day,
hour,
minute,
);

if (scheduled.isBefore(now)) {
scheduled = scheduled.add(
const Duration(days: 1),
);
}

await notifications.zonedSchedule(
id: 100,
title: "Attendance Reminder",
body: "Don't forget to mark today's Attendance",
scheduledDate: scheduled,
notificationDetails: const NotificationDetails(
android: AndroidNotificationDetails(
'attendance_reminder',
'Attendance Reminders',
channelDescription: 'Reminders for marking attendance',
importance: Importance.high,
priority: Priority.high,
),
),
androidScheduleMode:
AndroidScheduleMode.exactAllowWhileIdle,
matchDateTimeComponents:
DateTimeComponents.time,
);

print("DAILY REMINDER SCHEDULED: $scheduled");
}

// =========================
// SELECTED DAYS
// =========================

static Future<void> _scheduleSelectedDay({
required String day,
required int hour,
required int minute,
}) async {
final now = tz.TZDateTime.now(tz.local);

final weekdays = {
"Mon": DateTime.monday,
"Tue": DateTime.tuesday,
"Wed": DateTime.wednesday,
"Thur": DateTime.thursday,
"Fri": DateTime.friday,
"Sat": DateTime.saturday,
"Sun": DateTime.sunday,
};

final targetDays = weekdays[day]!;

var scheduled = tz.TZDateTime(
tz.local,
now.year,
now.month,
now.day,
hour,
minute,
);

while (
scheduled.weekday != targetDays ||
scheduled.isBefore(now)) {
scheduled = scheduled.add(
const Duration(days: 1),
);
}

await notifications.zonedSchedule(
id: 200 + targetDays,
title: "Attendance Reminder",
body: "Don't forget to mark today's Attendance",
scheduledDate: scheduled,
notificationDetails: const NotificationDetails(
android: AndroidNotificationDetails(
'attendance_reminder',
'Attendance Reminders',
channelDescription:
"Reminders for making attendance.",
importance: Importance.high,
priority: Priority.high,
),
),
androidScheduleMode:
AndroidScheduleMode.exactAllowWhileIdle,
matchDateTimeComponents:
DateTimeComponents.dayOfWeekAndTime,
);

print("SELECTED DAY REMINDER SCHEDULED: $day - $scheduled");
}

// =========================
// CANCEL
// =========================

static Future<void> cancelReminders() async {
await notifications.cancelAll();
print("ALL REMINDERS CANCELLED");
}
}