import cairo
import numpy as np

def main():
    ims = cairo.ImageSurface(cairo.FORMAT_ARGB32, 512, 512)
    cr = cairo.Context(ims)

    cr.set_source_rgb(0.5, 0.5, 0.5)
    cr.select_font_face("Arial", cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    cr.set_font_size(40)

    cr.move_to(10, 50)
    cr.show_text("Let's try the Cairo.")

    buf = ims.get_data()
    array = np.ndarray(shape=(512, 512, 3), dtype=np.uint8, buffer=buf)
    print(array.max())

    ims.write_to_png("image.png")


if __name__ == "__main__":
    main()