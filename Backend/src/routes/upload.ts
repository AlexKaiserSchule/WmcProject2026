import { Router, Request, Response, NextFunction } from 'express';
import upload from '../middleware/upload';
import { uploadImage, getImage, deleteImage } from '../controllers/uploadController';

const router = Router();

router.post('/', (req: Request, res: Response, next: NextFunction) => {
  upload.single('image')(req, res, (err: unknown) => {
    if (err) {
      const message = err instanceof Error ? err.message : 'Upload fehlgeschlagen';
      res.status(400).json({ error: message });
      return;
    }
    next();
  });
}, uploadImage);

router.get('/:id', getImage);
router.delete('/:id', deleteImage);

export default router;
