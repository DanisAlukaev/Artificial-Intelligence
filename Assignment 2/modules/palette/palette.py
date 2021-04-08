import skimage.segmentation as seg
import skimage.color as skcolor
from PIL import Image
import numpy as np


def get_palette(image, clusters = 200):
    """
    Method that generate color palette for the original image.
    The image is clustered and average pixel value for each cluster is saved.
    :return: list of colors.
    """
    # translate color to 0..1 RGB scale
    scaled = image / 255

    # cluster source image and restore it from the labels
    labels = seg.slic(scaled, start_label=0, n_segments=clusters)
    clustered = skcolor.label2rgb(labels, scaled, bg_label=-1, kind='avg')

    # convert ot 8 bit format
    clustered = np.ceil(clustered * 255)
    clustered = clustered.astype(np.uint8)

    # save restored image
    Image.fromarray(clustered).save('restored.jpg')

    # initialize list for palette
    palette = []
    # initialize starting index
    current_label = -1
    height, width = image.shape[:2]

    # add color of pixel if its segment was not processed
    for i in range(height):
        for j in range(width):
            if labels[i, j] > current_label:
                current_label = labels[i, j]
                color = tuple(clustered[i, j])
                # update palette
                if color not in palette:
                    palette.append(color)
    return palette


# set path to the image
path_to_image = "../../documents/input/Mandrill.jpg"
image = np.asarray(Image.open(path_to_image), dtype=np.int32)
palette = get_palette(image)
# copy the output and create new palette in config.py
print(palette)
