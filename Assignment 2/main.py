from config import IMAGE_SIZE, ORIGINAL_IMAGE
from modules.art_evolution.evolution import run_evolution
from modules.art_evolution.models import Chromosome

if __name__ == "__main__":
    # initialize initial chromosome
    initial_chromosome = Chromosome(IMAGE_SIZE)

    # run evolutionary algorithm
    result = run_evolution(ORIGINAL_IMAGE, initial_chromosome)
    # save the produced image
    result.save('/documents/output/result.png')
