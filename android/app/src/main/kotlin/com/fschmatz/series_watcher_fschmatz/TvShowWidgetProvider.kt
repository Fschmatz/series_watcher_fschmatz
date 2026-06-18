package com.fschmatz.series_watcher_fschmatz

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.util.Base64
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

class TvShowWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tv_show_widget)

            try {
                val prefs = HomeWidgetPlugin.getData(context)
                val jsonString = prefs.getString("tv_shows_json", "[]") ?: "[]"
                val jsonArray = JSONArray(jsonString)

                // Android 16 (API 36) exclusively uses modern CollectionItems API
                val builder = RemoteViews.RemoteCollectionItems.Builder()

                for (i in 0 until jsonArray.length()) {
                    val item = jsonArray.getJSONObject(i)
                    val id = item.optLong("id", i.toLong())
                    val itemViews = getProcessedItemView(context, item)

                    builder.addItem(id, itemViews)
                }

                builder.setHasStableIds(true)
                val collectionItems = builder.build()
                views.setRemoteAdapter(R.id.widget_list_view, collectionItems)
            } catch (e: Exception) {
                e.printStackTrace()
            }

            views.setEmptyView(R.id.widget_list_view, R.id.widget_empty_view)

            val clickIntentTemplate = Intent(Intent.ACTION_VIEW)
            var pendingIntentFlags = android.app.PendingIntent.FLAG_UPDATE_CURRENT or android.app.PendingIntent.FLAG_MUTABLE
            if (Build.VERSION.SDK_INT >= 34) {
                pendingIntentFlags = pendingIntentFlags or android.app.PendingIntent.FLAG_ALLOW_UNSAFE_IMPLICIT_INTENT
            }

            val pendingIntentTemplate = android.app.PendingIntent.getActivity(
                context, 0, clickIntentTemplate, pendingIntentFlags
            )
            views.setPendingIntentTemplate(R.id.widget_list_view, pendingIntentTemplate)

            appWidgetManager.updateAppWidget(widgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list_view)
        }
    }

    private fun getProcessedItemView(context: Context, show: JSONObject): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)

        views.setImageViewBitmap(R.id.iv_cover, null)

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
                val decodedBytes = Base64.decode(coverBase64, Base64.DEFAULT)
                val bitmap = BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                if (bitmap != null) {
                    val roundedBitmap = getRoundedCornerBitmap(bitmap, context, 8)
                    views.setImageViewBitmap(R.id.iv_cover, roundedBitmap)
                }
            } catch (e: Exception) {
                views.setImageViewBitmap(R.id.iv_cover, getPlaceholderBitmap(context, 8))
            }
        } else {
            views.setImageViewBitmap(R.id.iv_cover, getPlaceholderBitmap(context, 8))
        }

        return views
    }

    private fun getPlaceholderBitmap(context: Context, dp: Int): android.graphics.Bitmap {
        val width = (36 * context.resources.displayMetrics.density).toInt()
        val height = (54 * context.resources.displayMetrics.density).toInt()
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

    private fun getRoundedCornerBitmap(bitmap: android.graphics.Bitmap, context: Context, dp: Int): android.graphics.Bitmap {
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
}
