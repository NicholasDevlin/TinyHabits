package com.example.tiny_wins;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.work.ExistingWorkPolicy;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import java.util.Calendar;
import java.util.concurrent.TimeUnit;

/**
 * Manages scheduling of daily widget refresh using AlarmManager and WorkManager
 */
public class WidgetRefreshScheduler {
    private static final String TAG = "WidgetRefreshScheduler";
    private static final String DAILY_REFRESH_ACTION = "com.example.tiny_wins.DAILY_WIDGET_REFRESH";
    private static final String WORK_TAG = "daily_widget_refresh";
    private static final int ALARM_REQUEST_CODE = 12345;

    /**
     * Schedule daily widget refresh at midnight
     */
    public static void scheduleDailyRefresh(Context context) {
        try {
            AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
            if (alarmManager == null) {
                Log.e(TAG, "AlarmManager not available");
                return;
            }

            Intent intent = new Intent(context, DailyRefreshReceiver.class);
            intent.setAction(DAILY_REFRESH_ACTION);

            PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                ALARM_REQUEST_CODE,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE // Ensures not creating multiple pendingIntent
            );

            // Calculate next midnight
            Calendar calendar = Calendar.getInstance();
            calendar.add(Calendar.DAY_OF_MONTH, 1); // Next day
            calendar.set(Calendar.HOUR_OF_DAY, 0);  // Midnight
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);

            long triggerAtMillis = calendar.getTimeInMillis();

            // Use setExactAndAllowWhileIdle for better reliability on modern Android
            // This helps bypass Doze mode and battery optimization
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, // real-time clock
                    triggerAtMillis,
                    pendingIntent
                );
                Log.d(TAG, "Scheduled exact alarm with Doze bypass for midnight");
            } else {
                // Fallback for older Android versions
                alarmManager.setExact(
                    AlarmManager.RTC_WAKEUP,
                    triggerAtMillis,
                    pendingIntent
                );
                Log.d(TAG, "Scheduled exact alarm for midnight");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error scheduling daily refresh", e);
        }
    }

    /**
     * Trigger immediate widget refresh work
     */
    public static void triggerRefreshWork(Context context) {
        try {
            OneTimeWorkRequest refreshWork = new OneTimeWorkRequest.Builder(DailyWidgetRefreshWorker.class)
                .addTag(WORK_TAG)
                .setInitialDelay(0, TimeUnit.SECONDS)
                .build();

            WorkManager.getInstance(context).enqueueUniqueWork(
                WORK_TAG,
                ExistingWorkPolicy.REPLACE,
                refreshWork
            );

            Log.d(TAG, "Widget refresh work triggered");
        } catch (Exception e) {
            Log.e(TAG, "Error triggering refresh work", e);
        }
    }

    /**
     * Trigger immediate widget UI update
     */
    public static void triggerWidgetUpdate(Context context) {
        try {
            AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
            ComponentName componentName = new ComponentName(context, HabitWidgetProvider.class);
            int[] appWidgetIds = appWidgetManager.getAppWidgetIds(componentName);

            if (appWidgetIds.length > 0) {
                Intent updateIntent = new Intent(context, HabitWidgetProvider.class);
                updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
                updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds);
                context.sendBroadcast(updateIntent);

                Log.d(TAG, "Widget update broadcast sent for " + appWidgetIds.length + " widgets");
            }
        } catch (Exception e) {
            Log.e(TAG, "Error triggering widget update", e);
        }
    }

    /**
     * BroadcastReceiver that receives the alarm and triggers the WorkManager task
     */
    public static class DailyRefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (DAILY_REFRESH_ACTION.equals(intent.getAction())) {
                Log.d(TAG, "Daily refresh alarm received at midnight");

                // Trigger the refresh work
                triggerRefreshWork(context);

                // Reschedule for tomorrow's midnight (since we're not using setRepeating)
                scheduleDailyRefresh(context);
                Log.d(TAG, "Rescheduled next daily refresh for tomorrow");
            }
        }
    }

    /**
     * BroadcastReceiver that reschedules alarms after device reboot
     */
    public static class BootReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (Intent.ACTION_BOOT_COMPLETED.equals(action) || Intent.ACTION_MY_PACKAGE_REPLACED.equals(action)) {
                Log.d(TAG, "Device rebooted or app updated - rescheduling daily refresh");

                // Check if we have any widgets active before scheduling
                AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
                ComponentName componentName = new ComponentName(context, HabitWidgetProvider.class);
                int[] appWidgetIds = appWidgetManager.getAppWidgetIds(componentName);

                if (appWidgetIds.length > 0) {
                    scheduleDailyRefresh(context);
                    Log.d(TAG, "Rescheduled daily refresh for " + appWidgetIds.length + " active widgets");
                } else {
                    Log.d(TAG, "No active widgets found - skipping schedule");
                }
            }
        }
    }
}