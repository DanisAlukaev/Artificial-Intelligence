from config import ORIGINAL_IMAGE, POPULATION_SIZE, NUMBER_GENERATIONS
from modules.art_evolution.evolution import run_evolution
from PIL import Image

if __name__ == "__main__":
    # run evolutionary algorithm
    result = run_evolution(ORIGINAL_IMAGE, POPULATION_SIZE, NUMBER_GENERATIONS)
    # save the produced image
    result = Image.fromarray(result)
    result.save('/documents/output/result.png')
