const onlineUsers = new Map();

export function setUserOnline(userId, socketId) {
  if (!onlineUsers.has(userId)) {
    onlineUsers.set(userId, new Set());
  }
  onlineUsers.get(userId).add(socketId);
}

export function setUserOffline(userId, socketId) {
  const sockets = onlineUsers.get(userId);
  if (!sockets) return;

  sockets.delete(socketId);
  if (sockets.size === 0) {
    onlineUsers.delete(userId);
  }
}

export function isUserOnline(userId) {
  return onlineUsers.has(userId);
}

export function getOnlineUserIds() {
  return [...onlineUsers.keys()];
}
