import modules.art_evolution.utils as utils
import time
from modules.art_evolution.models import Population, Individual
from PIL import Image



def report(fittest, generation, runtime):
    try:
        result = Image.fromarray(utils.restore_image(fittest['individual']))
        result = result.convert('RGB')
        result.save('documents/output/Generation #' + str(generation) + '.jpeg')
        status = True
    except:
        status = False
    width, height = fittest['individual'].image_size
    ssim = 100 - 100 * fittest['fitness'] / (765 * width * height)
    print(f"Generation #{generation}: Similarity index is {ssim}, runtime is "
          f"{runtime} seconds, Saved={status}")


def run_evolution(original_image, population_size, number_generations):
    start_time = time.time()
    population = Population(original_image, population_size)
    fittest = population.get_fittest()
    report(fittest, 0, time.time() - start_time)

    for generation in range(number_generations):
        start_time = time.time()

        population.selection()
        population.crossover()
        population.mutation()

        fittest = population.get_fittest()
        report(fittest, generation + 1, time.time() - start_time)
    return utils.restore_image(fittest['individual'])
