import pool, { query } from '../config/db.js';

export async function ensureWallet(userId) {
  await query(
    `INSERT INTO user_wallets (user_id) VALUES ($1)
     ON CONFLICT (user_id) DO NOTHING`,
    [userId],
  );
}

export async function getWallet(userId) {
  await ensureWallet(userId);
  const result = await query(
    `SELECT user_id, balance_credits, tips_received_total, updated_at
     FROM user_wallets WHERE user_id = $1`,
    [userId],
  );
  return result.rows[0] ?? null;
}

export async function sendTip({ senderId, recipientId, postId, tipType, amount }) {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    await client.query(
      `INSERT INTO user_wallets (user_id) VALUES ($1)
       ON CONFLICT (user_id) DO NOTHING`,
      [senderId],
    );
    await client.query(
      `INSERT INTO user_wallets (user_id) VALUES ($1)
       ON CONFLICT (user_id) DO NOTHING`,
      [recipientId],
    );

    const balanceResult = await client.query(
      `SELECT balance_credits FROM user_wallets WHERE user_id = $1 FOR UPDATE`,
      [senderId],
    );
    const balance = balanceResult.rows[0]?.balance_credits ?? 0;
    if (balance < amount) {
      await client.query('ROLLBACK');
      return { ok: false, reason: 'insufficient_balance', balance };
    }

    await client.query(
      `UPDATE user_wallets SET balance_credits = balance_credits - $2, updated_at = NOW()
       WHERE user_id = $1`,
      [senderId, amount],
    );
    await client.query(
      `UPDATE user_wallets SET tips_received_total = tips_received_total + $2, updated_at = NOW()
       WHERE user_id = $1`,
      [recipientId, amount],
    );

    const tipResult = await client.query(
      `INSERT INTO tips (sender_id, recipient_id, post_id, tip_type, amount)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING id, sender_id, recipient_id, post_id, tip_type, amount, created_at`,
      [senderId, recipientId, postId ?? null, tipType, amount],
    );

    const walletResult = await client.query(
      `SELECT balance_credits FROM user_wallets WHERE user_id = $1`,
      [senderId],
    );

    await client.query('COMMIT');

    return {
      ok: true,
      tip: tipResult.rows[0],
      balance: walletResult.rows[0]?.balance_credits ?? 0,
    };
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

export async function listTipsForUser(userId, { page = 1, limit = 20 } = {}) {
  const offset = (page - 1) * limit;
  const result = await query(
    `SELECT t.id, t.tip_type, t.amount, t.post_id, t.created_at,
            u.username AS sender_username, u.avatar_url AS sender_avatar
     FROM tips t
     JOIN users u ON u.id = t.sender_id
     WHERE t.recipient_id = $1
     ORDER BY t.created_at DESC
     LIMIT $2 OFFSET $3`,
    [userId, limit, offset],
  );
  return result.rows;
}
