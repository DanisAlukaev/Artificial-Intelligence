from PIL import Image
import numpy as np

# input image
PATH_ORIGINAL_IMAGE = "documents/input/Mona Lisa.jpg"
ORIGINAL_IMAGE = np.asarray(Image.open(PATH_ORIGINAL_IMAGE), dtype=np.int32)

# number of individuals in population
POPULATION_SIZE = 500
# elite group size
ELITE_SIZE = 10

# number of mutations
MUTATIONS_NUMBER = 1
# number of generations
GENERATIONS_NUMBER = 9999
# number of genes
GENES_NUMBER = 1500

# minimal font
MIN_FONT = 40
# maximal font
MAX_FONT = 80

# number of cores
CORES_NUMBER = 8
