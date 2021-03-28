from PIL import Image
import numpy as np

# input image
ORIGINAL_IMAGE = np.asarray(Image.open("documents/input/Mona Lisa.jpg"), dtype=np.int32)
# number of individuals in population
POPULATION_SIZE = 500
# elite group size
ELITE_SIZE = 10
# number of mutations
MUTATIONS_NUMBER = 1
# number of generations
GENERATIONS_NUMBER = 9999

# number of cores
CORES_NUMBER = 8
