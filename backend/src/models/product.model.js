import pool from '../config/db.js';

export async function getMyProducts(userId) {
  const { rows } = await pool.query(
    `SELECT id, title, description, price, currency, stock, image_url,
            category, condition, allow_resell, resell_margin_pct
     FROM marketplace_products
     WHERE user_id = $1 AND is_active = TRUE
     ORDER BY created_at DESC`,
    [userId],
  );
  return rows;
}

export async function getProductsByUserId(userId) {
  const { rows } = await pool.query(
    `SELECT id, title, description, price, currency, stock, image_url,
            category, condition, allow_resell, resell_margin_pct
     FROM marketplace_products
     WHERE user_id = $1 AND is_active = TRUE
     ORDER BY created_at DESC`,
    [userId],
  );
  return rows;
}

export async function getResellableProducts(excludeUserId) {
  const { rows } = await pool.query(
    `SELECT mp.id, mp.title, mp.description, mp.price, mp.currency,
            mp.stock, mp.image_url, mp.category, mp.condition,
            mp.resell_margin_pct,
            u.username AS seller_username
     FROM marketplace_products mp
     JOIN users u ON u.id = mp.user_id
     WHERE mp.allow_resell = TRUE
       AND mp.is_active = TRUE
       AND mp.user_id != $1
     ORDER BY mp.created_at DESC`,
    [excludeUserId],
  );
  return rows;
}

export async function getPublicProducts() {
  const { rows } = await pool.query(
    `SELECT mp.id, mp.title, mp.description, mp.price, mp.currency,
            mp.stock, mp.image_url, mp.category, mp.condition,
            mp.resell_margin_pct,
            u.username AS seller_username
     FROM marketplace_products mp
     JOIN users u ON u.id = mp.user_id
     WHERE mp.is_active = TRUE
     ORDER BY mp.created_at DESC`
  );
  return rows;
}

export async function createProduct(userId, data) {
  const {
    title, description = null, price, currency = '₦', stock = 0,
    imageUrl = null, category = null, condition = null,
    allowResell = false, resellMarginPct = 0,
  } = data;

  const { rows } = await pool.query(
    `INSERT INTO marketplace_products
       (user_id, title, description, price, currency, stock, image_url,
        category, condition, allow_resell, resell_margin_pct)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
     RETURNING *`,
    [userId, title, description, price, currency, stock, imageUrl,
     category, condition, allowResell, resellMarginPct],
  );
  return rows[0];
}
