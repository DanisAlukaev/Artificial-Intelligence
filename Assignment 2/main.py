from config import ORIGINAL_IMAGE, POPULATION_SIZE, NUMBER_GENERATIONS
from modules.art_evolution.evolution import run_evolution
from modules.art_evolution.models import Individual

if __name__ == "__main__":
    # run evolutionary algorithm
    result = run_evolution(ORIGINAL_IMAGE, POPULATION_SIZE, NUMBER_GENERATIONS)
    # save the produced image
    result.save('/documents/output/result.png')
