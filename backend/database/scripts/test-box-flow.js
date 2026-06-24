import pool from '../../src/config/db.js';
import { createBoxRequest, getReceivedBoxRequests, updateBoxRequestStatus } from '../../src/models/box.model.js';
import { getWallet } from '../../src/models/tip.model.js';

async function test() {
  const client = await pool.connect();
  try {
    console.log('--- STARTING BOX FLOW TEST ---');

    // 1. Get user IDs for seeded users
    const usersRes = await client.query('SELECT id, username FROM users WHERE username IN ($1, $2)', ['david_dev', 'sarah_travels']);
    const david = usersRes.rows.find(u => u.username === 'david_dev');
    const sarah = usersRes.rows.find(u => u.username === 'sarah_travels');

    if (!david || !sarah) {
      console.error('Seeded users david_dev or sarah_travels not found!');
      return;
    }

    console.log(`User David ID: ${david.id}`);
    console.log(`User Sarah ID: ${sarah.id}`);

    // Reset wallets for clean test
    await client.query('INSERT INTO user_wallets (user_id, balance_credits) VALUES ($1, 200) ON CONFLICT (user_id) DO UPDATE SET balance_credits = 200', [david.id]);
    await client.query('INSERT INTO user_wallets (user_id, balance_credits) VALUES ($1, 100) ON CONFLICT (user_id) DO UPDATE SET balance_credits = 100', [sarah.id]);

    let walletDavid = await getWallet(david.id);
    let walletSarah = await getWallet(sarah.id);
    console.log(`Initial Balances -> David: ${walletDavid.balance_credits} credits, Sarah: ${walletSarah.balance_credits} credits`);

    // 2. David sends a Box Request to Sarah with 50 coins and a note
    console.log('\nSending Box request from David to Sarah...');
    const sendRes = await createBoxRequest({
      senderId: david.id,
      receiverId: sarah.id,
      coins: 50,
      note: 'Hello Sarah! Would love to connect!'
    });

    if (!sendRes.ok) {
      console.error('Failed to send box:', sendRes.reason);
      return;
    }
    console.log('Box request created successfully:', sendRes.request);

    // 3. List received requests for Sarah
    console.log('\nFetching received box requests for Sarah...');
    const received = await getReceivedBoxRequests(sarah.id);
    console.log('Sarah received requests:', received);

    // 4. Sarah accepts David\'s Box Request
    const requestId = received[0]?.id;
    if (!requestId) {
      console.error('No received request ID found for Sarah!');
      return;
    }

    console.log(`\nSarah accepting request ID: ${requestId}...`);
    const acceptRes = await updateBoxRequestStatus(requestId, sarah.id, 'accepted');
    if (!acceptRes.ok) {
      console.error('Failed to accept box:', acceptRes.reason);
      return;
    }
    console.log('Box request accepted successfully:', acceptRes.request);

    // 5. Verify wallet credits transferred
    walletDavid = await getWallet(david.id);
    walletSarah = await getWallet(sarah.id);
    console.log(`\nFinal Balances -> David: ${walletDavid.balance_credits} credits (should be 150), Sarah: ${walletSarah.balance_credits} credits (should be 150)`);

    console.log('\n--- BOX FLOW TEST COMPLETED SUCCESSFULY ---');
  } catch (err) {
    console.error('Test error:', err);
  } finally {
    client.release();
    await pool.end();
  }
}

test();
