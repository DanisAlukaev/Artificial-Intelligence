from PIL import Image
import time
from modules.art_evolution.models import Population
import modules.art_evolution.utils as utils
from config import ORIGINAL_IMAGE, POPULATION_SIZE, GENERATIONS_NUMBER


def report(population, generation, runtime):
    """
    Method that reports current information about the state of the population and saves the fittest individual.
    :param population: current state of population.
    :param generation: generation sequence number.
    :param runtime: execution time of program on this generation.
    """
    # get the fittest individual
    fittest = population.population[0]
    try:
        # try to save a RGB image
        result = Image.fromarray(utils.restore_image(fittest['individual']))
        result = result.convert('RGB')
        result.save('documents/output/Generation #' + str(generation) + '.jpeg')
        status = 'Saved'
    except:
        status = 'Not saved'

    # translate fitness into a 100 percent scale
    width, height = ORIGINAL_IMAGE.shape[:2]
    fitness = 100 - 100 * fittest['fitness'] / (255 * 3 * width * height)
    print(f"Generation #{generation}: Fitness achieved is {fitness}, runtime is {runtime} seconds, {status}")


def run_evolution():
    # get the start time
    start_time = time.time()
    # initialize new population
    population = Population(ORIGINAL_IMAGE, POPULATION_SIZE)
    # report the state of population
    report(population, 0, time.time() - start_time)

    # develop the population declared number of times
    for generation in range(GENERATIONS_NUMBER):
        # get the start time
        start_time = time.time()
        # perform the selection, crossover and mutation over the population
        population.selection()
        population.crossover()
        population.mutation()
        # report the state of population
        report(population, generation + 1, time.time() - start_time)

    # resultant individual will be the fittest one in the list of individuals
    result = Image.fromarray(utils.restore_image(population.population[0]['individual']))
    return result
