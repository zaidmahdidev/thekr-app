package com.example.thekr_app.radio

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.Icon
import android.media.MediaMetadata
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.os.Build
import android.os.IBinder
import androidx.core.content.ContextCompat
import com.example.thekr_app.R

/**
 * The radio's media notification: a real media session, so the system draws it
 * like any music player (cover, previous / play-pause / next, lock screen,
 * headset buttons). It runs as a foreground service of the media playback
 * type, so Android keeps the stream alive when the app is left.
 *
 * It only shows state. The sound is played by the Flutter side, and every
 * button is sent back there through [RadioChannel].
 */
@Suppress("DEPRECATION")
class RadioPlaybackService : Service() {

    private var session: MediaSession? = null
    private var art: Bitmap? = null

    private var title = ""
    private var subtitle = ""
    private var state = STATE_PLAYING

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createChannel()
        art = BitmapFactory.decodeResource(resources, R.drawable.radio_art)
        session = MediaSession(this, "ThekrRadio").apply {
            setCallback(object : MediaSession.Callback() {
                override fun onPlay() = RadioChannel.send("play")
                override fun onPause() = RadioChannel.send("pause")
                override fun onSkipToNext() = RadioChannel.send("next")
                override fun onSkipToPrevious() = RadioChannel.send("previous")
                override fun onStop() = RadioChannel.send("stop")
            })
            isActive = true
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> {
                title = intent.getStringExtra(EXTRA_TITLE) ?: ""
                subtitle = intent.getStringExtra(EXTRA_SUBTITLE) ?: ""
                state = intent.getStringExtra(EXTRA_STATE) ?: STATE_PLAYING
                render()
            }
            ACTION_HIDE -> shutDown()
            ACTION_DISMISSED -> {
                // The notification of a paused radio was swiped away.
                RadioChannel.send("stop")
                shutDown()
            }
            else -> {
                // Started without a command (after a restart): nothing to show.
                shutDown()
            }
        }
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        // A paused radio keeps its notification after the service state ends,
        // so it is always removed here.
        getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_ID)
        session?.release()
        session = null
        super.onDestroy()
    }

    // ------------------------------------------------------------------ view

    private fun render() {
        val playing = state != STATE_PAUSED
        val sessionState = when (state) {
            STATE_LOADING -> PlaybackState.STATE_BUFFERING
            STATE_PAUSED -> PlaybackState.STATE_PAUSED
            else -> PlaybackState.STATE_PLAYING
        }

        session?.setMetadata(
            MediaMetadata.Builder()
                .putString(MediaMetadata.METADATA_KEY_TITLE, title)
                .putString(MediaMetadata.METADATA_KEY_ARTIST, subtitle)
                .putBitmap(MediaMetadata.METADATA_KEY_ALBUM_ART, art)
                .build(),
        )
        session?.setPlaybackState(
            PlaybackState.Builder()
                .setActions(
                    PlaybackState.ACTION_PLAY or PlaybackState.ACTION_PAUSE or
                        PlaybackState.ACTION_PLAY_PAUSE or PlaybackState.ACTION_STOP or
                        PlaybackState.ACTION_SKIP_TO_NEXT or PlaybackState.ACTION_SKIP_TO_PREVIOUS,
                )
                // A live stream has no position.
                .setState(sessionState, PlaybackState.PLAYBACK_POSITION_UNKNOWN, 1f)
                .build(),
        )

        val notification = buildNotification(playing)

        // Android requires startForeground soon after startForegroundService,
        // so it is always called; a paused radio then lets go of the service
        // state and keeps the notification so it can be resumed or dismissed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        if (!playing) {
            stopForeground(false)
            getSystemService(NotificationManager::class.java).notify(NOTIFICATION_ID, notification)
        }
    }

    private fun buildNotification(playing: Boolean): Notification {
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, CHANNEL_ID)
        } else {
            Notification.Builder(this)
        }

        val playPause = if (playing) {
            action(android.R.drawable.ic_media_pause, "إيقاف مؤقت", "pause")
        } else {
            action(android.R.drawable.ic_media_play, "تشغيل", "play")
        }

        builder
            .setSmallIcon(R.drawable.ic_radio_small)
            .setLargeIcon(art)
            .setContentTitle(title)
            .setContentText(subtitle)
            .setContentIntent(openApp())
            .setDeleteIntent(servicePending(ACTION_DISMISSED))
            .setOngoing(playing)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .addAction(action(android.R.drawable.ic_media_previous, "السابقة", "previous"))
            .addAction(playPause)
            .addAction(action(android.R.drawable.ic_media_next, "التالية", "next"))
            .setStyle(
                Notification.MediaStyle()
                    .setMediaSession(session?.sessionToken)
                    .setShowActionsInCompactView(0, 1, 2),
            )
        return builder.build()
    }

    private fun action(icon: Int, label: String, command: String): Notification.Action {
        val intent = Intent(this, RadioActionReceiver::class.java)
            .setAction(RadioActionReceiver.ACTION)
            .putExtra(RadioActionReceiver.EXTRA_COMMAND, command)
        val pending = PendingIntent.getBroadcast(
            this,
            command.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        return Notification.Action.Builder(
            Icon.createWithResource("android", icon),
            label,
            pending,
        ).build()
    }

    private fun servicePending(action: String): PendingIntent {
        val intent = Intent(this, RadioPlaybackService::class.java).setAction(action)
        return PendingIntent.getService(
            this,
            action.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun openApp(): PendingIntent {
        val launch = packageManager.getLaunchIntentForPackage(packageName) ?: Intent()
        return PendingIntent.getActivity(
            this,
            0,
            launch,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun createChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java)
        if (manager.getNotificationChannel(CHANNEL_ID) != null) return
        manager.createNotificationChannel(
            NotificationChannel(CHANNEL_ID, "تشغيل الإذاعة", NotificationManager.IMPORTANCE_LOW).apply {
                description = "إشعار يظهر أثناء تشغيل الإذاعة"
                setShowBadge(false)
            },
        )
    }

    private fun shutDown() {
        stopForeground(STOP_FOREGROUND_REMOVE)
        getSystemService(NotificationManager::class.java).cancel(NOTIFICATION_ID)
        stopSelf()
    }

    companion object {
        private const val CHANNEL_ID = "radio_session"
        private const val NOTIFICATION_ID = 7302

        private const val ACTION_SHOW = "com.example.thekr_app.radio.SHOW"
        private const val ACTION_HIDE = "com.example.thekr_app.radio.HIDE"
        private const val ACTION_DISMISSED = "com.example.thekr_app.radio.DISMISSED"

        private const val EXTRA_TITLE = "title"
        private const val EXTRA_SUBTITLE = "subtitle"
        private const val EXTRA_STATE = "state"

        const val STATE_PLAYING = "playing"
        const val STATE_LOADING = "loading"
        const val STATE_PAUSED = "paused"

        fun show(context: Context, title: String, subtitle: String, state: String) {
            val intent = Intent(context, RadioPlaybackService::class.java)
                .setAction(ACTION_SHOW)
                .putExtra(EXTRA_TITLE, title)
                .putExtra(EXTRA_SUBTITLE, subtitle)
                .putExtra(EXTRA_STATE, state)
            ContextCompat.startForegroundService(context, intent)
        }

        fun hide(context: Context) {
            // Stopping a service that is not running is harmless.
            context.stopService(Intent(context, RadioPlaybackService::class.java))
        }
    }
}
