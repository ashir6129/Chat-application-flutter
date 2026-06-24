import pool, { query } from '../config/db.js';

export async function createBoxRequest({ senderId, receiverId, coins, note }) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Ensure wallets exist
    await client.query(
      `INSERT INTO user_wallets (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [senderId],
    );
    await client.query(
      `INSERT INTO user_wallets (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
      [receiverId],
    );

    // 2. Check sender wallet balance
    const balanceRes = await client.query(
      `SELECT balance_credits FROM user_wallets WHERE user_id = $1 FOR UPDATE`,
      [senderId],
    );
    const balance = balanceRes.rows[0]?.balance_credits ?? 0;
    if (balance < coins) {
      await client.query('ROLLBACK');
      return { ok: false, reason: 'insufficient_balance' };
    }

    // 3. Create box request
    const result = await client.query(
      `INSERT INTO box_requests (sender_id, receiver_id, coins, note, status)
       VALUES ($1, $2, $3, $4, 'pending')
       ON CONFLICT (sender_id, receiver_id) DO UPDATE
       SET coins = $3, note = $4, status = 'pending', updated_at = NOW()
       RETURNING id, sender_id, receiver_id, coins, note, status, created_at`,
      [senderId, receiverId, coins, note],
    );

    await client.query('COMMIT');
    return { ok: true, request: result.rows[0] };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export async function getBoxRequest(requestId) {
  const result = await query(
    `SELECT id, sender_id, receiver_id, coins, note, status, created_at FROM box_requests WHERE id = $1`,
    [requestId]
  );
  return result.rows[0] ?? null;
}

export async function findBoxRequestBetween(userId1, userId2) {
  const result = await query(
    `SELECT id, sender_id, receiver_id, coins, note, status, created_at 
     FROM box_requests 
     WHERE (sender_id = $1 AND receiver_id = $2) OR (sender_id = $2 AND receiver_id = $1)
     LIMIT 1`,
    [userId1, userId2]
  );
  return result.rows[0] ?? null;
}

export async function getReceivedBoxRequests(userId) {
  const result = await query(
    `SELECT br.id, br.coins, br.note, br.status, br.created_at,
            u.id AS sender_id, u.username AS sender_username, u.avatar_url AS sender_avatar,
            u.is_verified AS sender_verified
     FROM box_requests br
     JOIN users u ON u.id = br.sender_id
     WHERE br.receiver_id = $1 AND br.status = 'pending'
     ORDER BY br.created_at DESC`,
    [userId],
  );
  return result.rows;
}

export async function getSentBoxRequests(userId) {
  const result = await query(
    `SELECT br.id, br.coins, br.note, br.status, br.created_at,
            u.id AS receiver_id, u.username AS receiver_username, u.avatar_url AS receiver_avatar,
            u.is_verified AS receiver_verified
     FROM box_requests br
     JOIN users u ON u.id = br.receiver_id
     WHERE br.sender_id = $1
     ORDER BY br.created_at DESC`,
    [userId],
  );
  return result.rows;
}

export async function updateBoxRequestStatus(requestId, receiverId, status) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Lock and get the request
    const requestRes = await client.query(
      `SELECT id, sender_id, receiver_id, coins, status FROM box_requests WHERE id = $1 AND receiver_id = $2 FOR UPDATE`,
      [requestId, receiverId]
    );

    const request = requestRes.rows[0];
    if (!request) {
      await client.query('ROLLBACK');
      return { ok: false, reason: 'not_found' };
    }

    if (request.status !== 'pending') {
      await client.query('ROLLBACK');
      return { ok: false, reason: 'already_processed' };
    }

    if (status === 'accepted') {
      const { sender_id, coins } = request;

      // Ensure wallets exist
      await client.query(
        `INSERT INTO user_wallets (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
        [sender_id],
      );
      await client.query(
        `INSERT INTO user_wallets (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING`,
        [receiverId],
      );

      // Lock and check sender balance
      const balanceRes = await client.query(
        `SELECT balance_credits FROM user_wallets WHERE user_id = $1 FOR UPDATE`,
        [sender_id],
      );
      const balance = balanceRes.rows[0]?.balance_credits ?? 0;
      if (balance < coins) {
        // Fallback: decline or fail accept due to insufficient balance
        await client.query('ROLLBACK');
        return { ok: false, reason: 'sender_insufficient_balance' };
      }

      // Deduct coins from sender
      await client.query(
        `UPDATE user_wallets SET balance_credits = balance_credits - $2, updated_at = NOW() WHERE user_id = $1`,
        [sender_id, coins]
      );

      // Add coins to receiver
      await client.query(
        `UPDATE user_wallets SET balance_credits = balance_credits + $2, tips_received_total = tips_received_total + $2, updated_at = NOW() WHERE user_id = $1`,
        [receiverId, coins]
      );
    }

    // Update box request status
    const updateRes = await client.query(
      `UPDATE box_requests SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING id, status, updated_at`,
      [status, requestId]
    );

    await client.query('COMMIT');
    return { ok: true, request: updateRes.rows[0] };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}
