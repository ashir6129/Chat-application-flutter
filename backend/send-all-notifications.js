import { sendPushNotification } from './src/services/notification.service.js';
import { findUserByEmail } from './src/models/user.model.js';

const userId = 'ef8cb557-21f7-4481-b6d2-86f214ddd26c';

const notifications = [
  // Social actions
  { type: 'follow', title: 'New Follower', body: 'Someone started following you', data: { type: 'follow', follower_id: 'test-user-id' } },
  { type: 'like', title: 'New Like', body: 'Someone liked your post', data: { type: 'like', post_id: 'test-post-id', post_type: 'image', liker_id: 'test-user-id' } },
  { type: 'comment', title: 'New Comment', body: 'Someone commented on your post', data: { type: 'comment', post_id: 'test-post-id', commenter_id: 'test-user-id' } },
  { type: 'mention', title: 'You were mentioned', body: 'Someone mentioned you in a comment', data: { type: 'mention', post_id: 'test-post-id' } },
  { type: 'tag', title: 'You were tagged', body: 'Someone tagged you in a post', data: { type: 'tag', post_id: 'test-post-id' } },
  { type: 'post_share', title: 'Post Shared', body: 'Someone shared your post', data: { type: 'post_share', post_id: 'test-post-id', sharer_id: 'test-user-id' } },
  
  // Message actions
  { type: 'message', title: 'New Message', body: 'You have a new message', data: { type: 'message', conversation_id: 'test-conv-id', sender_id: 'test-user-id', message_type: 'text' } },
  { type: 'group_message', title: 'Group Message', body: 'New message in group', data: { type: 'group_message', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_voice', title: 'Voice Message', body: 'Someone sent you a voice message', data: { type: 'message_voice', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_photo', title: 'Photo Message', body: 'Someone sent you a photo', data: { type: 'message_photo', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_video', title: 'Video Message', body: 'Someone sent you a video', data: { type: 'message_video', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_reel', title: 'Reel Message', body: 'Someone sent you a reel', data: { type: 'message_reel', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_mention', title: 'Mentioned in Chat', body: 'Someone mentioned you in a message', data: { type: 'message_mention', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_reply', title: 'Message Reply', body: 'Someone replied to your message', data: { type: 'message_reply', conversation_id: 'test-conv-id', sender_id: 'test-user-id' } },
  { type: 'message_reaction', title: 'Message Reaction', body: 'Someone reacted to your message', data: { type: 'message_reaction', conversation_id: 'test-conv-id', sender_id: 'test-user-id', emoji: '❤️' } },
  
  // Call actions
  { type: 'voice_call', title: 'Voice Call', body: 'Someone is calling you', data: { type: 'voice_call', caller_id: 'test-user-id', caller_username: 'TestUser' } },
  { type: 'video_call', title: 'Video Call', body: 'Someone is video calling you', data: { type: 'video_call', caller_id: 'test-user-id', caller_username: 'TestUser' } },
  { type: 'missed_call', title: 'Missed Call', body: 'You missed a call', data: { type: 'missed_call', caller_id: 'test-user-id', caller_username: 'TestUser' } },
  
  // Other actions
  { type: 'trending_post', title: 'Trending Post', body: 'Your post is trending', data: { type: 'trending_post', post_id: 'test-post-id' } },
];

async function sendAll() {
  console.log('Sending all notification types...\n');
  
  for (let i = 0; i < notifications.length; i++) {
    const notif = notifications[i];
    console.log(`[${i+1}/${notifications.length}] Sending ${notif.type}...`);
    
    try {
      const result = await sendPushNotification(userId, notif);
      console.log(`  ✓ ${notif.type}: ${result.success ? 'Success' : 'Failed'} - ${result.error || result.messageId || result.reason}`);
    } catch (e) {
      console.log(`  ✗ ${notif.type}: Error - ${e.message}`);
    }
    
    // Delay between notifications
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
  
  console.log('\nAll notifications sent!');
  process.exit(0);
}

sendAll();
