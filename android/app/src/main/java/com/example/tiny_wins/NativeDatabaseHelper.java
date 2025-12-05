package com.example.tiny_wins;

import android.content.Context;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.util.Log;
import org.json.JSONArray;
import org.json.JSONObject;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Native Android helper to access Flutter's SQLite database directly
 * This allows widget refresh without requiring Flutter to be running
 */
public class NativeDatabaseHelper {
    private static final String TAG = "NativeDatabaseHelper";
    private static final String DB_NAME = "tiny_wins.db";

    /**
     * Get today's habits directly from SQLite database (without Flutter)
     */
    public static JSONObject getTodayHabitsFromDatabase(Context context) {
        JSONObject result = new JSONObject();

        try {
            // Find the database file (Flutter stores it in app's documents directory)
            File dbFile = getDatabaseFile(context);
            if (!dbFile.exists()) {
                Log.w(TAG, "Database file not found: " + dbFile.getPath());
                return createEmptyResult();
            }

            SQLiteDatabase db = SQLiteDatabase.openDatabase(
                dbFile.getPath(), 
                null, 
                SQLiteDatabase.OPEN_READONLY
            );

            // Get today's weekday (1=Monday, 7=Sunday)
            Calendar calendar = Calendar.getInstance();
            int todayWeekday = calendar.get(Calendar.DAY_OF_WEEK);
            // Convert to Flutter's weekday format (1=Monday, 7=Sunday)
            int flutterWeekday = (todayWeekday == Calendar.SUNDAY) ? 7 : todayWeekday - 1;

            // Get today's date for completion check
            String todayDate = getTodayDateString();

            // Query habits that should be active today
            String habitsQuery = "SELECT id, title, description, reminder_time, target_days FROM habits_table";
            Cursor habitsCursor = db.rawQuery(habitsQuery, null);

            JSONArray habitsArray = new JSONArray();
            int completedCount = 0;

            while (habitsCursor.moveToNext()) {
                int habitId = habitsCursor.getInt(0);
                String title = habitsCursor.getString(1);
                String reminderTime = habitsCursor.getString(3);
                String targetDays = habitsCursor.getString(4);

                // Check if habit is scheduled for today
                if (isHabitActiveToday(targetDays, flutterWeekday)) {
                    // Check if habit is completed today
                    boolean isCompleted = isHabitCompletedToday(db, habitId, todayDate);
                    
                    JSONObject habit = new JSONObject();
                    habit.put("id", habitId);
                    habit.put("title", title);
                    habit.put("isCompletedToday", isCompleted);
                    
                    habitsArray.put(habit);
                    
                    if (isCompleted) {
                        completedCount++;
                    }
                    
                    Log.d(TAG, "Habit: " + title + " (completed: " + isCompleted + ")");
                }
            }

            habitsCursor.close();
            db.close();

            // Build result JSON
            result.put("habits", habitsArray);
            result.put("totalHabits", habitsArray.length());
            result.put("completedHabits", completedCount);
            result.put("lastUpdated", new Date().toString());

            Log.d(TAG, "Successfully queried " + habitsArray.length() + " habits for today (" + completedCount + " completed)");
            
        } catch (Exception e) {
            Log.e(TAG, "Error querying database", e);
            return createEmptyResult();
        }

        return result;
    }

    private static File getDatabaseFile(Context context) {
        // Flutter stores database in app's documents directory
        File documentsDir = new File(context.getFilesDir().getParent() + "/app_flutter/");
        File dbFile = new File(documentsDir, DB_NAME);

        // If not found, try alternative locations
        if (!dbFile.exists()) {
            // Try in files directory
            dbFile = new File(context.getFilesDir(), DB_NAME);
        }

        if (!dbFile.exists()) {
            // Try in databases directory
            File databasesDir = context.getDatabasePath("dummy").getParentFile();
            dbFile = new File(databasesDir, DB_NAME);
        }

        Log.d(TAG, "Database file path: " + dbFile.getPath() + " (exists: " + dbFile.exists() + ")");
        return dbFile;
    }

    private static boolean isHabitActiveToday(String targetDays, int todayWeekday) {
        if (targetDays == null || targetDays.isEmpty()) {
            return false;
        }

        String[] days = targetDays.split(",");
        for (String day : days) {
            try {
                int dayNum = Integer.parseInt(day.trim());
                if (dayNum == todayWeekday) {
                    return true;
                }
            } catch (NumberFormatException e) {
                Log.w(TAG, "Invalid day format: " + day);
            }
        }
        return false;
    }

    private static boolean isHabitCompletedToday(SQLiteDatabase db, int habitId, String todayDate) {
        try {
            // Query habit_entries_table for today's completion
            String query = "SELECT is_completed FROM habit_entries_table WHERE habit_id = ? AND date(date) = ?";
            Cursor cursor = db.rawQuery(query, new String[]{String.valueOf(habitId), todayDate});

            boolean isCompleted = false;
            if (cursor.moveToFirst()) {
                isCompleted = cursor.getInt(0) == 1;
            }

            cursor.close();
            return isCompleted;
        } catch (Exception e) {
            Log.e(TAG, "Error checking completion for habit " + habitId, e);
            return false;
        }
    }

    private static String getTodayDateString() {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault());
        return sdf.format(new Date());
    }

    private static JSONObject createEmptyResult() {
        try {
            JSONObject result = new JSONObject();
            result.put("habits", new JSONArray());
            result.put("totalHabits", 0);
            result.put("completedHabits", 0);
            result.put("lastUpdated", new Date().toString());
            return result;
        } catch (Exception e) {
            Log.e(TAG, "Error creating empty result", e);
            return new JSONObject();
        }
    }

    /**
     * Check if database exists and is accessible
     */
    public static boolean isDatabaseAccessible(Context context) {
        try {
            File dbFile = getDatabaseFile(context);
            if (!dbFile.exists()) {
                return false;
            }

            SQLiteDatabase db = SQLiteDatabase.openDatabase(
                dbFile.getPath(), 
                null, 
                SQLiteDatabase.OPEN_READONLY
            );

            // Try a simple query
            Cursor cursor = db.rawQuery("SELECT COUNT(*) FROM habits_table", null);
            boolean accessible = cursor.moveToFirst();
            cursor.close();
            db.close();

            return accessible;
        } catch (Exception e) {
            Log.e(TAG, "Database not accessible", e);
            return false;
        }
    }
}