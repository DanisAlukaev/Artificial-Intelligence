from random import randint
import modules.art_evolution.utils as utils
import modules.art_evolution.fitness as fitness
from operator import itemgetter
import time
from multiprocessing import Manager, Process, Pool


def mutate(symbols_list):
    n = len(symbols_list)
    # choose the random symbol
    random_index = randint(0, n - 1)
    # auxiliary list
    mutated_list = symbols_list.copy()

    # mutate the color of symbol
    mutated_list[random_index]['color'] = utils.get_random_color()
    # change the relative priority of symbol
    # important for drawing
    mutated_list = utils.shuffle(mutated_list, random_index)

    # ignore the font size
    # mutated_list[random_index]['font_size'] = utils.get_random_font_size()
    return mutated_list


def create_individual(current_state, image_size, original_image, individuals):
    mutated_list = mutate(current_state[0])
    mutated_image = utils.restore_image(mutated_list, image_size)
    score_mutated = fitness.fitness_function(original_image, mutated_image)
    individuals.append((mutated_list, score_mutated))


def run_evolution(original_image, image_size, symbols_list):
    # set the randomly generated canvas as current state
    canvas = utils.restore_image(symbols_list, image_size)
    current_state = (symbols_list, fitness.fitness_function(original_image, canvas.copy()))

    # duration of evolution is 1000 generation
    for generation in range(1000):
        starttime = time.time()
        # each new generation consisting of 500 mutated descendants
        processes = []

        with Manager() as manager:
            individuals = manager.list()

            for mutation in range(50):
                process = Process(target=create_individual,
                                  args=(current_state, image_size, original_image, individuals,))
                processes.append(process)
                process.start()

            for process in processes:
                process.join()

            # sort the list of individuals by the similarity index
            sorted_individuals = sorted(individuals, key=itemgetter(1), reverse=True)

        # if similarity index was increased in comparison with parent,
        # then the mutation was productive
        if current_state[1] < sorted_individuals[0][1]:
            current_state = sorted_individuals[0]
        print("Evaluation: ", current_state[1])
        print('Time taken = {} seconds \n'.format(time.time() - starttime))
        utils.restore_image(current_state[0], image_size).save('documents/output/' + str(generation) + '.png')
    return utils.restore_image(current_state[0], image_size)
