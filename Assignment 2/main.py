from config import IMAGE_SIZE, ORIGINAL_IMAGE
from modules.art_evolution.utils import initialize_canvas, restore_image
from modules.art_evolution.evolution import run_evolution
from modules.art_evolution.fitness import fitness_function

if __name__ == "__main__":
    # get list of symbols comprising the image
    list_symbols = initialize_canvas(IMAGE_SIZE)
    # result = restore_image(list_symbols, IMAGE_SIZE)

    # run evolutionary algorithm
    result = run_evolution(ORIGINAL_IMAGE, IMAGE_SIZE, list_symbols)
    # save the produced image
    result.save('/documents/output/result.png')
