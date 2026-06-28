import { asyncHandler } from '../utils/asyncHandler.js';
import { AppError } from '../utils/AppError.js';
import * as productModel from '../models/product.model.js';

function serialize(row) {
  return {
    id:               row.id,
    title:            row.title,
    description:      row.description ?? '',
    price:            parseFloat(row.price),
    currency:         row.currency,
    stock:            row.stock,
    image_url:        row.image_url ?? null,
    category:         row.category ?? null,
    condition:        row.condition ?? null,
    allow_resell:     row.allow_resell,
    resell_margin_pct: row.resell_margin_pct ?? 0,
    seller_username:  row.seller_username ?? null,
  };
}

export const getMyProducts = asyncHandler(async (req, res) => {
  const rows = await productModel.getMyProducts(req.user.sub);
  res.json({ success: true, data: { products: rows.map(serialize) } });
});

export const getResellableProducts = asyncHandler(async (req, res) => {
  const rows = await productModel.getResellableProducts(req.user.sub);
  res.json({ success: true, data: { products: rows.map(serialize) } });
});

export const getPublicProducts = asyncHandler(async (req, res) => {
  const rows = await productModel.getPublicProducts();
  res.json({ success: true, data: { products: rows.map(serialize) } });
});

export const createProduct = asyncHandler(async (req, res) => {
  const {
    title, description, price, currency, stock,
    image_url, category, condition, allow_resell, resell_margin_pct,
  } = req.body;

  if (!title?.trim()) throw new AppError('Title is required', 400);
  if (price == null || isNaN(Number(price))) throw new AppError('Valid price is required', 400);

  const product = await productModel.createProduct(req.user.sub, {
    title: title.trim(),
    description,
    price: Number(price),
    currency,
    stock: Number(stock ?? 0),
    imageUrl: image_url,
    category,
    condition,
    allowResell: allow_resell === true || allow_resell === 'true',
    resellMarginPct: Number(resell_margin_pct ?? 0),
  });

  res.status(201).json({ success: true, data: { product: serialize(product) } });
});

export const getUserProducts = asyncHandler(async (req, res) => {
  const { userId } = req.params;
  const rows = await productModel.getProductsByUserId(userId);
  res.json({ success: true, data: { products: rows.map(serialize) } });
});
