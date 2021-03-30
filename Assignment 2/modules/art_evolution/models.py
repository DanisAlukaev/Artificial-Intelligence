from random import randint, choice, random, shuffle
import modules.art_evolution.utils as utils
from operator import itemgetter
from skimage.metrics import structural_similarity
import numpy as np
import concurrent.futures
import multiprocessing as mp
from PIL import Image
import bisect
import time
from multiprocessing import Manager, Pool, Value
from config import CORES_NUMBER, ELITE_SIZE, MUTATIONS_NUMBER


def _multiprocessing_init(original_image, individual):
    population_entry = {'individual': individual}

    individual = utils.restore_image(population_entry['individual'])
    individual_fitness = _calculate_fitness(original_image, individual)
    population_entry['fitness'] = individual_fitness

    return population_entry


def _calculate_fitness(original_image, individual):
    # check the similarity index of the original and candidate image
    individual_pil = Image.fromarray(individual, 'RGB')
    individual_rgb = np.asarray(individual_pil)
    difference = np.sum(np.abs(original_image - individual_rgb))
    return difference


def _multiprocessing_crossover(original_image, parents):
    parent1, parent2 = parents
    number_genes = len(parent1['individual'].chromosome)

    offspring_chromosome = []
    for i in range(number_genes):
        gene = choice([parent1['individual'].chromosome[i], parent2['individual'].chromosome[i]])
        offspring_chromosome.append(gene)

    offspring_entry = {'individual': Individual(parent1['individual'].image_size, offspring_chromosome)}
    offspring = utils.restore_image(offspring_entry['individual'])
    offspring_fitness = _calculate_fitness(original_image, offspring)
    offspring_entry['fitness'] = offspring_fitness
    return offspring_entry


def _multiprocessing_mutation(original_image, individual):
    individual['individual'].mutate()
    individual_image = utils.restore_image(individual['individual'])
    individual_fitness = _calculate_fitness(original_image, individual_image)
    individual['fitness'] = individual_fitness
    return individual


class Individual:

    def __init__(self, image_size, chromosome=None):
        self.image_size = image_size
        if chromosome is None:
            self.chromosome = self._initialize_random_genes()
        else:
            self.chromosome = chromosome.copy()

    def _generate_random_gen(self):
        # generate position
        symbol_position = self._get_random_position()
        # generate symbol
        symbol = self._get_random_symbol()
        # generate color
        symbol_color = self._get_random_color()
        # generate the font_size
        symbol_size = self._get_random_font_size()

        # compose the entry
        gene = {'symbol': symbol, 'position': symbol_position, 'font_size': symbol_size, 'color': symbol_color}
        return gene

    def _initialize_random_genes(self):
        # initialize list consisting of parameters for symbol representation
        # each entry is dictionary containing symbol, position, font_size, color keys
        chromosome = []

        # define number of genes (symbols) in chromosome based on the size of input image
        number_genes = max(*self.image_size) * 3

        # generate symbols
        for i in range(number_genes):
            gene = self._generate_random_gen()
            # append gen to the chromosome
            chromosome.append(gene)
        return chromosome

    def generate_sibling(self):
        sibling_chromosome = self.chromosome.copy()
        shuffle(sibling_chromosome)
        for gen in sibling_chromosome:
            gen['color'] = self._get_random_color()
        return Individual(self.image_size, sibling_chromosome)

    def _get_random_position(self):
        # randomly generate position on the image
        m, n = self.image_size
        x = randint(0, m)
        y = randint(0, n)
        return x, y

    def _get_random_font_size(self):
        # randomly generate font size
        font_size = randint(50, 85)
        return font_size

    def _get_random_symbol(self):
        # randomly generate symbol
        # symbol is either ASCII special character or Basic Latin or Latin-1 supplement
        range_decimal = choice([(33, 126), (161, 383)])
        decimal = randint(*range_decimal)
        symbol = chr(decimal)
        return symbol

    def _get_random_color(self):
        # randomly generate color in RGBA
        red = randint(0, 255)
        green = randint(0, 255)
        blue = randint(0, 255)
        alpha = 255
        return red, green, blue, alpha

    def mutate(self):
        for i in range(MUTATIONS_NUMBER):
            mutations = [self._mutate_color, self._mutate_priority, self._mutate_parameters, self._mutate_lose_gen]
            choice(mutations)()

    def _mutate_lose_gen(self):
        number_genes = len(self.chromosome)
        # choose the random symbol
        random_idx = randint(0, number_genes - 1)
        del self.chromosome[random_idx]
        self.chromosome.append(self._generate_random_gen())

    def _mutate_parameters(self):
        number_genes = len(self.chromosome)
        # choose the random symbol
        random_idx = randint(0, number_genes - 1)
        self.chromosome[random_idx] = self._generate_random_gen()

    def _mutate_color(self):
        number_genes = len(self.chromosome)
        # choose the random symbol
        random_idx = randint(0, number_genes - 1)
        # auxiliary list
        mutated_chromosome = self.chromosome.copy()

        # mutate the color of symbol
        mutated_chromosome[random_idx]['color'] = self._get_random_color()
        self.chromosome = mutated_chromosome

    def _mutate_priority(self):
        number_genes = len(self.chromosome)
        # choose the random symbol
        gene1_idx = randint(0, number_genes - 1)
        # auxiliary list
        mutated_chromosome = self.chromosome.copy()

        # swap two genes
        # symbols with a greater priority (smaller index) will be displayed on top of the others
        gene2_idx = randint(0, gene1_idx)
        tempo = mutated_chromosome[gene1_idx]
        mutated_chromosome[gene1_idx] = mutated_chromosome[gene2_idx]
        mutated_chromosome[gene2_idx] = tempo

        self.chromosome = mutated_chromosome


class Population:

    def __init__(self, original_image, population_size):
        self.original_image = original_image
        self.population_size = population_size
        self.image_size = original_image.shape[:2]

        population = []
        total_fitness = 0

        with concurrent.futures.ProcessPoolExecutor(max_workers=CORES_NUMBER) as executor:
            results = []
            for i in range(population_size):
                individual = Individual(self.image_size)
                results.append(executor.submit(_multiprocessing_init, self.original_image, individual))

            for futures in concurrent.futures.as_completed(results):
                population.append(futures.result())

        population = sorted(population, key=itemgetter('fitness'))
        for i in range(ELITE_SIZE):
            total_fitness += population[i]['fitness']

        for i in range(self.population_size):
            if i < ELITE_SIZE:
                probability = population[i]['fitness'] / total_fitness
            else:
                probability = 0
            population[i]['probability'] = probability

        self.population = population
        self.parents = []

    def selection(self):
        parents = []
        for i in range(self.population_size - ELITE_SIZE):
            parent1 = self._select_parent()
            parent2 = self._select_parent()
            while parent1 == parent2:
                parent2 = self._select_parent()
            parents.append((parent1, parent2))
        self.parents = parents

    def _select_parent(self):
        boundaries = self._cumulative_distribution_function()
        outcome = random()
        parent_idx = bisect.bisect(boundaries, outcome)
        return self.population[parent_idx]

    def _cumulative_distribution_function(self):
        boundaries = []
        cumulative_sum = 0
        probabilities = [self.population[i]['probability'] for i in range(ELITE_SIZE)]
        for probability in probabilities:
            cumulative_sum += probability
            boundaries.append(cumulative_sum)
        return boundaries

    def crossover(self):
        next_population = []
        for i in range(ELITE_SIZE):
            next_population.append(self.population[i])
        with concurrent.futures.ProcessPoolExecutor(max_workers=CORES_NUMBER) as executor:
            results = [executor.submit(_multiprocessing_crossover, self.original_image, parents) for parents in
                       self.parents]

            for futures in concurrent.futures.as_completed(results):
                next_population.append(futures.result())

        total_fitness = 0
        next_population = sorted(next_population, key=itemgetter('fitness'))

        for i in range(ELITE_SIZE):
            total_fitness += next_population[i]['fitness']

        for i in range(self.population_size):
            if i < ELITE_SIZE:
                probability = next_population[i]['fitness'] / total_fitness
            else:
                probability = 0
            next_population[i]['probability'] = probability
        self.population = next_population

    def mutation(self):
        mutated_population = []
        for i in range(ELITE_SIZE):
            mutated_population.append(self.population[i])
        population_before_mutation = self.population.copy()[10:]
        with concurrent.futures.ProcessPoolExecutor(max_workers=CORES_NUMBER) as executor:
            results = [executor.submit(_multiprocessing_mutation, self.original_image, individual)
                       for individual in population_before_mutation]

            for futures in concurrent.futures.as_completed(results):
                mutated_population.append(futures.result())
        len(mutated_population)
        total_fitness = 0
        mutated_population = sorted(mutated_population, key=itemgetter('fitness'))
        for i in range(ELITE_SIZE):
            total_fitness += mutated_population[i]['fitness']

        for i in range(self.population_size):
            if i < ELITE_SIZE:
                probability = mutated_population[i]['fitness'] / total_fitness
            else:
                probability = 0
            mutated_population[i]['probability'] = probability
        self.population = mutated_population

    def get_fittest(self):
        return self.population[0]
