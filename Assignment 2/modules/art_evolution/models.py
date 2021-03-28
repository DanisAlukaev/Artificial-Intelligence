from random import randint, choice, random, shuffle
import modules.art_evolution.utils as utils
from operator import itemgetter
from skimage.metrics import structural_similarity
import numpy as np
from PIL import Image
import bisect
import time
from multiprocessing import Manager, Pool, Value
from config import CORES_NUMBER, ELITE_SIZE, MUTATIONS_NUMBER


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

        with Manager() as manager:
            population = manager.list()
            pool = Pool(CORES_NUMBER)
            total_fitness = 0
            # randomly initialize set of individuals
            for i in range(population_size):
                individual = Individual(self.image_size)
                pool.apply_async(self._multiprocessing_init, (individual, population,))
            pool.close()
            pool.join()

            population = list(population)
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

    def _multiprocessing_init(self, individual, population):
        population_entry = {'individual': individual}

        individual = utils.restore_image(population_entry['individual'])
        individual_fitness = self._calculate_fitness(individual)
        population_entry['fitness'] = individual_fitness

        population.append(population_entry)

    def _calculate_fitness(self, individual):
        # check the similarity index of the original and candidate image
        individual_pil = Image.fromarray(individual, 'RGB')
        individual_rgb = np.asarray(individual_pil)
        difference = np.sum(np.abs(self.original_image - individual_rgb))
        return difference

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
        with Manager() as manager:
            next_population = manager.list()
            pool = Pool(CORES_NUMBER)
            total_fitness = 0

            for i in range(ELITE_SIZE):
                next_population.append(self.population[i])

            for parents in self.parents:
                pool.apply_async(self._multiprocessing_crossover, (parents, next_population,))
            pool.close()
            pool.join()

            next_population = list(next_population)
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

    def _multiprocessing_crossover(self, parents, next_population):
        parent1, parent2 = parents
        number_genes = len(parent1['individual'].chromosome)

        offspring_chromosome = []
        for i in range(number_genes):
            outcome = randint(1, 2)
            if outcome == 1:
                offspring_chromosome.append(parent1['individual'].chromosome[i])
            else:
                offspring_chromosome.append(parent2['individual'].chromosome[i])

        offspring_entry = {'individual': Individual(parent1['individual'].image_size, offspring_chromosome)}
        offspring = utils.restore_image(offspring_entry['individual'])
        offspring_fitness = self._calculate_fitness(offspring)
        offspring_entry['fitness'] = offspring_fitness
        next_population.append(offspring_entry)

    def mutation(self):
        with Manager() as manager:
            pool = Pool(CORES_NUMBER)
            total_fitness = 0

            for i in range(ELITE_SIZE, len(self.population)):
                pool.apply_async(self._multiprocessing_mutation, (i, ))
            pool.close()
            pool.join()

            population = sorted(self.population, key=itemgetter('fitness'))
            for i in range(ELITE_SIZE):
                total_fitness += population[i]['fitness']

            for i in range(self.population_size):
                if i < ELITE_SIZE:
                    probability = population[i]['fitness'] / total_fitness
                else:
                    probability = 0
                population[i]['probability'] = probability
            self.population = population

    def _multiprocessing_mutation(self, index):
        self.population[index]['individual'].mutate()
        individual = utils.restore_image(self.population[index]['individual'])
        individual_fitness = self._calculate_fitness(individual)
        self.population[index]['fitness'] = individual_fitness

    def get_fittest(self):
        return self.population[0]
