import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import * as productController from '../../controllers/product.controller.js';

const router = Router();

router.get('/my',        requireAuth, productController.getMyProducts);
router.get('/resellable', requireAuth, productController.getResellableProducts);
router.get('/',          requireAuth, productController.getPublicProducts);
router.get('/user/:userId', requireAuth, productController.getUserProducts);
router.post('/',         requireAuth, productController.createProduct);

export default router;
