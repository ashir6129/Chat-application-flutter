import pool from '../../src/config/db.js';
import { startDirectConversation } from '../../src/services/chat.service.js';
import { createBoxRequest, updateBoxRequestStatus } from '../../src/models/box.model.js';

async function test() {
  const client = await pool.connect();
  try {
    console.log('--- STARTING CHAT RESTRICTION TEST ---');

    // 1. Get user IDs
    const usersRes = await client.query('SELECT id, username FROM users WHERE username IN ($1, $2)', ['david_dev', 'sarah_travels']);
    const david = usersRes.rows.find(u => u.username === 'david_dev');
    const sarah = usersRes.rows.find(u => u.username === 'sarah_travels');

    if (!david || !sarah) {
      console.error('Test users not found!');
      return;
    }

    // 2. Clear any box requests and follow relationships for clean test
    await client.query('DELETE FROM box_requests WHERE (sender_id = $1 AND receiver_id = $2) OR (sender_id = $2 AND receiver_id = $1)', [david.id, sarah.id]);
    await client.query('DELETE FROM user_follows WHERE (follower_id = $1 AND following_id = $2) OR (follower_id = $2 AND following_id = $1)', [david.id, sarah.id]);

    console.log('Cleared all connections. Attempting to start chat...');

    // 3. Expect failure (no box request, no mutual follow)
    try {
      await startDirectConversation(david.id, sarah.id);
      console.error('TEST FAILED: Chat started when it should have been blocked!');
    } catch (err) {
      console.log('Successfully blocked unauthorized chat with error:', err.message);
    }

    // 4. Create and accept a Box request
    console.log('\nCreating and accepting a Box request between David and Sarah...');
    const boxRes = await createBoxRequest({
      senderId: david.id,
      receiverId: sarah.id,
      coins: 10,
      note: 'Unlock chat!'
    });
    
    await updateBoxRequestStatus(boxRes.request.id, sarah.id, 'accepted');
    console.log('Box request accepted!');

    // 5. Expect success now
    try {
      const convo = await startDirectConversation(david.id, sarah.id);
      console.log('TEST PASSED: Chat initiated successfully after Box request accepted! Conversation ID:', convo.id);
    } catch (err) {
      console.error('TEST FAILED: Chat blocked even after accepting box request!', err);
    }

    console.log('\n--- CHAT RESTRICTION TEST COMPLETED ---');
  } catch (err) {
    console.error('Test error:', err);
  } finally {
    client.release();
    await pool.end();
  }
}

test();
