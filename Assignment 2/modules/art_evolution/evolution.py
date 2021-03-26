from random import randint
import modules.art_evolution.utils as utils
import modules.art_evolution.fitness as fitness
from operator import itemgetter
import time
from modules.art_evolution.models import Chromosome
from multiprocessing import Manager, Process, Pool


def create_individual(parent, original_image, individuals):
    mutated_chromosome = parent[0].mutate()
    mutated_image = utils.restore_image(mutated_chromosome)
    mutated_score = fitness.fitness_function(original_image, mutated_image)
    individuals.append((mutated_chromosome, mutated_score))


def run_evolution(original_image, parent: Chromosome):
    # set the randomly generated canvas as current state
    canvas = utils.restore_image(parent)
    current_state = (parent, fitness.fitness_function(original_image, canvas))

    # duration of evolution is 1000 generation
    for generation in range(1000):
        starttime = time.time()
        with Manager() as manager:
            individuals = manager.list()
            pool = Pool(5)
            # each new generation consisting of 500 mutated descendants
            for mutation in range(50):
                pool.apply_async(create_individual, (current_state, original_image, individuals,))
            pool.close()
            pool.join()
            # sort the list of individuals by the similarity index
            sorted_individuals = sorted(individuals, key=itemgetter(1), reverse=True)

        # if similarity index was increased in comparison with parent,
        # then the mutation was productive
        if current_state[1] < sorted_individuals[0][1]:
            current_state = sorted_individuals[0]
        print("Evaluation: ", current_state[1])
        print('Time taken = {} seconds \n'.format(time.time() - starttime))
        utils.restore_image(current_state[0]).save('documents/output/' + str(generation) + '.png')
    return utils.restore_image(current_state[0])
