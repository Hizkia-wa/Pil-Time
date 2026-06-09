package com.example.frontend_pasien

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.util.Log

class PilTimeAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val payload = intent.getStringExtra("payload")
        Log.d("PilTime", "Native AlarmReceiver triggered with payload: $payload")

        // Periksa izin SYSTEM_ALERT_WINDOW (Draw over other apps)
        val canDrawOverlays = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Settings.canDrawOverlays(context)
        } else {
            true // API < 23 tidak butuh izin khusus ini
        }

        if (canDrawOverlays) {
            Log.d("PilTime", "Permission canDrawOverlays granted. Force launching MainActivity.")
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
                putExtra("piltime_alarm_payload", payload)
            }
            context.startActivity(launchIntent)
        } else {
            Log.d("PilTime", "Permission canDrawOverlays NOT granted. Relying purely on flutter_local_notifications.")
        }
    }
}
