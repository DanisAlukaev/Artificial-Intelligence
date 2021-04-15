# Solution for the Home Assignment 2.
# Student:    Danis Alukaev
# Group:      BS19-02
# Student ID: 19BS551

from modules.art_evolution.evolution import run_evolution

if __name__ == "__main__":
    # run evolutionary algorithm
    # set parameter use_palette to False for using entire color space
    # otherwise, go to config.py and follow the instructions
    result = run_evolution(use_palette=True)
