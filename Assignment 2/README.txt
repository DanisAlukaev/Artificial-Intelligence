Solution for the Home Assignment 2.
Student:    Danis Alukaev
Group:      BS19-02
Student ID: 19BS551

Structure of the submission:
The archive contains 1 pdf file with the report `Report.pdf` and folder with the source code `Source`.
Inside `Source` directory there are following elements:
a. Folder `documents`.
    Contains sample input and output for the program.
    Make sure to place the input images in the `input` directory.
    For the output there will be created directory with the name of a source image inside of the directory `output`. At
    each generation the fittest individual will be saved automatically. Every 20 generations plot with the fitness
    method is updated.
b. Folder `modules`.
    For the project there were created two modules: `art_evolution` and `palette`.
    Module `art_evolution` comprised from the files `evolution.py`, `models.py`, `utils.py`.
    - `evolution.py` contains methods `report`, `plot_fitness` aggregating information about the population and method
      `run_evolution` implementing algorithm flow of genetic algorithm.
    - `models.py` contains classes `Individual` and `Population`, on which the algorithm was based. Each individual has
       its own chromosome consisting of genes (symbols and their parameters). Population consists of individuals and
       has built-in methods for selection, crossover and mutations.
    - `utils.py` contains method for image restoring.
    Module `palette` is used to generate palette for an image via color clustering.
    - Folder `output` aggregates clustered images from which the palette was extracted.
    - `palette.py` contains method `get_palette` that extracts the palette from the original image 
c. File `config.py`.
    This file is used to configure the global parameters of a program.
    In order to apply the genetic algorithm to your own image you will need to modify this file (for more details follow
    the steps provided below).
d. File `main.py`.
    Entry point of the program. Execute this file to run the genetic algorithm.

Getting started:
The program was implemented in Python programming language, so there are several mandatory steps to set up the project's
environment:
1. Copy directory `Source` and place the copy in your project environment.
2. Install package dependencies.
    > pip install requirements.txt
3. Run the program. Inside the `Source` directory execute the following command:
    > python main.py

Apply to your own image:
1. Go to the `config.py`.
2. Change the `PATH_ORIGINAL_IMAGE` variable to relative path of an image, should be of the form of
   'documents/input/<NAME>.jpg'.
3. In case you want to generate an image with a certain color palette create new list comprised from the entries of a
   form (R, G, B). For example, it can be [(123, 138, 103), (98, 110, 93), (61, 60, 47)].
   In order to restore an image using the palette of an original image (it will speed up the process of individuals
   evolution), first use `palette` module to get the list of used colors and assign it to the `PALETTE` variable.
