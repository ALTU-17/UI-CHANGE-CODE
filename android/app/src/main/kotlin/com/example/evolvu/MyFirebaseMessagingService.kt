//package in.aceventura.evolvuschool
//
//import android.app.NotificationChannel
//import android.app.NotificationManager
//import android.app.PendingIntent
//import android.content.Context
//import android.content.Intent
//import android.os.Build
//import android.util.Log
//import android.widget.RemoteViews
//import androidx.core.app.NotificationCompat
//import com.google.firebase.messaging.FirebaseMessagingService
//import com.google.firebase.messaging.RemoteMessage
//import org.json.JSONObject
//import `in.aceventura.evolvuschool.ParentDashboard`
//import `in.aceventura.evolvuschool.R`
//import `in.aceventura.evolvuschool.SharedPrefManager`
//import `in.aceventura.evolvuschool.utils.FirebaseNotificationUtils`
//
//class MyFirebaseMessagingService : FirebaseMessagingService() {
//
//    companion object {
//        private const val TAG = "FCMService"
//        private const val CHANNEL_ID = "fcm_channel"
//    }
//
//    override fun onMessageReceived(remoteMessage: RemoteMessage) {
//        Log.d(TAG, "From: ${remoteMessage.from}")
//
//        Log.e("LOL>", "Notification Title: ${remoteMessage.notification?.title}")
//        Log.e("LOL>", "Notification Data: ${remoteMessage.data}")
//
//        try {
//            val stringJson = JSONObject(remoteMessage.data.toString())
//            val values = stringJson.getString("activity")
//
//            Log.e("flags", "values?? ${SharedPrefManager.getInstance(applicationContext).activityName}")
//            SharedPrefManager.getInstance(applicationContext).activityName = values
//
//            when (values) {
//                "remark" -> {
//                    FirebaseNotificationUtils.Remarkremark_id = stringJson.getString("remark_id")
//                    FirebaseNotificationUtils.Remarkstud_id = stringJson.getString("stud_id")
//                    FirebaseNotificationUtils.Remarksection_id = stringJson.getString("section_id")
//                    FirebaseNotificationUtils.Remarkclass_id = stringJson.getString("class_id")
//                    FirebaseNotificationUtils.Remarkparent_id = stringJson.getString("parent_id")
//                }
//                "homework" -> {
//                    FirebaseNotificationUtils.HomeWorkhomework_id = stringJson.getString("homework_id")
//                    FirebaseNotificationUtils.HomeWorkstud_id = stringJson.getString("stud_id")
//                    FirebaseNotificationUtils.HomeWorksection_id = stringJson.getString("section_id")
//                    FirebaseNotificationUtils.HomeWorkclass_id = stringJson.getString("class_id")
//                    FirebaseNotificationUtils.HomeWorkparent_id = stringJson.getString("parent_id")
//                }
//                "note" -> {
//                    FirebaseNotificationUtils.Notenotes_id = stringJson.getString("notes_id")
//                    FirebaseNotificationUtils.Notestud_id = stringJson.getString("stud_id")
//                    FirebaseNotificationUtils.Notesection_id = stringJson.getString("section_id")
//                    FirebaseNotificationUtils.Noteclass_id = stringJson.getString("class_id")
//                    FirebaseNotificationUtils.Noteparent_id = stringJson.getString("parent_id")
//                }
//                "notice" -> {
//                    FirebaseNotificationUtils.Noticenotice_id = stringJson.getString("notice_id")
//                    FirebaseNotificationUtils.Noticestud_id = stringJson.getString("stud_id")
//                    FirebaseNotificationUtils.Noticesection_id = stringJson.getString("section_id")
//                    FirebaseNotificationUtils.Noticeclass_id = stringJson.getString("class_id")
//                    FirebaseNotificationUtils.Noticeparent_id = stringJson.getString("parent_id")
//                }
//            }
//        } catch (e: Exception) {
//            Log.e("JsonValue", "Error: ${e.message}")
//        }
//
//        if (remoteMessage.data.isNotEmpty()) {
//            Log.d(TAG, "Message data payload: ${remoteMessage.data}")
//            sendNotification(remoteMessage.notification?.title, remoteMessage.notification?.body)
//        }
//
//        remoteMessage.notification?.let {
//            Log.d(TAG, "Message Notification Body: ${it.body}")
//            sendNotification(it.title, it.body)
//        }
//    }
//
//    override fun onNewToken(token: String) {
//        Log.d(TAG, "Refreshed token: $token")
//    }
//
//    private fun sendNotification(title: String?, message: String?) {
//        val intent = Intent(this, ParentDashboard::class.java)
//        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
//        val pendingIntent = PendingIntent.getActivity(
//            this, 0, intent,
//            PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
//        )
//
//        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
//            .setSmallIcon(R.drawable.icon)
//            .setContent(getCustomDesign(title, message))
//            .setAutoCancel(true)
//            .setContentIntent(pendingIntent)
//
//        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(
//                CHANNEL_ID, "FCM Notifications", NotificationManager.IMPORTANCE_DEFAULT
//            )
//            notificationManager.createNotificationChannel(channel)
//        }
//
//        notificationManager.notify(0, notificationBuilder.build())
//    }
//
//    private fun getCustomDesign(title: String?, message: String?): RemoteViews {
//        val remoteViews = RemoteViews(packageName, R.layout.notification)
//        remoteViews.setTextViewText(R.id.title, title)
//        remoteViews.setTextViewText(R.id.message, message)
//        remoteViews.setImageViewResource(R.id.icon, R.drawable.icon)
//        return remoteViews
//    }
//}
