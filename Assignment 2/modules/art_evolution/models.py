from random import randint, choice, random, shuffle
import modules.art_evolution.utils as utils
from operator import itemgetter
from skimage.metrics import structural_similarity
import numpy as np
from PIL import Image
import bisect
import time
from multiprocessing import Manager, Pool, Value
from config import NUMBER_CORES


class Individual:

    def __init__(self, image_size, chromosome=None):
        self.image_size = image_size
        if chromosome is None:
            self.chromosome = self._initialize_random_genes()
        else:
            self.chromosome = chromosome.copy()

    def _initialize_random_genes(self):
        # initialize list consisting of parameters for symbol representation
        # each entry is dictionary containing symbol, position, font_size, color keys
        chromosome = []

        # define number of genes (symbols) in chromosome based on the size of input image
        number_genes = max(*self.image_size) * 3

        # generate symbols
        for i in range(number_genes):
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
        mutations = [self._mutate_color, self._mutate_priority]
        choice(mutations)()

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

        with Manager() as manager:
            population = manager.list()
            pool = Pool(NUMBER_CORES)
            progenitor = Individual(self.image_size)
            total_fitness = 0
            # randomly initialize set of individuals
            for i in range(population_size):
                pool.apply_async(self._multiprocessing_init, (progenitor, population,))
            pool.close()
            pool.join()

            population = list(population)
            for i in range(population_size):
                total_fitness += population[i]['fitness']

            for i in range(population_size):
                probability = population[i]['fitness'] / total_fitness
                population[i]['probability'] = probability

            self.population = population
            self.parents = []

    def _multiprocessing_init(self, progenitor, population):
        individual_params = progenitor.generate_sibling()
        population_entry = {'individual': individual_params}

        individual = utils.restore_image(population_entry['individual'])
        individual_fitness = self._calculate_fitness(individual)
        population_entry['fitness'] = individual_fitness

        population.append(population_entry)

    def _calculate_fitness(self, individual):
        # check the similarity index of the original and candidate image
        individual_pil = Image.fromarray(individual, 'RGB')
        individual_rgb = np.asarray(individual_pil)
        score_candidate = structural_similarity(self.original_image, individual_rgb,
                                                data_range=self.original_image.max() - individual_rgb.min(),
                                                multichannel=True)
        return score_candidate

    def selection(self):
        parents = []
        for i in range(self.population_size):
            parents.append([self._select_parent(), self._select_parent()])
        self.parents = parents

    def _select_parent(self):
        boundaries = self._cumulative_distribution_function()
        outcome = random()
        parent_idx = bisect.bisect(boundaries, outcome)
        return self.population[parent_idx]

    def _cumulative_distribution_function(self):
        boundaries = []
        cumulative_sum = 0
        probabilities = [individual['probability'] for individual in self.population]
        for probability in probabilities:
            cumulative_sum += probability
            boundaries.append(cumulative_sum)
        return boundaries

    def crossover(self):
        with Manager() as manager:
            next_population = manager.list()
            pool = Pool(NUMBER_CORES)
            total_fitness = 0
            for i, parents in enumerate(self.parents):
                pool.apply_async(self._multiprocessing_crossover, (parents, next_population,))
            pool.close()
            pool.join()
            pool.terminate()

            next_population = list(next_population)
            for i in range(self.population_size):
                total_fitness += next_population[i]['fitness']

            for i in range(self.population_size):
                probability = next_population[i]['fitness'] / total_fitness
                next_population[i]['probability'] = probability

            self.population = next_population

    def _multiprocessing_crossover(self, parents, next_population):
        parent1, parent2 = parents
        number_genes = len(parent1['individual'].chromosome)
        crossover_point = randint(1, number_genes - 2)

        child1 = {'individual': Individual(self.image_size, parent1['individual'].chromosome)}
        child2 = {'individual': Individual(self.image_size, parent2['individual'].chromosome)}

        for i in range(crossover_point, number_genes):
            child1['individual'].chromosome[i], child2['individual'].chromosome[i] = \
                child2['individual'].chromosome[i], child1['individual'].chromosome[i]

        offspring_entry = choice([child1, child2])

        offspring = utils.restore_image(offspring_entry['individual'])
        offspring_fitness = self._calculate_fitness(offspring)
        offspring_entry['fitness'] = offspring_fitness
        next_population.append(offspring_entry)

        print(len(next_population))

    def mutation(self):
        with Manager() as manager:
            population = manager.list()
            pool = Pool(NUMBER_CORES)
            total_fitness = 0

            for individual_entry in self.population.copy():
                pool.apply_async(self._multiprocessing_mutation, (individual_entry, population,))
            pool.close()
            pool.join()

            population = list(population)
            for i in range(self.population_size):
                total_fitness += population[i]['fitness']

            for i in range(self.population_size):
                probability = population[i]['fitness'] / total_fitness
                population[i]['probability'] = probability
            self.population = population

    def _multiprocessing_mutation(self, individual_entry, population):
        if random() <= 0.5:
            individual_entry['individual'].mutate()
            individual = utils.restore_image(individual_entry['individual'])
            individual_fitness = self._calculate_fitness(individual)
            individual_entry['fitness'] = individual_fitness
        population.append(individual_entry)

    def get_fittest(self):
        sorted_population = sorted(self.population, key=itemgetter('fitness'), reverse=True)
        return sorted_population[0]
