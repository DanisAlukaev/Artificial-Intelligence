from PIL import Image
import numpy as np

# input image
ORIGINAL_IMAGE = np.asarray(Image.open("documents/input/Mona Lisa.jpg"), dtype=np.int32)
# number of individuals in population
POPULATION_SIZE = 50
# number of generations
NUMBER_GENERATIONS = 1000
