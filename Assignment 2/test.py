import cairo
import numpy as np

def main():
    ims = cairo.ImageSurface(cairo.FORMAT_ARGB32, 64, 64)
    cr = cairo.Context(ims)

    cr.set_source_rgb(0.5, 0.5, 0.5)
    cr.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    cr.set_font_size(5)

    cr.move_to(0, 5)
    cr.translate(448, 448)
    cr.show_text("Let's try the Cairo.")
    cr.scale(8, 8)

    ims.write_to_png("image64.png")


if __name__ == "__main__":
    main()