package com.example.tiny_wins;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.view.View;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class HabitWidgetProvider extends AppWidgetProvider {
    private static final String ACTION_MARK_COMPLETE = "com.example.tiny_wins.MARK_COMPLETE";
    private static final String EXTRA_HABIT_ID = "habit_id";
    private static final String EXTRA_WIDGET_ID = "widget_id";

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
        }
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);

        if (ACTION_MARK_COMPLETE.equals(intent.getAction())) {
            int habitId = intent.getIntExtra(EXTRA_HABIT_ID, -1);
            int widgetId = intent.getIntExtra(EXTRA_WIDGET_ID, -1);

            if (habitId != -1 && widgetId != -1) {
                // Mark habit as complete and update widget
                markHabitComplete(context, habitId);
                updateAppWidget(context, AppWidgetManager.getInstance(context), widgetId);
            }
        }
    }

    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId) {
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.habit_widget);

        try {
            SharedPreferences prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE);
            String widgetDataJson = prefs.getString("flutter.tinywins_habits_widget_data", "");

            if (widgetDataJson.isEmpty()) {
                // Fallback to the old key format if new one doesn't exist
                widgetDataJson = prefs.getString("tinywins_habits_widget_data", "");
            }

            // Final fallback to old widget ID pattern
            if (widgetDataJson.isEmpty()) {
                for (int id = 0; id < 10; id++) {
                    widgetDataJson = prefs.getString("flutter.HabitWidgetPrefs_" + id + ".widget_data", "");
                    if (!widgetDataJson.isEmpty()) break;
                }
            }

            if (!widgetDataJson.isEmpty()) {
                JSONObject widgetData = new JSONObject(widgetDataJson);
                JSONArray habitsArray = widgetData.getJSONArray("habits");
                int totalHabits = widgetData.getInt("totalHabits");
                int completedHabits = widgetData.getInt("completedHabits");

                // Set header info with progress
                views.setTextViewText(R.id.widget_title, "TinyWins");
                views.setTextViewText(R.id.widget_subtitle, "Today's Habits (" + completedHabits + "/" + totalHabits + ")");

                // Create individual habit items
                if (habitsArray.length() > 0) {
                    // Hide the message text view
                    views.setViewVisibility(R.id.habits_message, View.GONE);
                    // Show the habits container
                    views.setViewVisibility(R.id.habits_container, View.VISIBLE);

                    // Clear all existing views from the container first to prevent duplication
                    views.removeAllViews(R.id.habits_container);

                    // Add habit items to the container
                    int maxHabitsToShow = Math.min(habitsArray.length(), 10); // Show max 10 habits

                    for (int i = 0; i < maxHabitsToShow; i++) {
                        try {
                            JSONObject habit = habitsArray.getJSONObject(i);
                            RemoteViews habitItem = createHabitItem(context, habit, appWidgetId);
                            views.addView(R.id.habits_container, habitItem);
                        } catch (Exception e) {
                            System.err.println("Error creating habit item " + i + ": " + e.getMessage());
                        }
                    }
                } else {
                    // No habits - show message
                    views.setViewVisibility(R.id.habits_container, View.GONE);
                    views.setViewVisibility(R.id.habits_message, View.VISIBLE);
                    views.setTextViewText(R.id.habits_message, "No habits scheduled for today");
                }
            } else {
                // No data available
                views.setTextViewText(R.id.widget_title, "TinyWins");
                views.setTextViewText(R.id.widget_subtitle, "Today's Habits");
                views.setTextViewText(R.id.habits_message, "Create your first habit!");
            }
        } catch (JSONException e) {
            // Error parsing data, show default message
            views.setTextViewText(R.id.widget_title, "TinyWins");
            views.setTextViewText(R.id.widget_subtitle, "Today's Habits");
            views.setTextViewText(R.id.habits_message, "Create your first habit!");
        }

        // Update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    private static RemoteViews createHabitItem(Context context, JSONObject habit, int widgetId) throws JSONException {
        RemoteViews habitItem = new RemoteViews(context.getPackageName(), R.layout.habit_widget_item);

        int habitId = habit.getInt("id");
        String title = habit.getString("title");
        boolean isCompleted = habit.getBoolean("isCompletedToday");

        habitItem.setTextViewText(R.id.habit_title, title);

        // Configure icon based on completion status
        if (isCompleted) {
            habitItem.setImageViewResource(R.id.mark_complete_button, R.drawable.ic_check_circle);
        } else {
            habitItem.setImageViewResource(R.id.mark_complete_button, R.drawable.ic_circle_outline);
        }

        // Set up click listener for mark as complete button
        Intent markCompleteIntent = new Intent(context, HabitWidgetProvider.class);
        markCompleteIntent.setAction(ACTION_MARK_COMPLETE);
        markCompleteIntent.putExtra(EXTRA_HABIT_ID, habitId);
        markCompleteIntent.putExtra(EXTRA_WIDGET_ID, widgetId);

        PendingIntent markCompletePendingIntent = PendingIntent.getBroadcast(
                context, habitId + 1000, markCompleteIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        habitItem.setOnClickPendingIntent(R.id.mark_complete_button, markCompletePendingIntent);

        return habitItem;
    }

    private void markHabitComplete(Context context, int habitId) {
        // Start MainActivity with habit action data
        Intent mainIntent = new Intent(context, MainActivity.class);
        mainIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        mainIntent.putExtra("widget_habit_id", habitId);
        mainIntent.putExtra("widget_action", "mark_complete");
        context.startActivity(mainIntent);

        // Also trigger widget update
        Intent updateIntent = new Intent(context, HabitWidgetProvider.class);
        updateIntent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        context.sendBroadcast(updateIntent);
    }

    @Override
    public void onEnabled(Context context) {
        // Called when the first widget is created
        // Schedule daily refresh to ensure widget updates at midnight
        WidgetRefreshScheduler.scheduleDailyRefresh(context);
        android.util.Log.d("HabitWidgetProvider", "Widget enabled - daily refresh scheduled");
    }

    @Override
    public void onDisabled(Context context) {
        // Called when the last widget is removed
    }
}