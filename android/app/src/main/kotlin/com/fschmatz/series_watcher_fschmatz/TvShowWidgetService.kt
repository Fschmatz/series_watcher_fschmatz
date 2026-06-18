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

        // Always clear the ImageView first to prevent stale cached bitmaps
        views.setImageViewBitmap(R.id.iv_cover, null)

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

            val coverBase64 = show.optString("cover", "")
            if (coverBase64.isNotEmpty()) {
                try {
                    val decodedBytes = android.util.Base64.decode(coverBase64, android.util.Base64.DEFAULT)
                    val bitmap = android.graphics.BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                    val roundedBitmap = getRoundedCornerBitmap(bitmap, 8)
                    views.setImageViewBitmap(R.id.iv_cover, roundedBitmap)
                } catch (e: Exception) {
                    views.setImageViewBitmap(R.id.iv_cover, getPlaceholderBitmap(8))
                }
            } else {
                views.setImageViewBitmap(R.id.iv_cover, getPlaceholderBitmap(8))
            }
        }
        return views
    }

    private fun getPlaceholderBitmap(dp: Int): android.graphics.Bitmap {
        val width = (48 * context.resources.displayMetrics.density).toInt()
        val height = (68 * context.resources.displayMetrics.density).toInt()
        val pixels = (dp * context.resources.displayMetrics.density).toInt()
        val output = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(output)
        val paint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG)
        paint.color = android.graphics.Color.BLACK
        canvas.drawRoundRect(
            android.graphics.RectF(0f, 0f, width.toFloat(), height.toFloat()),
            pixels.toFloat(), pixels.toFloat(), paint
        )
        return output
    }

    private fun getRoundedCornerBitmap(bitmap: android.graphics.Bitmap, dp: Int): android.graphics.Bitmap {
        val pixels = (dp * context.resources.displayMetrics.density).toInt()
        val output = android.graphics.Bitmap.createBitmap(bitmap.width, bitmap.height, android.graphics.Bitmap.Config.ARGB_8888)
        val canvas = android.graphics.Canvas(output)
        val paint = android.graphics.Paint()
        val rect = android.graphics.Rect(0, 0, bitmap.width, bitmap.height)
        val rectF = android.graphics.RectF(rect)
        val roundPx = pixels.toFloat()

        paint.isAntiAlias = true
        canvas.drawARGB(0, 0, 0, 0)
        paint.color = -0xbdbdbe
        canvas.drawRoundRect(rectF, roundPx, roundPx, paint)
        paint.xfermode = android.graphics.PorterDuffXfermode(android.graphics.PorterDuff.Mode.SRC_IN)
        canvas.drawBitmap(bitmap, rect, rect, paint)
        return output
    }

    override fun getLoadingView(): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)
        views.setTextViewText(R.id.tv_show_name, "")
        views.setTextViewText(R.id.tv_next_episode, "")
        views.setTextViewText(R.id.tv_episode_duration, "")
        views.setImageViewBitmap(R.id.iv_cover, getPlaceholderBitmap(8))
        return views
    }

    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = false
}
