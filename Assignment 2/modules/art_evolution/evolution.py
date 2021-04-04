import matplotlib.ticker as ticker
from matplotlib.pyplot import *
from PIL import Image
import numpy as np
import time
import os
from modules.art_evolution.models import Population
import modules.art_evolution.utils as utils
from config import IMAGE_SIZE, POPULATION_SIZE, GENERATIONS_NUMBER, FILE_NAME


def get_fitness(population):
    """
    Method that compute fitness of individual in percents.
    :param population: current state of population.
    :return: fitness of individual.
    """
    # get the fittest individual
    fittest = population.population[0]
    # translate fitness into a 100 percent scale
    width, height = IMAGE_SIZE
    fitness = 100 - 100 * fittest['fitness'] / (255 * 3 * width * height)
    return fitness


def report(population, generation, runtime):
    """
    Method that report current information about the state of the population and saves the fittest individual.
    :param population: current state of population.
    :param generation: generation sequence number.
    :param runtime: execution time of program on this generation.
    """
    # get the fittest individual
    fittest = population.population[0]

    # create directory if needed
    try:
        # try to save a RGB image
        result = Image.fromarray(utils.restore_image(fittest['individual']))
        result = result.convert('RGB')
        generation_str = str(generation)
        nulls = ''
        for i in range(4 - len(generation_str)):
            nulls += '0'
        filename = f'documents/output/{FILE_NAME}/{nulls + generation_str}.jpeg'
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        result.save(filename)
        status = 'Saved'
    except Exception:
        status = 'Not saved'

    print(
        f"Generation #{generation}: Fitness achieved is {get_fitness(population)}, runtime is {runtime} seconds, {status}")


def plot_fitness(generations, fitness):
    """
    Method that plot fitness function for each population and save it in
    :param generations: numpy array of generations numbers.
    :param fitness: numpy array of fitness.
    """
    fig, (ax1) = subplots(1, 1, figsize=(15, 10))
    ax1.set_title(fr'Fitness for the image "{FILE_NAME}"')
    ax1.set(xlabel=r'Generation number', ylabel=r'Fitness, in %')
    ax1.xaxis.set_major_locator(ticker.MaxNLocator(integer=True))
    ax1.yaxis.set_major_locator(ticker.MaxNLocator(integer=True))
    ticklabel_format(style='plain', axis='x', useOffset=False)

    ax1.grid()
    ax1.set_xlim(generations.min(), generations.max())
    ax1.plot(generations, fitness)
    savefig(f'documents/output/{FILE_NAME}/Fitness report.jpg')


def run_evolution():
    # get the start time
    start_time = time.time()
    # initialize new population
    population = Population(POPULATION_SIZE)
    # report the state of population
    report(population, 0, time.time() - start_time)

    generations = np.array([])
    fitness = np.array([])

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

        generations = np.append(generations, generation)
        fitness = np.append(fitness, get_fitness(population))
        if generation % 20 == 0:
            plot_fitness(generations, fitness)

    # resultant individual will be the fittest one in the list of individuals
    result = Image.fromarray(utils.restore_image(population.population[0]['individual']))
    return result
