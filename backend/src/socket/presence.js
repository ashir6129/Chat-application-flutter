const onlineUsers = new Map();

export function setUserOnline(userId, socketId) {
  if (userId == null) return;
  const key = String(userId);
  if (!onlineUsers.has(key)) {
    onlineUsers.set(key, new Set());
  }
  onlineUsers.get(key).add(socketId);
}

export function setUserOffline(userId, socketId) {
  if (userId == null) return;
  const key = String(userId);
  const sockets = onlineUsers.get(key);
  if (!sockets) return;

  sockets.delete(socketId);
  if (sockets.size === 0) {
    onlineUsers.delete(key);
  }
}

export function isUserOnline(userId) {
  if (userId == null) return false;
  return onlineUsers.has(String(userId));
}

export function getOnlineUserIds() {
  return [...onlineUsers.keys()];
}
