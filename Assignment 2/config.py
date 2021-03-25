from PIL import Image
import numpy as np

# input image size
IMAGE_SIZE = (512, 512)
# input image
ORIGINAL_IMAGE = np.asarray(Image.open("documents/input/Mona Lisa.jpg"), dtype=np.int32)
# IMAGE = np.asarray(Image.open("canvas.png").convert('RGB'), dtype=np.int32)
