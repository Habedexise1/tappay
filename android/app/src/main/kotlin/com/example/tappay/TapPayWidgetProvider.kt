package com.example.tappay

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class TapPayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val launchIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse(SCANNER_URI),
        )

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.tappay_widget).apply {
                setTextViewText(
                    R.id.widget_balance,
                    widgetData.getString(KEY_BALANCE, null) ?: context.getString(R.string.widget_balance_placeholder),
                )
                setTextViewText(
                    R.id.widget_last_amount,
                    widgetData.getString(KEY_LAST_AMOUNT, null) ?: context.getString(R.string.widget_empty_amount),
                )
                setTextViewText(
                    R.id.widget_last_merchant,
                    widgetData.getString(KEY_LAST_MERCHANT, null) ?: context.getString(R.string.widget_no_transactions),
                )
                setTextViewText(
                    R.id.widget_last_date,
                    widgetData.getString(KEY_LAST_DATE, null) ?: "",
                )
                setOnClickPendingIntent(R.id.widget_root, launchIntent)
                setOnClickPendingIntent(R.id.widget_scan_button, launchIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    companion object {
        const val SCANNER_URI = "tappay://qr_scanner?homeWidget"
        const val KEY_BALANCE = "widget_balance"
        const val KEY_LAST_AMOUNT = "widget_last_amount"
        const val KEY_LAST_MERCHANT = "widget_last_merchant"
        const val KEY_LAST_DATE = "widget_last_date"
    }
}
