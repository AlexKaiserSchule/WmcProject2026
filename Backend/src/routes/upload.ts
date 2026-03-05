import { Router } from 'express';
import upload from '../middleware/upload';
import { uploadImage, getImage, deleteImage } from '../controllers/uploadController';

const router = Router();

router.post('/', upload.single('image'), uploadImage);
router.get('/:id', getImage);
router.delete('/:id', deleteImage);

export default router;
