package com.fschmatz.series_watcher_fschmatz

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONObject
import es.antonborri.home_widget.HomeWidgetPlugin

class TvShowWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TvShowRemoteViewsFactory(this.applicationContext)
    }
}

class TvShowRemoteViewsFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {
    private var showsList = mutableListOf<JSONObject>()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        showsList.clear()

        // Use HomeWidgetPlugin to get the correct SharedPreferences
        val prefs = HomeWidgetPlugin.getData(context)
        val jsonString = prefs.getString("tv_shows_json", "[]") ?: "[]"

        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                showsList.add(jsonArray.getJSONObject(i))
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        showsList.clear()
    }

    override fun getCount(): Int = showsList.size

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)
        if (position < showsList.size) {
            val show = showsList[position]
            views.setTextViewText(R.id.tv_show_name, show.optString("show_name", ""))
            views.setTextViewText(R.id.tv_next_episode, show.optString("next_episode", ""))

            val duration = show.optString("duration", "")
            if (duration.isNotEmpty()) {
                views.setTextViewText(R.id.tv_episode_duration, duration)
            } else {
                views.setTextViewText(R.id.tv_episode_duration, "")
            }
        }
        return views
    }

    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
}
