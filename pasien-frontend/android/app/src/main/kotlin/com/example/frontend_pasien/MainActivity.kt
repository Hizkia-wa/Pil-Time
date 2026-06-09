package com.example.frontend_pasien

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.piltime.app/permissions"
    private val ALARM_CHANNEL = "com.piltime.app/alarm"
    private var pendingAlarmPayload: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        intent?.getStringExtra("piltime_alarm_payload")?.let {
            pendingAlarmPayload = it
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.getStringExtra("piltime_alarm_payload")?.let {
            pendingAlarmPayload = it
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ── Cek apakah izin "Display over other apps" sudah diberikan ──
                    "canDrawOverlays" -> {
                        val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            Settings.canDrawOverlays(applicationContext)
                        } else {
                            true // API < 23 tidak perlu izin ini
                        }
                        result.success(granted)
                    }

                    // ── Buka halaman pengaturan "Display over other apps" ──
                    "openOverlaySettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(
                                Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName")
                            )
                            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(intent)
                        }
                        result.success(null)
                    }

                    // ── Cek apakah app sudah dibebaskan dari optimasi baterai ──
                    "isIgnoringBatteryOptimizations" -> {
                        val ignoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val pm = getSystemService(POWER_SERVICE) as PowerManager
                            pm.isIgnoringBatteryOptimizations(packageName)
                        } else {
                            true // API < 23 tidak butuh
                        }
                        result.success(ignoring)
                    }

                    // ── Buka halaman pengaturan optimasi baterai ──
                    "openBatteryOptimizationSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            try {
                                // Langsung minta exempt untuk app ini
                                val intent = Intent(
                                    Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                    Uri.parse("package:$packageName")
                                )
                                startActivity(intent)
                            } catch (e: Exception) {
                                // Fallback: buka halaman umum optimasi baterai
                                val intent = Intent(
                                    Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
                                )
                                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                startActivity(intent)
                            }
                        }
                        result.success(null)
                    }

                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setAlarm" -> {
                        val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                        val timeInMillis = call.argument<Long>("timeInMillis") ?: return@setMethodCallHandler
                        val payload = call.argument<String>("payload") ?: ""
                        
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        val intent = Intent(this, PilTimeAlarmReceiver::class.java).apply {
                            putExtra("payload", payload)
                        }
                        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                        } else {
                            PendingIntent.FLAG_UPDATE_CURRENT
                        }
                        val pendingIntent = PendingIntent.getBroadcast(this, id, intent, flags)
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
                        } else {
                            alarmManager.setExact(AlarmManager.RTC_WAKEUP, timeInMillis, pendingIntent)
                        }
                        result.success(null)
                    }
                    
                    "cancelAlarm" -> {
                        val id = call.argument<Int>("id") ?: return@setMethodCallHandler
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        val intent = Intent(this, PilTimeAlarmReceiver::class.java)
                        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            PendingIntent.FLAG_NO_CREATE or PendingIntent.FLAG_IMMUTABLE
                        } else {
                            PendingIntent.FLAG_NO_CREATE
                        }
                        val pendingIntent = PendingIntent.getBroadcast(this, id, intent, flags)
                        if (pendingIntent != null) {
                            alarmManager.cancel(pendingIntent)
                        }
                        result.success(null)
                    }
                    
                    "getAlarmPayload" -> {
                        val payload = pendingAlarmPayload
                        pendingAlarmPayload = null
                        result.success(payload)
                    }
                    
                    else -> result.notImplemented()
                }
            }
    }
}
