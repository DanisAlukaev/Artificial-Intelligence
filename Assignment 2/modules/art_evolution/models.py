from random import randint, choice


class Chromosome:

    def __init__(self, image_size, symbols=None):
        self.image_size = image_size
        if symbols is None:
            self.symbols = self._create_random_symbols()
        else:
            self.symbols = symbols

    def _create_random_symbols(self):
        # initialize list consisting of parameters for symbol representation
        # each entry is dictionary containing symbol, position, font_size, color keys
        symbols = []

        # define number of genes in chromosome based on the size of input image
        number_symbols = max(*self.image_size) * 2

        # generate symbols
        for i in range(number_symbols):
            # generate position
            symbol_position = self._get_random_position()
            # generate symbol
            symbol = self._get_random_symbol()
            # generate color
            symbol_color = self._get_random_color()
            # generate the font_size
            symbol_size = self._get_random_font_size()

            # compose the entry
            symbol_parameters = {'symbol': symbol, 'position': symbol_position, 'font_size': symbol_size,
                                 'color': symbol_color}
            # append the entry to list of symbols
            symbols.append(symbol_parameters)
        return symbols

    def _get_random_position(self):
        # randomly generate position on the image
        m, n = self.image_size
        x = randint(0, m)
        y = randint(0, n)
        return x, y

    def _get_random_font_size(self):
        # randomly generate font size
        font_size = randint(5, 250)
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

    def _change_priority(self, symbols, index1):
        # change priority of element with a given index
        # symbols with a greater priority (smaller index) will be displayed on top of the others
        list_length = len(symbols)
        index2 = randint(0, list_length - 1)
        tempo = symbols[index1]
        symbols[index1] = symbols[index2]
        symbols[index2] = tempo

    def mutate(self):
        number_symbols = len(self.symbols)
        # choose the random symbol
        random_index = randint(0, number_symbols - 1)
        # auxiliary list
        mutated_symbols = self.symbols.copy()

        # mutate the color of symbol
        mutated_symbols[random_index]['color'] = self._get_random_color()
        # change the relative priority of symbol
        # important for drawing
        self._change_priority(mutated_symbols, random_index)

        mutated_chromosome = Chromosome(self.image_size, mutated_symbols)
        return mutated_chromosome
