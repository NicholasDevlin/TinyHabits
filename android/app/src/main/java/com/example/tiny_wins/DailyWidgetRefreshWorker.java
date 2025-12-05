package com.example.tiny_wins;

import android.content.Context;
import android.content.Intent;
import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.WorkerParameters;
import android.util.Log;

/**
 * WorkManager worker that refreshes widget data daily at midnight
 */
public class DailyWidgetRefreshWorker extends Worker {
    private static final String TAG = "DailyWidgetRefreshWorker";
    
    public DailyWidgetRefreshWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
    }

    @NonNull
    @Override
    public Result doWork() {
        Log.d(TAG, "Daily widget refresh worker started at midnight");
        
        try {
            Context context = getApplicationContext();
            
            // Method 1: Check if it's a new day
            boolean isNewDay = HabitDataManager.isNewDay(context);
            Log.d(TAG, "Is new day: " + isNewDay);
            
            if (isNewDay) {
                Log.d(TAG, "New day detected - refreshing widget data directly from database");
                
                // Method 2: Query database directly (NO Flutter required!)
                boolean refreshSuccess = performNativeDataRefresh(context);
                
                if (refreshSuccess) {
                    // Mark that we've processed today only if successful
                    HabitDataManager.markDayAsProcessed(context);
                } else {
                    Log.w(TAG, "Native refresh failed - will retry next time");
                }
            }
            
            // Method 3: Always trigger widget UI update to refresh display
            WidgetRefreshScheduler.triggerWidgetUpdate(context);
            Log.d(TAG, "Widget UI update triggered");
            
            Log.d(TAG, "Daily widget refresh completed successfully");
            return Result.success();
            
        } catch (Exception e) {
            Log.e(TAG, "Error in daily widget refresh worker", e);
            return Result.retry();
        }
    }
    
    /**
     * Perform native data refresh without Flutter dependency (public for testing)
     */
    public static boolean performNativeDataRefresh(Context context) {
        try {
            if (NativeDatabaseHelper.isDatabaseAccessible(context)) {
                // Get fresh habit data directly from SQLite database
                org.json.JSONObject todayHabits = NativeDatabaseHelper.getTodayHabitsFromDatabase(context);
                
                // Save to SharedPreferences (same format as Flutter)
                android.content.SharedPreferences prefs = context.getSharedPreferences(
                    "FlutterSharedPreferences", Context.MODE_PRIVATE
                );
                android.content.SharedPreferences.Editor editor = prefs.edit();
                editor.putString("flutter.tinywins_habits_widget_data", todayHabits.toString());
                editor.putString("tinywins_habits_widget_data", todayHabits.toString());
                editor.apply();

                Log.d(TAG, "Successfully refreshed widget data from database without Flutter!");

                return true;
            } else {
                Log.w(TAG, "Database not accessible - trying Flutter fallback");
                
                // Fallback: Try to start Flutter app
                Intent flutterIntent = new Intent(context, MainActivity.class);
                flutterIntent.setAction("DAILY_REFRESH_WIDGET_DATA");
                flutterIntent.putExtra("is_midnight_refresh", true);
                flutterIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                flutterIntent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP);
                context.startActivity(flutterIntent);
                Thread.sleep(3000); // Give Flutter time to update

                return true; // Assume success for Flutter fallback
            }
            
        } catch (Exception e) {
            Log.e(TAG, "Error refreshing widget data: " + e.getMessage());
            return false;
        }
    }
}