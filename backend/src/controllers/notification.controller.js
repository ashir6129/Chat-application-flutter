import * as NotificationModel from '../models/notification.model.js';

export async function getNotifications(req, res, next) {
  try {
    const userId = req.user.sub;
    const page = Math.max(1, parseInt(req.query.page) || 1);
    const limit = Math.max(1, Math.min(100, parseInt(req.query.limit) || 20));
    const offset = (page - 1) * limit;

    const notifications = await NotificationModel.listNotificationsForUser(userId, { limit, offset });
    const unreadCount = await NotificationModel.countUnreadNotifications(userId);

    // Format to match the app expectations
    const formatted = notifications.map((n) => {
      // Determine sections: e.g. "New" if created within 24 hours, otherwise "Earlier"
      const diffMs = Date.now() - new Date(n.created_at).getTime();
      const section = diffMs < 24 * 60 * 60 * 1000 ? 'New' : 'Earlier';

      // Relative time text (simple helper)
      let timeText = 'Just now';
      const seconds = Math.floor(diffMs / 1000);
      const minutes = Math.floor(seconds / 60);
      const hours = Math.floor(minutes / 60);
      const days = Math.floor(hours / 24);

      if (days > 0) {
        timeText = `${days}d ago`;
      } else if (hours > 0) {
        timeText = `${hours}h ago`;
      } else if (minutes > 0) {
        timeText = `${minutes}m ago`;
      } else if (seconds > 5) {
        timeText = `${seconds}s ago`;
      }

      return {
        notification_uid: n.id,
        type: n.type,
        message: n.message,
        is_read: n.is_read,
        created_at: timeText,
        section,
        actor: {
          name: n.actor_username || 'Someone',
          avatar_url: n.actor_avatar || null,
          is_verified: n.actor_is_verified || false,
        },
        metadata: n.metadata || {},
      };
    });

    res.json({
      success: true,
      notifications: formatted,
      unread_count: unreadCount,
      page,
      limit,
    });
  } catch (err) {
    next(err);
  }
}

export async function markRead(req, res, next) {
  try {
    const userId = req.user.sub;
    const { id } = req.params;

    const updated = await NotificationModel.markNotificationAsRead(id, userId);
    if (!updated) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    res.json({ success: true, notification: updated });
  } catch (err) {
    next(err);
  }
}

export async function markAllRead(req, res, next) {
  try {
    const userId = req.user.sub;
    await NotificationModel.markAllNotificationsAsRead(userId);
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (err) {
    next(err);
  }
}

export async function deleteNotif(req, res, next) {
  try {
    const userId = req.user.sub;
    const { id } = req.params;

    const deleted = await NotificationModel.deleteNotification(id, userId);
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    res.json({ success: true, message: 'Notification deleted successfully' });
  } catch (err) {
    next(err);
  }
}
