package com.example.tiny_wins;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Manages habit data operations directly from native Android side
 * This allows widgets to refresh even when Flutter app is not running
 */
public class HabitDataManager {
    private static final String TAG = "HabitDataManager";
    private static final String PREFS_NAME = "FlutterSharedPreferences";
    private static final String WIDGET_DATA_KEY = "flutter.tinywins_habits_widget_data";
    private static final String LAST_RESET_DATE_KEY = "flutter.last_habit_reset_date";

    /**
     * Check if it's a new day (without clearing any data)
     */
    public static boolean isNewDay(Context context) {
        try {
            SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            String currentDate = getCurrentDateString();
            String lastProcessedDate = prefs.getString(LAST_RESET_DATE_KEY, "");

            Log.d(TAG, "Current date: " + currentDate + ", Last processed: " + lastProcessedDate);

            return !currentDate.equals(lastProcessedDate);
        } catch (Exception e) {
            Log.e(TAG, "Error checking if new day", e);
            return false;
        }
    }

    /**
     * Mark the current day as processed (don't run refresh again today)
     */
    public static void markDayAsProcessed(Context context) {
        try {
            SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
            String currentDate = getCurrentDateString();

            SharedPreferences.Editor editor = prefs.edit();
            editor.putString(LAST_RESET_DATE_KEY, currentDate);
            editor.apply();

            Log.d(TAG, "Marked day as processed: " + currentDate);
        } catch (Exception e) {
            Log.e(TAG, "Error marking day as processed", e);
        }
    }

    /**
     * Get current date as string in YYYY-MM-DD format
     */
    private static String getCurrentDateString() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        return sdf.format(new Date());
    }
}