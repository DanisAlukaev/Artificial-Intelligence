from random import randint, choice, random, shuffle
from operator import itemgetter
import concurrent.futures
from PIL import Image
import numpy as np
import bisect
from config import (CORES_NUMBER, ELITE_SIZE, MUTATIONS_NUMBER, GENES_NUMBER, MIN_FONT, MAX_FONT, IMAGE_SIZE,
                    ORIGINAL_IMAGE, PALETTE)
import modules.art_evolution.utils as utils


def _calculate_fitness(individual):
    """
    Method used to compute the fitness of an individual.
    As fitness, the sum of the absolute values of the differences between the color parameters of the individual and
    the original image was taken. The lower the value the better.
    :param individual: member of population.
    :return: fitness of individual.
    """
    # convert image from RGBA to RGB
    individual_pil = Image.fromarray(individual)
    individual_pil = individual_pil.convert('RGB')
    individual_rgb = np.asarray(individual_pil)
    # compute the difference between the images
    difference = np.sum(np.abs(ORIGINAL_IMAGE - individual_rgb))
    return difference


def _multiprocessing_init(individual):
    """
    Method used for multiprocessing computations at the initial stage.
    Restore image from the chromosome of individual and calculates its fitness.
    :param individual: member of population.
    :return: dictionary comprising of individual and its fitness.
    """
    individual_image = utils.restore_image(individual)
    individual_fitness = _calculate_fitness(individual_image)
    population_entry = {'individual': individual, 'fitness': individual_fitness}
    return population_entry


def _multiprocessing_crossover(parents):
    # unpack parents of the spring
    parent1, parent2 = parents

    # observation showed that passing random genes to an offspring yields better in terms of fitness function result
    # rather than using a crossover point
    offspring_chromosome = []
    for i in range(GENES_NUMBER):
        # randomly choose gene either from first or second parent
        gene = choice([parent1['individual'].chromosome[i], parent2['individual'].chromosome[i]])
        offspring_chromosome.append(gene)

    offspring = Individual(offspring_chromosome)
    offspring_image = utils.restore_image(offspring)
    offspring_fitness = _calculate_fitness(offspring_image)
    offspring_entry = {'individual': offspring, 'fitness': offspring_fitness}
    return offspring_entry


def _multiprocessing_mutation(individual):
    """
    Method used for multiprocessing computations at the mutation stage.
    Mutate the chromosome of individual. Restore image from chromosome and calculates fitness of individual.
    :param individual: member of population.
    :return: dictionary comprising of individual and its fitness.
    """
    individual['individual'].mutate()
    individual_image = utils.restore_image(individual['individual'])
    individual_fitness = _calculate_fitness(individual_image)
    individual['fitness'] = individual_fitness
    return individual


class Individual:

    def __init__(self, chromosome=None, use_palette=False):
        """
        Constructor of the class Individual.
        :param chromosome: list of genes.
        """
        self.use_palette = use_palette
        if chromosome is None:
            self._initialize_random_genes()
        else:
            self.chromosome = chromosome.copy()

    def _generate_random_gene(self):
        """
        Method that stochastically generate gene of the individual.
        Gene is a dictionary with keys 'symbol', 'position', 'font_size' and 'color' with each of those associated
        value describing it.
        """
        # generate position
        symbol_position = self._get_random_position()
        # generate symbol
        symbol = self._get_random_symbol()
        # generate color
        symbol_color = self._get_random_color()
        # generate the font_size
        symbol_size = self._get_random_font_size()

        # compose the gene
        gene = {'symbol': symbol, 'position': symbol_position, 'font_size': symbol_size, 'color': symbol_color}
        return gene

    def _initialize_random_genes(self):
        """
        Method that stochastically generate chromosome of the current individual.
        Chromosome consists of genes, each of whose is a dictionary with keys 'symbol', 'position', 'font_size' and
        'color'.
        """
        # initialize a list of genes
        chromosome = []
        # append to the chromosome randomly created genes
        for i in range(GENES_NUMBER):
            gene = self._generate_random_gene()
            chromosome.append(gene)
        self.chromosome = chromosome

    def generate_sibling(self):
        """
        Method that generate new individual inheriting the glyph, font size, position from the current member of
        population, but has different ordering and colors of glyphs.
        :return:
        """
        # copy the current chromosome
        sibling_chromosome = self.chromosome.copy()
        # change the ordering of genes
        shuffle(sibling_chromosome)
        # assign new colors to glyphs
        for gene in sibling_chromosome:
            gene['color'] = self._get_random_color()
        return Individual(sibling_chromosome, use_palette=self.use_palette)

    @staticmethod
    def _get_random_position():
        """
        Method that choose the random position on the image surface.
        :return: x,y-coordinates.
        """
        # randomly generate position on the image
        m, n = IMAGE_SIZE
        x = randint(0, m)
        y = randint(0, n)
        return x, y

    @staticmethod
    def _get_random_font_size():
        """
        Method that choose the random size of font defined with the declared range.
        :return: random font size.
        """
        # randomly generate font size
        font_size = randint(MIN_FONT, MAX_FONT)
        return font_size

    @staticmethod
    def _get_random_symbol():
        """
        Method that choose random symbol out of alphabet consisting of Basic Latin,
        Latin-1 supplement and digits glyphs.
        :return: random symbol.
        """
        # define alphabet
        alphabet = "qwertyuiopasdfghjklzxcvbnmàáâãäåèéêëñòóôõöùúûüýÿ1234567890"
        # randomly choose the symbol
        symbol = alphabet[randint(0, len(alphabet) - 1)]
        return symbol

    def _get_random_color(self):
        """
        Method that generate 8-bit RGBA color.
        :return: random RGBA color.
        """
        if self.use_palette:
            idx = randint(0, len(PALETTE) - 1)
            red, green, blue = PALETTE[idx]
        else:
            red = randint(0, 255)
            green = randint(0, 255)
            blue = randint(0, 255)
        # using constant alpha-channel parameter improve the quality of the output image
        alpha = 255
        return red, green, blue, alpha

    def mutate(self):
        """
        Method that perform declared number of the mutations.
        There are 4 basic mutations with same probability to occur:
        1. Mutate color parameter of the gene.
        2. Mutate the priority of the gene (gene with greater priority displayed on the top of others).
        3. Losing of some gene that is followed by appending of random gene.
        4. Mutate entire gene by changing all the parameters.
        """
        for i in range(MUTATIONS_NUMBER):
            # define set of mutations
            mutations = [self._mutate_color, self._mutate_priority, self._mutate_lose_gen, self._mutate_parameters]
            # mutate the gene
            choice(mutations)()

    def _mutate_color(self):
        """
        Method that change the color parameter of the random gene.
        """
        # choose the random symbol
        random_idx = randint(0, GENES_NUMBER - 1)
        # assign random color for symbol
        self.chromosome[random_idx]['color'] = self._get_random_color()

    def _mutate_priority(self):
        """
        Method changing the priority of the random gene.
        Swaps two randomly genes.
        :return:
        """
        # choose two random indexes
        gene1_idx = randint(2, GENES_NUMBER - 1)
        gene2_idx = randint(0, gene1_idx - 1)

        # swap two genes
        tempo = self.chromosome[gene1_idx]
        self.chromosome[gene1_idx] = self.chromosome[gene2_idx]
        self.chromosome[gene2_idx] = tempo

    def _mutate_lose_gen(self):
        """
        Method that delete random gene and create new one.
        """
        # choose the random symbol
        random_idx = randint(0, GENES_NUMBER - 1)
        del self.chromosome[random_idx]
        self.chromosome.insert(0, self._generate_random_gene())

    def _mutate_parameters(self):
        """
        Method that set new parameters for the random gene.
        """
        # choose the random symbol
        random_idx = randint(0, GENES_NUMBER - 1)
        self.chromosome[random_idx] = self._generate_random_gene()


class Population:

    def __init__(self, population_size, use_palette):
        """
        Constructor for the class Population.
        Stochastically generates initial population.
        :param population_size: number of individuals in population.
        """
        # set population size
        self.population_size = population_size
        # initialize list of individuals
        population = []
        # initialize total fitness
        total_fitness = 0

        # use multiple processes to create individuals and compute their fitness
        with concurrent.futures.ProcessPoolExecutor(max_workers=CORES_NUMBER) as executor:
            results = []
            # create progenitor
            individual = Individual(use_palette=use_palette)
            for i in range(self.population_size):
                # generate sibling
                sibling = Individual(use_palette=use_palette)
                # process sibling
                results.append(executor.submit(_multiprocessing_init, sibling))

            for futures in concurrent.futures.as_completed(results):
                # store the result
                population.append(futures.result())
        # sort the population by value of fitness
        population = sorted(population, key=itemgetter('fitness'))

        # aggregate the fitness of population elite
        for i in range(ELITE_SIZE):
            total_fitness += population[i]['fitness']
        # auxiliary variable to scale the fitness value
        probability_scale = population[0]['fitness'] + population[ELITE_SIZE - 1]['fitness']

        for i in range(self.population_size):
            # assign probability of being selected based on the fitness value of individual
            probability = (probability_scale - population[i]['fitness']) / total_fitness if i < ELITE_SIZE else 0
            population[i]['probability'] = probability

        # save the population
        self.population = population
        # initialize parents list
        self.parents = []

    def selection(self):
        """
        Method that select pairs of individuals to pass their genes to next generation.
        Only the fittest individuals that are in the elite can be chosen.
        """
        # initialize list of parents
        parents = []
        # each pair will produce one individual
        for i in range(self.population_size - ELITE_SIZE):
            # choose two non-equal parents
            parent1 = self._select_parent()
            parent2 = self._select_parent()
            while parent1 == parent2:
                parent2 = self._select_parent()
            # save parents in list
            parents.append((self.population[parent1], self.population[parent2]))
        self.parents = parents

    def _select_parent(self):
        """
        Method that stochastically choose the individual based on the fitness value.
        Each of individuals has probability to be chosen.
        :return: index of chosen individual.
        """
        # define the boundaries of CDF
        boundaries = self._cumulative_distribution_function()
        # select individual
        parent_idx = bisect.bisect(boundaries, random())
        return parent_idx

    def _cumulative_distribution_function(self):
        """
        Method that compute cumulative distribution function for elite individuals to be selected.
        :return: list of boundaries.
        """
        # initialize boundary probabilities
        boundaries = []
        # initialize cumulative sum of probabilities
        cumulative_sum = 0
        # get probabilities for elite individuals
        probabilities = [self.population[i]['probability'] for i in range(ELITE_SIZE)]
        # set boundaries
        for probability in probabilities:
            cumulative_sum += probability
            boundaries.append(cumulative_sum)
        return boundaries

    def _assign_probabilities(self, population):
        """
        Method that assign probabilities to be selected to elite individuals.
        :param population: population to be processed.
        """
        # initialize total fitness
        total_fitness = 0
        # sort the population by value of fitness
        population = sorted(population, key=itemgetter('fitness'))

        # aggregate the fitness of population elite
        for i in range(ELITE_SIZE):
            total_fitness += population[i]['fitness']
        # auxiliary variable to scale the fitness value
        probability_scale = population[0]['fitness'] + population[ELITE_SIZE - 1]['fitness']

        for i in range(self.population_size):
            # assign probability of being selected based on the fitness value of individual
            probability = (probability_scale - population[i]['fitness']) / total_fitness if i < ELITE_SIZE else 0
            population[i]['probability'] = probability
        # save the population
        self.population = population

    def crossover(self):
        """
        Method that perform crossover in population.
        Uses parents chosen by selection operator.
        """
        # initialize list of individuals moving to next population
        next_population = []
        # move the elite to next population
        for i in range(ELITE_SIZE):
            next_population.append(self.population[i])

        # use multiple processes to combine genetic information and compute fitness of the offspring
        with concurrent.futures.ProcessPoolExecutor(max_workers=CORES_NUMBER) as executor:
            # process parents
            results = [executor.submit(_multiprocessing_crossover, parents) for parents in
                       self.parents]

            for futures in concurrent.futures.as_completed(results):
                # store the result
                next_population.append(futures.result())

        # assign probabilities to be selected
        self._assign_probabilities(next_population)

    def mutation(self):
        """
        Method that perform mutation on each offspring.
        """
        # initialize list of mutated individuals
        mutated_population = []
        # move the elite to next population
        for i in range(ELITE_SIZE):
            mutated_population.append(self.population[i])
        # copy individuals to be mutated
        population_before_mutation = self.population.copy()[10:]

        # use multiple processes to mutate individuals and compute fitness of mutated individuals
        with concurrent.futures.ProcessPoolExecutor(max_workers=CORES_NUMBER) as executor:
            # process individuals
            results = [executor.submit(_multiprocessing_mutation, individual)
                       for individual in population_before_mutation]

            for futures in concurrent.futures.as_completed(results):
                # store the result
                mutated_population.append(futures.result())

        # assign probabilities to be selected
        self._assign_probabilities(mutated_population)
