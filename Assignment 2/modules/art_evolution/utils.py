from random import randint, choice
from modules.art_evolution.models import Individual
from PIL import Image, ImageDraw, ImageFont


def restore_image(chromosome: Individual):
    # initialize the canvas
    image = Image.new('RGBA', chromosome.image_size)
    image_canvas = ImageDraw.Draw(image)

    # draw all symbols
    for symbol in chromosome.chromosome:
        font = ImageFont.truetype("documents/fonts/arial.ttf", symbol['font_size'])
        image_canvas.text(symbol['position'], symbol['symbol'], font=font, fill=symbol['color'])
    return image
