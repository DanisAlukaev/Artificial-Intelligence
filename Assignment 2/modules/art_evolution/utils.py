from random import randint, choice
from PIL import Image, ImageDraw, ImageFont


def get_random_position(image_size):
    # generate position on the image
    m, n = image_size
    x = randint(0, m)
    y = randint(0, n)
    return x, y


def get_random_font_size():
    font_size = randint(5, 250)
    return font_size


def shuffle(symbols_list, index_element1):
    list_length = len(symbols_list)
    index_element2 = randint(0, list_length - 1)
    tempo = symbols_list[index_element1]
    symbols_list[index_element1] = symbols_list[index_element2]
    symbols_list[index_element2] = tempo
    return symbols_list


def get_random_symbol():
    # generate random symbol
    range_decimal = choice([(33, 126), (161, 383)])
    decimal = randint(*range_decimal)
    symbol = chr(decimal)
    return symbol


def get_random_color():
    # generate the random space
    red = randint(0, 255)
    green = randint(0, 255)
    blue = randint(0, 255)
    alpha = randint(0, 255)
    return red, green, blue, alpha


def initialize_canvas(image_size):
    # list consisting of parameters for symbol representation
    # each entry is dictionary containing symbol, position, font_size, color keys
    list_symbols = []

    # define number of genes in chromosome based on the size of input image
    size = max(*image_size)
    number_symbols = size * 2

    # generate parameters for symbols
    for i in range(number_symbols):
        # generate position
        symbol_position = get_random_position(image_size)
        # generate symbol
        symbol = get_random_symbol()
        # generate color
        symbol_color = get_random_color()
        # generate the font_size
        symbol_size = get_random_font_size()
        # compose the entry
        symbol_parameters = {'symbol': symbol, 'position': symbol_position, 'font_size': symbol_size,
                             'color': symbol_color}
        # append the entry to list of symbols
        list_symbols.append(symbol_parameters)
    return list_symbols


def restore_image(symbols_list, image_size):
    # initialize the canvas
    image = Image.new('RGBA', image_size)
    image_canvas = ImageDraw.Draw(image)

    # draw all symbols
    for symbol_entry in symbols_list:
        font = ImageFont.truetype("documents/fonts/arial.ttf", symbol_entry['font_size'])
        image_canvas.text(symbol_entry['position'], symbol_entry['symbol'], font=font, fill=symbol_entry['color'])
    return image
