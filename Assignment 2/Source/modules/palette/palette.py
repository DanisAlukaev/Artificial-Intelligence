# Solution for the Home Assignment 2.
# Student:    Danis Alukaev
# Group:      BS19-02
# Student ID: 19BS551

import skimage.segmentation as seg
import skimage.color as skcolor
from PIL import Image
import numpy as np


def get_palette(image_path, clusters=200):
    """
    Method that generate color palette for the original image.
    The image is clustered and average pixel value for each cluster is saved.
    :return: list of colors.
    """
    image = np.asarray(Image.open(image_path), dtype=np.int32)
    # translate color to 0..1 RGB scale
    scaled = image / 255

    # cluster source image and restore it from the labels
    labels = seg.slic(scaled, start_label=0, n_segments=clusters)
    clustered = skcolor.label2rgb(labels, scaled, bg_label=-1, kind='avg')

    # convert ot 8 bit format
    clustered = np.ceil(clustered * 255)
    clustered = clustered.astype(np.uint8)

    file_name = image_path.split('/')[-1][:-4]
    # save restored image
    Image.fromarray(clustered).save(f'output/{file_name} - clustered.jpg')

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
PATH_TO_IMAGE = "../../documents/input/Head.jpg"
palette = get_palette(PATH_TO_IMAGE)
# copy the output and create new palette in config.py
print(palette)
