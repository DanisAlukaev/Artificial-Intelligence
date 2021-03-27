from modules.art_evolution.models import Individual
import numpy as np
import cairo


def restore_image(individual: Individual):
    image_surface = cairo.ImageSurface(cairo.FORMAT_ARGB32, *individual.image_size)
    context = cairo.Context(image_surface)

    context.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    # draw all symbols
    for symbol in individual.chromosome:
        context.set_font_size(symbol['font_size'])
        red, green, blue, alpha = symbol['color']
        context.set_source_rgb(red / 255, green / 255, blue / 255)
        context.move_to(*symbol['position'])
        context.show_text(symbol['symbol'])
    buffer = image_surface.get_data()
    image = np.ndarray(shape=(512, 512, 4), dtype=np.uint8, buffer=buffer)
    return image
